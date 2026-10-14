import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/app_controller.dart';
import 'package:numcross/app/app_prefs.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';
import 'package:numcross/app_root.dart';
import 'package:numcross/monetization/ad_config.dart';
import 'package:numcross/monetization/ad_service.dart';
import 'package:numcross/monetization/monetization.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class FakeAds implements AdService {
  AdAudience? audience;
  int starts = 0, rewardedShown = 0;
  bool ready = true;
  bool grantReward = true;

  @override
  Future<void> start(AdAudience a) async {
    starts++;
    audience = a;
  }

  @override
  Future<void> updateAudience(AdAudience a) async => audience = a;

  @override
  bool get rewardedReady => ready;

  @override
  Future<bool> showRewarded() async {
    rewardedShown++;
    return grantReward;
  }

  @override
  Future<bool> privacyOptionsRequired() async => true;

  @override
  Future<void> showPrivacyOptions() async {}
}

Future<Monetization> newMoney(
  FakeAds ads, [
  Map<String, Object> v = const {},
]) async {
  mockStorage(v);
  return Monetization(
    await SharedPreferences.getInstance(),
    ads: ads,
    now: () => DateTime(2026, 10, 14, 9),
  );
}

Future<AdadiApp> appWith(FakeAds ads, Map<String, Object> storage) async {
  mockStorage(storage);
  final prefs = await AppPrefs.load();
  return AdadiApp(
    locale: LocaleController(initial: languageForCode('en')),
    app: AppController(
      prefs,
      monetization: Monetization(prefs.shared, ads: ads),
    ),
  );
}

void main() {
  group('coins', () {
    test('start with none (friends give hints), spend and earn', () async {
      final m = await newMoney(FakeAds());
      expect(m.coins, AdConfig.startingCoins);
      expect(m.coins, 0);
      expect(await m.spendCoin(), isFalse);
      await m.addCoins(2);
      expect(m.coins, 2);
      expect(await m.spendCoin(), isTrue);
      expect(m.coins, 1);
    });

    test('a watched rewarded ad gives a coin, at most 5 a day', () async {
      final ads = FakeAds();
      final m = await newMoney(ads);
      for (var i = 0; i < 7; i++) {
        await m.watchAdForCoin();
      }
      expect(ads.rewardedShown, AdConfig.rewardedAdsPerDay);
      expect(m.coins, AdConfig.rewardedAdsPerDay * AdConfig.coinsPerAd);
      expect(m.canWatchAd, isFalse);
    });

    test('a skipped ad gives nothing; no network, no button', () async {
      final ads = FakeAds()..grantReward = false;
      final m = await newMoney(ads);
      expect(await m.watchAdForCoin(), isFalse);
      expect(m.coins, 0);
      ads.ready = false;
      expect(m.canWatchAd, isFalse);
    });
  });

  test('ad audience: teen treatment below 18, under consent age below 16', () {
    expect(Monetization.audienceFor(band13to15).teen, isTrue);
    expect(Monetization.audienceFor(band13to15).underAgeOfConsent, isTrue);
    expect(Monetization.audienceFor(band16to17).teen, isTrue);
    expect(Monetization.audienceFor(band16to17).underAgeOfConsent, isFalse);
    expect(Monetization.audienceFor(band18plus).teen, isFalse);
  });

  testWidgets('ads start after onboarding, not on the first frame', (
    tester,
  ) async {
    usePhone(tester);
    final ads = FakeAds();
    await tester.pumpWidget(await appWith(ads, {'band': '16-17'}));
    await tester.pump();
    expect(ads.starts, 0);
    await tester.pump(const Duration(seconds: 2));
    expect(ads.starts, 1);
    expect(ads.audience?.teen, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('age gate screen never starts ads', (tester) async {
    usePhone(tester);
    final ads = FakeAds();
    await tester.pumpWidget(await appWith(ads, {}));
    await tester.pump(const Duration(seconds: 3));
    expect(ads.starts, 0);
  });

  Future<void> openLevel(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tapVisible(tester, const ValueKey('difficulty-easy'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('out of coins: the coins dialog with an ad and the invite', (
    tester,
  ) async {
    usePhone(tester);
    final ads = FakeAds();
    await tester.pumpWidget(await appWith(ads, {'band': '13-15', 'coins': 0}));
    await openLevel(tester);

    await tester.tap(find.byKey(const ValueKey('hint')));
    await tester.pumpAndSettle();
    expect(find.text('Coins for hints'), findsOneWidget);
    expect(find.byKey(const ValueKey('invite')), findsOneWidget);
    expect(find.text('From friends today: 0/3'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('watch-ad')));
    await tester.pumpAndSettle();
    expect(ads.rewardedShown, 1);
    expect(find.text('Coins for hints'), findsNothing);

    // The coin buys the hint.
    await tester.tap(find.byKey(const ValueKey('hint')));
    await tester.pumpAndSettle();
    expect(find.text('Coins for hints'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('coins'), 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no ad network: no "watch an ad" button', (tester) async {
    usePhone(tester);
    final ads = FakeAds()..ready = false;
    await tester.pumpWidget(await appWith(ads, {'band': '13-15', 'coins': 0}));
    await openLevel(tester);
    await tester.tap(find.byKey(const ValueKey('hint')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('watch-ad')), findsNothing);
    expect(find.byKey(const ValueKey('invite')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a lost level offers no ad (rewarded ads are for coins only)', (
    tester,
  ) async {
    usePhone(tester);
    final ads = FakeAds();
    await tester.pumpWidget(await appWith(ads, {'band': '18+'}));
    await openLevel(tester);

    final p = generateLevel(band18plus, Difficulty.easy, 1);
    final cell = p.blanks.first;
    final wrong = [
      for (var i = 0; i < p.bank.length; i++)
        if (p.bank[i] != p.solution[cell]) i,
    ].first;
    for (var i = 0; i < band18plus[Difficulty.easy].mistakesAllowed!; i++) {
      await tester.tap(find.byKey(ValueKey('tile-$wrong')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('cell-${cell.row}-${cell.col}')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('result-primary')), findsOneWidget);
    expect(ads.rewardedShown, 0);
    await tester.pumpWidget(const SizedBox());
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/app_controller.dart';
import 'package:numcross/app/app_prefs.dart';
import 'package:numcross/i18n/languages.dart';
import 'package:numcross/i18n/locale_controller.dart';
import 'package:numcross/main.dart';
import 'package:numcross/monetization/ad_config.dart';
import 'package:numcross/monetization/ad_service.dart';
import 'package:numcross/monetization/monetization.dart';
import 'package:numcross/monetization/purchase_service.dart';
import 'package:numcross_engine/numcross_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class FakeAds implements AdService {
  AdAudience? audience;
  int starts = 0, interstitials = 0, rewardedShown = 0;
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
  Future<void> showInterstitial() async => interstitials++;

  @override
  Future<bool> privacyOptionsRequired() async => true;

  @override
  Future<void> showPrivacyOptions() async {}
}

class FakeStore implements PurchaseService {
  @override
  void Function()? onRemoveAdsOwned;

  @override
  Future<void> start() async {}

  @override
  bool get available => true;

  @override
  String? get removeAdsPrice => r'$2.99';

  @override
  Future<bool> buyRemoveAds() async {
    onRemoveAdsOwned?.call();
    return true;
  }

  @override
  Future<void> restore() async => onRemoveAdsOwned?.call();
}

Future<Monetization> newMoney(
  FakeAds ads, [
  Map<String, Object> v = const {},
]) async {
  mockStorage(v);
  return Monetization(
    await SharedPreferences.getInstance(),
    ads: ads,
    purchases: FakeStore(),
  );
}

Future<NumCrossApp> appWith(FakeAds ads, Map<String, Object> storage) async {
  mockStorage(storage);
  final prefs = await AppPrefs.load();
  return NumCrossApp(
    locale: LocaleController(initial: languageForCode('en')),
    app: AppController(
      prefs,
      monetization: Monetization(
        prefs.shared,
        ads: ads,
        purchases: FakeStore(),
      ),
    ),
  );
}

void main() {
  group('interstitial pacing', () {
    test('never in the first 3 levels, then at most every 3 levels', () async {
      final ads = FakeAds();
      final m = await newMoney(ads);
      final shownAfter = <int>[];
      for (var level = 1; level <= 12; level++) {
        await m.onLevelWon();
        final before = ads.interstitials;
        await m.maybeShowInterstitial();
        if (ads.interstitials > before) shownAfter.add(level);
      }
      expect(shownAfter, [4, 7, 10]);
    });

    test('pure rule', () {
      expect(
        interstitialDue(levelsWon: 3, levelsSinceLast: 3, adsRemoved: false),
        isFalse,
      );
      expect(
        interstitialDue(levelsWon: 4, levelsSinceLast: 2, adsRemoved: false),
        isFalse,
      );
      expect(
        interstitialDue(levelsWon: 4, levelsSinceLast: 4, adsRemoved: false),
        isTrue,
      );
      expect(
        interstitialDue(levelsWon: 9, levelsSinceLast: 9, adsRemoved: true),
        isFalse,
      );
    });

    test('remove ads stops interstitials and survives restarts', () async {
      final ads = FakeAds();
      final m = await newMoney(ads, {
        'stats/levelsWon': 10,
        'stats/sinceInterstitial': 5,
      });
      await m.purchases.buyRemoveAds();
      expect(m.adsRemoved, isTrue);
      await m.maybeShowInterstitial();
      expect(ads.interstitials, 0);
      final again = Monetization(
        await SharedPreferences.getInstance(),
        ads: ads,
      );
      expect(again.adsRemoved, isTrue);
    });
  });

  group('coins', () {
    test('start with 3, spend and earn', () async {
      final m = await newMoney(FakeAds());
      expect(m.coins, AdConfig.startingCoins);
      for (var i = 0; i < 3; i++) {
        expect(await m.spendCoin(), isTrue);
      }
      expect(await m.spendCoin(), isFalse);
      await m.addCoins(2);
      expect(m.coins, 2);
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
    await tester.tap(find.byKey(const ValueKey('difficulty-easy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('out of coins: hint via rewarded ad', (tester) async {
    usePhone(tester);
    final ads = FakeAds();
    await tester.pumpWidget(await appWith(ads, {'band': '13-15', 'coins': 0}));
    await openLevel(tester);

    await tester.tap(find.byKey(const ValueKey('hint')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('watch-ad')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(ads.rewardedShown, 1);
    final blank = generateLevel(band13to15, Difficulty.easy, 1).blanks.first;
    final cell = tester.widget(
      find.byKey(ValueKey('cell-${blank.row}-${blank.col}')),
    );
    expect(
      cell.runtimeType.toString(),
      'CellFace',
      reason: 'cell was filled by the hint',
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('out of coins and no ad ready: friendly message', (tester) async {
    usePhone(tester);
    final ads = FakeAds()..ready = false;
    await tester.pumpWidget(await appWith(ads, {'band': '13-15', 'coins': 0}));
    await openLevel(tester);
    await tester.tap(find.byKey(const ValueKey('hint')));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('lost level: extra life via rewarded ad, once', (tester) async {
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
    Future<void> mistake() async {
      await tester.tap(find.byKey(ValueKey('tile-$wrong')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('cell-${cell.row}-${cell.col}')));
      await tester.pump();
    }

    for (var i = 0; i < band18plus[Difficulty.easy].mistakesAllowed!; i++) {
      await mistake();
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('extra-life')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(ads.rewardedShown, 1);
    expect(
      find.byKey(const ValueKey('result-primary')),
      findsNothing,
      reason: 'playing again',
    );

    await mistake();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('result-primary')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('extra-life')),
      findsNothing,
      reason: 'only once',
    );
    await tester.pumpWidget(const SizedBox());
  });
}

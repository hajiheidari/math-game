// Solar Hijri (Jalali) calendar conversion, used for Persian dates.
// Port of the well-known jalaali-js algorithm (Borkowski / Birashk breaks).

class JalaliDate {
  final int year, month, day;
  const JalaliDate(this.year, this.month, this.day);

  factory JalaliDate.fromGregorian(DateTime g) =>
      _d2j(_g2d(g.year, g.month, g.day));

  DateTime toGregorian() {
    final (y, m, d) = _d2g(_j2d(year, month, day));
    return DateTime(y, m, d);
  }

  static bool isLeap(int year) => _jalCal(year).leap == 0;

  static int monthLength(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeap(year) ? 30 : 29;
  }

  @override
  bool operator ==(Object other) =>
      other is JalaliDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year/$month/$day';
}

const List<String> jalaliMonthNames = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', //
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
];

int _div(int a, int b) => a ~/ b; // truncates toward zero, like JS ~~(a/b)
int _mod(int a, int b) => a - _div(a, b) * b;

const _breaks = [
  -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, //
  1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
];

({int leap, int gy, int march}) _jalCal(int jy) {
  final gy = jy + 621;
  var leapJ = -14;
  var jp = _breaks[0];
  var jump = 0;
  if (jy < jp || jy >= _breaks.last) {
    throw RangeError('Jalali year $jy out of range');
  }
  for (var i = 1; i < _breaks.length; i++) {
    final jm = _breaks[i];
    jump = jm - jp;
    if (jy < jm) break;
    leapJ = leapJ + _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
    jp = jm;
  }
  var n = jy - jp;
  leapJ = leapJ + _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
  if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
  final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
  final march = 20 + leapJ - leapG;
  if (jump - n < 6) n = n - jump + _div(jump + 4, 33) * 33;
  var leap = _mod(_mod(n + 1, 33) - 1, 4);
  if (leap == -1) leap = 4;
  return (leap: leap, gy: gy, march: march);
}

int _g2d(int gy, int gm, int gd) {
  var d =
      _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
      _div(153 * _mod(gm + 9, 12) + 2, 5) +
      gd -
      34840408;
  d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
  return d;
}

(int, int, int) _d2g(int jdn) {
  var j = 4 * jdn + 139361631;
  j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
  final i = _div(_mod(j, 1461), 4) * 5 + 308;
  final gd = _div(_mod(i, 153), 5) + 1;
  final gm = _mod(_div(i, 153), 12) + 1;
  final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
  return (gy, gm, gd);
}

int _j2d(int jy, int jm, int jd) {
  final r = _jalCal(jy);
  return _g2d(r.gy, 3, r.march) +
      (jm - 1) * 31 -
      _div(jm, 7) * (jm - 7) +
      jd -
      1;
}

JalaliDate _d2j(int jdn) {
  final (gy, _, _) = _d2g(jdn);
  var jy = gy - 621;
  final r = _jalCal(jy);
  var k = jdn - _g2d(gy, 3, r.march);
  if (k >= 0) {
    if (k <= 185) return JalaliDate(jy, 1 + _div(k, 31), _mod(k, 31) + 1);
    k -= 186;
  } else {
    jy -= 1;
    k += 179;
    if (r.leap == 1) k += 1;
  }
  return JalaliDate(jy, 7 + _div(k, 30), _mod(k, 30) + 1);
}

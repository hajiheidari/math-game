/// Digit shapes. Numbers are always stored as ints; only display changes.
enum DigitSet {
  /// 0123456789
  western(0x30),

  /// ٠١٢٣٤٥٦٧٨٩ (Arabic-Indic, U+0660)
  arabicIndic(0x0660),

  /// ۰۱۲۳۴۵۶۷۸۹ (Extended Arabic-Indic, U+06F0; Persian and Urdu)
  persian(0x06F0);

  const DigitSet(this.zero);
  final int zero;
}

/// User setting for digits.
enum DigitMode {
  /// Follow the current language's default.
  auto,

  /// Always 0–9.
  western,

  /// The current language's own digits.
  native,
}

/// Replaces ASCII digits in [text] with the digits of [set].
String localizeDigits(String text, DigitSet set) {
  if (set == DigitSet.western) return text;
  final out = StringBuffer();
  for (final unit in text.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      out.writeCharCode(set.zero + unit - 0x30);
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

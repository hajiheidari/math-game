/// Arithmetic operators. Symbols are language-neutral and are shown as-is in
/// every locale.
enum Op {
  add('+'),
  sub('−'),
  mul('×'),
  div('÷');

  const Op(this.symbol);
  final String symbol;
}

/// `a op b` as a whole, non-negative number, or null when the result would be
/// negative or fractional (or a division by zero).
int? applyOp(Op op, int a, int b) {
  switch (op) {
    case Op.add:
      return a + b;
    case Op.sub:
      return a >= b ? a - b : null;
    case Op.mul:
      return a * b;
    case Op.div:
      return (b != 0 && a % b == 0) ? a ~/ b : null;
  }
}

/// True when `a op b = c` is arithmetically correct with whole, non-negative
/// numbers. This is what a player can check, independent of band rules, so
/// the uniqueness solver uses it.
bool equationHolds(Op op, int a, int b, int c) =>
    a >= 0 && b >= 0 && c >= 0 && applyOp(op, a, b) == c;

/// Solves `a op b = c` for the single missing value (exactly one of [a], [b],
/// [c] must be null). Returns null when no whole non-negative value works or
/// when the answer is not unique (e.g. `0 × ? = 0`).
int? solveMissing(Op op, int? a, int? b, int? c) {
  final missing = (a == null ? 1 : 0) + (b == null ? 1 : 0) + (c == null ? 1 : 0);
  assert(missing == 1);
  int? v;
  if (c == null) {
    v = applyOp(op, a!, b!);
  } else if (a == null) {
    final bb = b!;
    switch (op) {
      case Op.add:
        v = c - bb;
      case Op.sub:
        v = c + bb;
      case Op.mul:
        v = (bb != 0 && c % bb == 0) ? c ~/ bb : null;
      case Op.div:
        v = bb != 0 ? c * bb : null;
    }
    if (v != null && !equationHolds(op, v, bb, c)) v = null;
  } else {
    final aa = a;
    switch (op) {
      case Op.add:
        v = c - aa;
      case Op.sub:
        v = aa - c;
      case Op.mul:
        v = (aa != 0 && c % aa == 0) ? c ~/ aa : null;
      case Op.div:
        v = (c != 0 && aa % c == 0) ? aa ~/ c : null;
    }
    if (v != null && !equationHolds(op, aa, v, c)) v = null;
  }
  return (v != null && v >= 0) ? v : null;
}

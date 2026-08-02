import 'package:intl/intl.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _compact = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
final _pct = NumberFormat('+0.00%;-0.00%');
final _num = NumberFormat('#,##0.00');

String money(double v) => _money.format(v);
String money0(double v) => _compact.format(v);
String pctFrac(double v) => _pct.format(v); // expects fraction
String pctPoints(double v) {
  final sign = v >= 0 ? '+' : '';
  return '$sign${v.toStringAsFixed(2)}%';
}

String qtyFmt(double v) => v >= 1 ? _num.format(v) : v.toStringAsFixed(5);
String priceFmt(double v) => v >= 1000 ? v.toStringAsFixed(1) : v.toStringAsFixed(4);

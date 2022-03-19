import 'package:intl/intl.dart';

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

enum DialogAction {
  cancel,
  discard,
  disagree,
  agree,
}

extension MoneyFormatting on double? {
  String toMoney() {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(this);
  }
}

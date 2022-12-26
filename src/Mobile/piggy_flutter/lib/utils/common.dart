import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
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

IconData getIconOrDefault(String iconData) {
  IconData? icon =
      deserializeIcon(Map<String, dynamic>.from(json.decode(iconData)));

  if (icon == null) {
    return Icons.question_mark;
  }

  return icon;
}

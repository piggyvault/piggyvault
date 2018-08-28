import 'package:flutter/widgets.dart';

class AccountFormModel {
  final String id;
  String name;
  int currencyId, accountTypeId;

  AccountFormModel(
      {@required this.id, this.name, this.currencyId, this.accountTypeId});

  @override
  String toString() {
    return 'AccountFormModel name $name id $id currencyId $currencyId accountTypeId $accountTypeId';
  }
}

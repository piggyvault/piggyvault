import 'package:flutter/widgets.dart';

class AccountFormModel {
  AccountFormModel(
      {@required this.id, this.name, this.currencyId, this.accountTypeId});

  AccountFormModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        currencyId = json['currencyId'],
        accountTypeId = json['accountTypeId'];

  final String id;
  String name;
  int currencyId, accountTypeId;

  @override
  String toString() {
    return 'AccountFormModel name $name id $id currencyId $currencyId accountTypeId $accountTypeId';
  }
}

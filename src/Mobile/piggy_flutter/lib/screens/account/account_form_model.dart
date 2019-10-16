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

  AccountFormModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        currencyId = json['currencyId'],
        accountTypeId = json['accountTypeId'];
}

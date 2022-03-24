class AccountFormModel {
  AccountFormModel(
      {required this.id,
      required this.isArchived,
      this.name,
      this.currencyId,
      this.accountTypeId});

  AccountFormModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        currencyId = json['currencyId'],
        accountTypeId = json['accountTypeId'],
        isArchived = json['isArchived'];

  final String? id;
  String? name;
  int? currencyId, accountTypeId;
  bool isArchived;

  @override
  String toString() {
    return 'AccountFormModel name $name id $id currencyId $currencyId accountTypeId $accountTypeId';
  }
}

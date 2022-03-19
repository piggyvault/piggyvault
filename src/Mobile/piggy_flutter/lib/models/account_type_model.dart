class AccountType {
  final String? name;
  final int? id;

  AccountType(this.name, this.id);

  AccountType.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}

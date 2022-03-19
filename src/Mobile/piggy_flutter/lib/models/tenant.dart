class Tenant {
  Tenant({this.id, this.name, this.tenancyName});

  Tenant.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        tenancyName = json['tenancyName'];

  final String? tenancyName, name;
  final int? id;
}

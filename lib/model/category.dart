class Category {
  final String name;
  final int id;
//  String icon;

  Category(this.id, this.name);

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}

import 'package:flutter/material.dart';

class Category {
  String name;
  final int id;
  final String icon;

  Category({@required this.id, this.name, this.icon});

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        icon = json['icon'];

  @override
  String toString() {
    return 'category name is $name';
  }
}

import 'package:flutter/material.dart';

class Category {
  Category({required this.id, this.name, this.icon});

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        icon = json['icon'];

  String? name;
  final String? id;
  String? icon;

  @override
  String toString() {
    return 'category is $name';
  }
}

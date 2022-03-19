import 'package:flutter/material.dart';

class UserSettings {
  final String? defaultCurrencyCode;

  UserSettings({required this.defaultCurrencyCode});

  UserSettings.fromJson(Map<String, dynamic> json)
      : defaultCurrencyCode = json['defaultCurrencyCode'];
}

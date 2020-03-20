import 'package:flutter/material.dart';

class UIData {
  //routes
  static const String introViewsRoute = "/intro_views";
  static const String loginRoute = "/login";
  static const String dashboardRoute = "/dashboard";
  static const String categoriesRoute = "/categories";

  //strings
  static const String appName = "Piggy";
  static const String appVersion = "0.13.1";
  static const String authToken = "authToken";
  static const String firstAccess = "firstAccess";
  static const String tenantId = "tenantId";
  static const String transaction_type_expense = "Expense";
  static const String transaction_type_income = "Income";
  static const String transaction_type_transfer = "Transfer";
  static const String adjust_balance = "Adjust Balance";
  static const String account_edit = "account_edit";
  static const String category_edit = 'category_edit';
  static const String edit = "Edit";
  static const String reports = 'Reports';
  static const String settings = 'Settings';

  //images
  static const String imageDir = "assets/images";
  static const String loginImage = "$imageDir/login.jpg";

  //login
  static const String login = "Login";

  //generic
  static const String error = "Error";
  static const String success = "Success";
  static const String ok = "OK";
  static const String forgot_password = "Forgot Password?";
  static const String something_went_wrong = "Something went wrong";
  static const String coming_soon = "Coming Soon";
  static const String category_update_success_message = "Category updated";

  static const MaterialColor ui_kit_color = Colors.grey;
}

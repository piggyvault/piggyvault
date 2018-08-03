import 'package:piggy_flutter/bloc/account_bloc.dart';

class TransactionEditDto {
  String id, description, accountId, transactionTime;
  double amount;
  int categoryId;
  AccountBloc accountBloc;

  TransactionEditDto(
      {this.id,
      this.description,
      this.accountId,
      this.transactionTime,
      this.amount,
      this.categoryId,
      this.accountBloc});

  TransactionEditDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        description = json['description'],
        amount = json['amount'],
        categoryId = json['categoryId'],
        transactionTime = json['transactionTime'],
        accountId = json['accountId'];
}

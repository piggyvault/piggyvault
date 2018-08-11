import 'dart:async';

import 'package:intl/intl.dart';
import 'package:piggy_flutter/model/account_detail_state.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

class AccountDetailBloc {
  final Stream<AccountDetailState> state;

  factory AccountDetailBloc(
      {TransactionService transactionService, String accountId}) {
    final state = _getTransactions(
        accountId: accountId,
        pageIndex: 0,
        transactionService: transactionService);

    return AccountDetailBloc._(state);
  }

  AccountDetailBloc._(this.state);

  void dispose() {}

  static Stream<AccountDetailState> _getTransactions(
      {String accountId,
      int pageIndex,
      TransactionService transactionService}) async* {
    var startMonth = DateTime.now().month - pageIndex;
    var startYear = DateTime.now().year;

    if (startMonth < 0) {
      startMonth += 11;
      startYear -= 1;
    }

    var endMonth = startMonth + 1;
    var endYear = startYear;
    if (endMonth > 11) {
      endMonth -= 11;
      endYear += 1;
    }

    final startDate = DateTime(startYear, startMonth, 1);
    final endDate =
        DateTime(endYear, endMonth, 1).add(Duration(milliseconds: -1));

    final DateFormat formatter = DateFormat("MMM, ''yy");

    final title = formatter.format(startDate);

    yield AccountDetailLoading(title);

    final input = GetTransactionsInput(
        type: 'account',
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        groupBy: TransactionsGroupBy.Date);

    try {
      final result = await transactionService.getTransactions(input);

      if (result.isEmpty) {
        yield AccountDetailEmpty(title);
      } else {
        yield AccountDetailPopulated(result: result, title: title);
      }
    } catch (e) {
      yield AccountDetailError(title);
    }
  }
}

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:piggy_flutter/model/account_detail_state.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class AccountDetailBloc {
  final String accountId;
  int pageIndex = 0;

  final TransactionService _transactionService = TransactionService();

  final _onPageChanged = PublishSubject<int>();
  final _state = BehaviorSubject<AccountDetailState>(
      seedValue: AccountDetailLoading('This Month'));

  Function(int) get onPageChanged => _onPageChanged.sink.add;

  Stream<AccountDetailState> get state => _state.stream;

  AccountDetailBloc({this.accountId}) {
    _onPageChanged.listen(_getTransactions);
  }

  void dispose() {
    _onPageChanged.close();
    _state.close();
  }

  Future<Null> _getTransactions(
    int delta,
  ) async {
    pageIndex += delta;

    print('######### AccountDetailBloc _getTransactions $pageIndex');
    var startMonth = DateTime.now().month + pageIndex;
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

    _state.add(AccountDetailLoading(title));

    final input = GetTransactionsInput(
        type: 'account',
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        groupBy: TransactionsGroupBy.Date);

    try {
      final result = await _transactionService.getTransactions(input);

      if (result.isEmpty) {
        _state.add(AccountDetailEmpty(title));
      } else {
        _state.add(AccountDetailPopulated(result: result, title: title));
      }
    } catch (e) {
      _state.add(AccountDetailError(title));
    }
  }
}

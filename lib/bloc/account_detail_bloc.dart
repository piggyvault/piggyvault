import 'dart:async';

import 'package:intl/intl.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/account_detail_state.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/account_service.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class AccountDetailBloc {
  final String accountId;
  int _pageIndex = 0;
  String _title = 'This Month',
      _nextPageTitle = 'Future',
      _previousPageTitle = 'Last Month';

  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();

  final _account = BehaviorSubject<Account>();
  final _onPageChanged = PublishSubject<int>();
  final _transactionsState = BehaviorSubject<AccountDetailState>();
  final _refreshAccount = PublishSubject<bool>();

  Function(int) get onPageChanged => _onPageChanged.sink.add;
  Function(bool) get refreshAccount => _refreshAccount.sink.add;
  Function(Account) get changeAccount => _account.sink.add;

  Stream<Account> get account => _account.stream;
  Stream<AccountDetailState> get transactionsState => _transactionsState.stream;
  Stream<AccountDetailState> get state =>
      Observable.combineLatest2(account, transactionsState,
          (Account accountData, AccountDetailState transactionsStateData) {
        transactionsStateData.account = accountData;
        transactionsStateData.title = _title;
        transactionsStateData.nextPageTitle = _nextPageTitle;
        transactionsStateData.previousPageTitle = _previousPageTitle;
        return transactionsStateData;
      }).asBroadcastStream();

  AccountDetailBloc({this.accountId}) {
    _onPageChanged.listen(_getTransactions);
    _refreshAccount.listen(_getAccountDetails);
  }

  void dispose() {
    _onPageChanged.close();
    _transactionsState.close();
    _refreshAccount.close();
    _account.close();
  }

  Future<Null> _getAccountDetails(bool done) async {
    print('######### AccountDetailBloc _getAccountDetails');
    final result = await _accountService.getAccountDetails(accountId);
    _account.add(result);
  }

  Future<Null> _getTransactions(
    int delta,
  ) async {
    _pageIndex += delta;

    print('######### AccountDetailBloc _getTransactions $_pageIndex');
    var startMonth = DateTime.now().month + _pageIndex;
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

    _title = formatter.format(startDate);
    _nextPageTitle = formatter.format(DateTime(endYear, endMonth, 1));
    _previousPageTitle =
        formatter.format(DateTime(startYear, startMonth - 1, 1));

    _transactionsState.add(AccountDetailLoading());

    final input = GetTransactionsInput(
        type: 'account',
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        groupBy: TransactionsGroupBy.Date);

    try {
      final result = await _transactionService.getTransactions(input);

      if (result.isEmpty) {
        _transactionsState.add(AccountDetailEmpty());
      } else {
        _transactionsState.add(AccountDetailPopulated(result));
      }
    } catch (e) {
      _transactionsState.add(AccountDetailError());
    }
  }
}

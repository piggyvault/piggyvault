import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, AccountFormState> {
  AccountFormBloc(
      {@required this.accountsBloc, @required this.accountRepository})
      : assert(accountRepository != null),
        super(InitialAccountFormState());

  final AccountRepository accountRepository;
  final AccountsBloc accountsBloc;

  @override
  Stream<AccountFormState> mapEventToState(
    AccountFormEvent event,
  ) async* {
    if (event is AccountFormLoad) {
      if (event.accountId != null) {
        yield AccountFormLoading();
        try {
          final AccountFormModel account =
              await accountRepository.getAccountForEdit(event.accountId);
          yield AccountFormLoaded(account: account);
        } catch (e) {
          yield AccountFormError();
        }
      } else {
        yield AccountFormLoaded(account: AccountFormModel(id: event.accountId));
      }
    }

    if (event is AccountFormSave) {
      yield AccountFormSaving();
      try {
        await accountRepository.createOrUpdateAccount(event.account);
        yield AccountFormSaved();
        accountsBloc.add(LoadAccounts());
      } catch (error) {
        yield AccountFormError();
      }
    }
  }
}

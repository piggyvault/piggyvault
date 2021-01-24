import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:piggy_flutter/blocs/account_form/bloc.dart';
import 'package:piggy_flutter/blocs/account_types/bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/currencies/bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/currency.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({Key key, this.title, this.account})
      : super(key: key);

  final String title;
  final Account account;

  @override
  _AccountFormScreenState createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  AccountFormModel accountFormModel;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _autoValidate = false;
  final bool _formWasEdited = false;

  AccountFormBloc accountFormBloc;
  TextEditingController _nameFieldController;
  CurrenciesBloc currenciesBloc;
  AccountTypesBloc accountTypesBloc;

  @override
  void initState() {
    super.initState();
    accountFormBloc = AccountFormBloc(
        accountsBloc: BlocProvider.of<AccountsBloc>(context),
        accountRepository: RepositoryProvider.of<AccountRepository>(context));

    accountFormModel = AccountFormModel(id: widget.account?.id);
    accountFormBloc.add(AccountFormLoad(accountId: widget.account?.id));

    if (widget.account == null) {
      _nameFieldController = TextEditingController();
    } else {
      _nameFieldController = TextEditingController(text: widget.account.name);
    }

    currenciesBloc = CurrenciesBloc(
        accountRepository: RepositoryProvider.of<AccountRepository>(context));
    currenciesBloc.add(LoadCurrencies());

    accountTypesBloc = AccountTypesBloc(
        accountRepository: RepositoryProvider.of<AccountRepository>(context));
    accountTypesBloc.add(AccountTypesLoad());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          submitButton(theme),
        ],
      ),
      body: BlocListener<AccountFormBloc, AccountFormState>(
        cubit: accountFormBloc,
        listener: (BuildContext context, AccountFormState state) {
          if (state is AccountFormSaving) {
            showProgress(context);
          }

          if (state is AccountFormSaved) {
            hideProgress(context);
            showSuccess(
                context: context,
                message: UIData.success,
                icon: MaterialCommunityIcons.check);
          }
        },
        child: BlocBuilder<AccountFormBloc, AccountFormState>(
          cubit: accountFormBloc,
          builder: (BuildContext context, AccountFormState state) {
            if (state is AccountFormLoaded) {
              accountFormModel = state.account;
            }

            return DropdownButtonHideUnderline(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  onWillPop: _onWillPop,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      _nameField(theme),
                      BlocBuilder<CurrenciesBloc, CurrenciesState>(
                          cubit: currenciesBloc,
                          builder: (BuildContext context,
                              CurrenciesState currenciesState) {
                            if (currenciesState is CurrenciesLoaded) {
                              return InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Currency',
                                    hintText: 'Choose a currency',
                                  ),
                                  isEmpty: accountFormModel.currencyId == null,
                                  child: DropdownButton<int>(
                                    value: accountFormModel.currencyId,
                                    onChanged: (int value) {
                                      setState(() {
                                        accountFormModel.currencyId = value;
                                      });
                                    },
                                    items: currenciesState.currencies
                                        .map((Currency currency) {
                                      return DropdownMenuItem<int>(
                                        value: currency.id,
                                        child: Text(currency.name),
                                      );
                                    }).toList(),
                                  ));
                            } else {
                              return const LinearProgressIndicator();
                            }
                          }),
                      BlocBuilder<AccountTypesBloc, AccountTypesState>(
                        cubit: accountTypesBloc,
                        builder: (BuildContext context,
                            AccountTypesState accountTypestate) {
                          if (accountTypestate is AccountTypesLoaded) {
                            return InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                hintText: 'Choose an account type',
                              ),
                              isEmpty: accountFormModel.accountTypeId == null,
                              child: DropdownButton<int>(
                                value: accountFormModel.accountTypeId,
                                onChanged: (int value) {
                                  setState(() {
                                    accountFormModel.accountTypeId = value;
                                  });
                                },
                                items: accountTypestate.accountTypes
                                    .map((AccountType type) {
                                  return DropdownMenuItem<int>(
                                    value: type.id,
                                    child: Text(type.name),
                                  );
                                }).toList(),
                              ),
                            );
                          } else {
                            return const LinearProgressIndicator();
                          }
                        },
                      ),
                      const SizedBox(height: 24.0),
                      Text('* all fields are mandatory',
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) {
      return true;
    }

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard unsaved changes?', style: dialogTextStyle),
              actions: <Widget>[
                FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                FlatButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        ) ??
        false;
  }

  Widget _nameField(ThemeData theme) {
    return PrimaryColorOverride(
      child: TextField(
        enabled: true,
        controller: _nameFieldController,
        decoration: const InputDecoration(
          labelText: 'Account name',
          border: OutlineInputBorder(),
          // errorText: snapshot.error
        ),
        style: theme.textTheme.headline,
      ),
    );
  }

  Widget submitButton(ThemeData theme) {
    return FlatButton(
      child: Text('SAVE', style: theme.textTheme.button),
      onPressed: () {
        onSave();
      },
    );
  }

  void onSave() {
    accountFormModel.name = _nameFieldController.text;

    if (_isValidAccount()) {
      accountFormBloc.add(AccountFormSave(account: accountFormModel));
    }
  }

  bool _isValidAccount() {
    if (accountFormModel.currencyId == null) {
      const String error = 'Currency is required.';
      showInSnackBar(error);
      return false;
    } else if (accountFormModel.accountTypeId == null) {
      const String error = 'Account type is required.';
      showInSnackBar(error);
      return false;
    }
    return true;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/models/currency.dart';
import 'package:piggy_flutter/screens/account/account_form_bloc.dart';
import 'package:piggy_flutter/screens/account/account_type_model.dart';
import 'package:piggy_flutter/utils/api_subscription.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class AccountFormScreen extends StatefulWidget {
  final String title;
  final Account account;

  const AccountFormScreen({Key key, this.title, this.account})
      : super(key: key);

  @override
  _AccountFormScreenState createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _formWasEdited = false;

  StreamSubscription<ApiRequest> _apiStreamSubscription;
  AccountFormBloc _bloc;
  TextEditingController _nameFieldController;

  @override
  void initState() {
    super.initState();
    _bloc = AccountFormBloc(widget.account?.id);

    if (widget.account == null) {
      _nameFieldController = TextEditingController();
    } else {
      _nameFieldController = TextEditingController(text: widget.account.name);
    }

    _apiStreamSubscription = apiSubscription(
        stream: _bloc.state, context: context, key: _scaffoldKey);
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
      body: DropdownButtonHideUnderline(
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
                _currencyField(),
                _typeField(),
                const SizedBox(height: 24.0),
                Text('* all fields are mandatory',
                    style: Theme.of(context).textTheme.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dispose() {
    _apiStreamSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) return true;

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
    return StreamBuilder(
      stream: _bloc.name,
      builder: (context, snapshot) {
        return PrimaryColorOverride(
          child: TextField(
            enabled: true,
            controller: _nameFieldController,
            decoration: InputDecoration(
                labelText: 'Account name',
                border: OutlineInputBorder(),
                errorText: snapshot.error),
            style: theme.textTheme.headline,
            onChanged: _bloc.changeName,
          ),
        );
      },
    );
  }

  Widget _currencyField() => StreamBuilder<List<Currency>>(
      stream: _bloc.currencies,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
          return InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Currency',
                hintText: 'Choose a currency',
              ),
              isEmpty: _bloc.account.currencyId == null,
              child: DropdownButton<int>(
                value: _bloc.account.currencyId,
                onChanged: (int value) {
                  setState(() {
                    _bloc.account.currencyId = value;
                  });
                },
                items: snapshot.data.map((Currency currency) {
                  return DropdownMenuItem<int>(
                    value: currency.id,
                    child: Text(currency.name),
                  );
                }).toList(),
              ));
        } else {
          return LinearProgressIndicator();
        }
      });

  Widget _typeField() => StreamBuilder<List<AccountType>>(
      stream: _bloc.types,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Type',
              hintText: 'Choose an account type',
            ),
            isEmpty: _bloc.account.accountTypeId == null,
            child: DropdownButton<int>(
              value: _bloc.account.accountTypeId,
              onChanged: (int value) {
                setState(() {
                  _bloc.account.accountTypeId = value;
                });
              },
              items: snapshot.data.map((AccountType type) {
                return DropdownMenuItem<int>(
                  value: type.id,
                  child: Text(type.name),
                );
              }).toList(),
            ),
          );
        } else {
          return LinearProgressIndicator();
        }
      });

  Widget submitButton(ThemeData theme) {
    return StreamBuilder(
      stream: _bloc.name,
      builder: (context, snapshot) {
        return FlatButton(
          child: Text('SAVE', style: theme.textTheme.button),
          onPressed: snapshot.hasData ? onSave : null,
        );
      },
    );
  }

  void onSave() {
    if (_isValidAccount()) {
      _bloc.submit();
    }
  }

  bool _isValidAccount() {
    if (_bloc.account.currencyId == null) {
      String error = 'Currency is required.';
      showInSnackBar(error);
      return false;
    } else if (_bloc.account.accountTypeId == null) {
      String error = 'Account type is required.';
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

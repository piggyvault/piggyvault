import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/bloc/category_bloc.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

// This is based on
// https://material.google.com/components/dialogs.html#dialogs-full-screen-dialogs

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = new DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new DefaultTextStyle(
        style: theme.textTheme.subhead,
        child: new Row(children: <Widget>[
          new Expanded(
              child: new Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          bottom: new BorderSide(color: theme.dividerColor))),
                  child: new InkWell(
                      onTap: () {
                        showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: date.subtract(const Duration(days: 30)),
                            lastDate:
                                date.add(const Duration(days: 30))).then<Null>(
                            (DateTime value) {
                          if (value != null)
                            onChanged(new DateTime(value.year, value.month,
                                value.day, time.hour, time.minute));
                        });
                      },
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                                new DateFormat('EEE, MMM d yyyy').format(date)),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.black54),
                          ])))),
        ]));
  }
}

class TransactionFormPage extends StatefulWidget {
  @override
  TransactionFormPageState createState() => new TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  final CategoryBloc categoryBloc = new CategoryBloc();
  final AccountBloc accountBloc = new AccountBloc();
  final TransactionBloc transactionBloc = new TransactionBloc();

  DateTime _transactionTime = new DateTime.now();
  String _transactionType = 'Expense';
  double _amount;
  int _categoryId;
  String _description, _accountId;
  bool _saveNeeded = false;

  Future<bool> _onWillPop() async {
//    _saveNeeded = _hasLocation || _hasName || _saveNeeded;
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              content: new Text('Discard new event?', style: dialogTextStyle),
              actions: <Widget>[
                new FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                new FlatButton(
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

  Widget buildCategoryList() => new StreamBuilder<List<Category>>(
      stream: categoryBloc.categories,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return new DropdownButton<int>(
            value: _categoryId,
            onChanged: (int newValue) {
              setState(() {
                _categoryId = newValue;
              });
            },
            items: snapshot.data.map((Category category) {
              return new DropdownMenuItem<int>(
                value: category.id,
                child: new Text(category.name),
              );
            }).toList(),
          );
        } else {
          return new CircularProgressIndicator();
        }
      });

  Widget buildAccountList() => new StreamBuilder<List<Account>>(
      stream: accountBloc.userAccounts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return new DropdownButton<String>(
            value: _accountId,
            onChanged: (String newValue) {
              setState(() {
                _accountId = newValue;
              });
            },
            items: snapshot.data.map((Account account) {
              return new DropdownMenuItem<String>(
                value: account.id,
                child: new Text(account.name),
              );
            }).toList(),
          );
        } else {
          return new CircularProgressIndicator();
        }
      });

  @override
  void initState() {
    super.initState();
    accountBloc.refreshAccounts.add(true);
  }

  void onSave() {
    transactionBloc.saveTransaction.add(new SaveTransactionInput(
        null,
        _description,
        _accountId,
        _transactionTime.toString(),
        _amount,
        _categoryId));

    Navigator.pop(context, DismissDialogAction.save);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(title: new Text('New Transaction'), actions: <Widget>[
        new FlatButton(
            child: new Text('SAVE',
                style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () {
              onSave();
            })
      ]),
      body: new Form(
          onWillPop: _onWillPop,
          child: new ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                new ListTile(
                  title: const Text('Type'),
                  trailing: new DropdownButton<String>(
                    value: _transactionType,
                    onChanged: (String newValue) {
                      setState(() {
                        _transactionType = newValue;
                      });
                    },
                    items: <String>['Expense', 'Income', 'Transfer']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
                ),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: new TextField(
                        decoration: const InputDecoration(
                            labelText: 'Amount', filled: true),
                        style: theme.textTheme.subhead,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onChanged: (String value) {
                          setState(() {
                            _amount = double.parse(value);
                          });
                        })),
                new ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  title: const Text('Category'),
                  trailing: buildCategoryList(),
                ),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.topLeft,
                    child: new TextField(
                        decoration: const InputDecoration(
                            labelText: 'Description', filled: true),
//                        style: theme.textTheme.body1,
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        onChanged: (String value) {
                          setState(() {
//                            _hasName = value.isNotEmpty;
//                            if (_hasName) {
                            _description = value;
//                            }
                          });
                        })),
                new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text('From', style: theme.textTheme.caption),
                      new DateTimeItem(
                          dateTime: _transactionTime,
                          onChanged: (DateTime value) {
                            setState(() {
                              _transactionTime = value;
                              _saveNeeded = true;
                            });
                          })
                    ]),
                new ListTile(
                  title: const Text('Account'),
                  trailing: buildAccountList(),
                ),
              ].map((Widget child) {
                return new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 96.0,
                    child: child);
              }).toList())),
    );
  }
}

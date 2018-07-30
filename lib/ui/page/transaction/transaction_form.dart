import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/bloc/category_bloc.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/providers/category_provider.dart';
import 'package:piggy_flutter/providers/transaction_provider.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key key,
      this.child,
      this.labelText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker(
      {Key key,
      this.labelText,
      this.selectedDate,
      this.selectedTime,
      this.selectDate,
      this.selectTime})
      : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101));
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDropdown(
            labelText: labelText,
            valueText: new DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ),
        const SizedBox(width: 12.0),
        new Expanded(
          flex: 3,
          child: new _InputDropdown(
            valueText: selectedTime.format(context),
            valueStyle: valueStyle,
            onPressed: () {
              _selectTime(context);
            },
          ),
        ),
      ],
    );
  }
}

class TransactionFormPage extends StatefulWidget {
  @override
  TransactionFormPageState createState() => new TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  final TextEditingController _descriptionFieldController =
      new TextEditingController();
  final TextEditingController _amountFieldController =
      new TextEditingController();

  DateTime _transactionDate = new DateTime.now();
  TimeOfDay _transactionTime;

  String _transactionType = 'Expense';

  int _categoryId;
  String _accountId;
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

  Widget buildCategoryList(CategoryBloc categoryBloc) =>
      new StreamBuilder<List<Category>>(
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

  Widget buildAccountList(AccountBloc accountBloc) =>
      new StreamBuilder<List<Account>>(
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

  void onSave(TransactionBloc transactionBloc, AccountBloc accountBloc) {
    transactionBloc.saveTransaction.add(new SaveTransactionInput(
        null,
        _descriptionFieldController.text,
        _accountId,
        new DateTime(
                _transactionDate.year,
                _transactionDate.month,
                _transactionDate.day,
                _transactionTime.hour,
                _transactionTime.minute)
            .toString(),
        double.parse(_amountFieldController.text),
        _categoryId,
        accountBloc));

    Navigator.pop(context, DismissDialogAction.save);
  }

  @override
  void initState() {
    super.initState();
    _transactionTime =
        TimeOfDay(hour: _transactionDate.hour, minute: _transactionDate.minute);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CategoryBloc categoryBloc = CategoryProvider.of(context);
    final AccountBloc accountBloc = AccountProvider.of(context);
    final TransactionBloc transactionBloc = TransactionProvider.of(context);

    return new Scaffold(
      appBar: new AppBar(title: new Text('New Transaction'), actions: <Widget>[
        new FlatButton(
            child: new Text('SAVE',
                style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () {
              onSave(transactionBloc, accountBloc);
            })
      ]),
      body: new DropdownButtonHideUnderline(
        child: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
            onWillPop: _onWillPop,
            child: new ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                new InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Transaction Type',
                      hintText: 'Choose the type of transaction',
                    ),
                    isEmpty: _transactionType == null,
                    child: new DropdownButton<String>(
                      value: _transactionType,
                      isDense: true,
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
                    )),
                const SizedBox(height: 24.0),
                new TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Amount',
                      prefixText: '\$',
                      suffixText: 'USD',
                      suffixStyle: const TextStyle(color: Colors.green)),
                  maxLines: 1,
                  controller: _amountFieldController,
                ),
//                        const SizedBox(height: 24.0),
                new InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Choose a category',
                  ),
                  isEmpty: _categoryId == null,
                  child: buildCategoryList(categoryBloc),
                ),
                const SizedBox(height: 24.0),
                new TextFormField(
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Tell us about the transaction',
//                            helperText: 'Keep it short but meaningful',
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  controller: _descriptionFieldController,
                ),
                const SizedBox(height: 24.0),
                new _DateTimePicker(
                  labelText: 'To',
                  selectedDate: _transactionDate,
                  selectedTime: _transactionTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _transactionDate = date;
                    });
                  },
                  selectTime: (TimeOfDay time) {
                    setState(() {
                      _transactionTime = time;
                    });
                  },
                ),
//                        const SizedBox(height: 24.0),
                new InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    hintText: 'Choose an account',
                  ),
                  isEmpty: _accountId == null,
                  child: buildAccountList(accountBloc),
                ),
                const SizedBox(height: 24.0),
                new Text(
                    '* all fields are mandatory',
                    style: Theme.of(context).textTheme.caption
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

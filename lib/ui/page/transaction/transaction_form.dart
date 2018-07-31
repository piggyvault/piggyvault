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
import 'package:piggy_flutter/utils/uidata.dart';

// TODO: BLoC

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
  final TextEditingController _convertedAmountFieldController =
      new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  bool _formWasEdited = false;
  bool _showTransferToAmount = false;

  String _categoryErrorText;
  String _accountErrorText;

  DateTime _transactionDate = new DateTime.now();
  TimeOfDay _transactionTime;

  String _transactionType = UIData.transaction_type_expense;

  int _categoryId;
  String _accountId, _toAccountId;

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              content:
                  new Text('Discard unsaved changes?', style: dialogTextStyle),
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
              return new LinearProgressIndicator();
            }
          });

  Widget buildAccountList(AccountBloc accountBloc, [bool isToAccount = false]) {
    return new StreamBuilder<List<Account>>(
        stream: accountBloc.userAccounts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new DropdownButton<String>(
              value: isToAccount ? _toAccountId : _accountId,
              onChanged: (String newValue) {
                setState(() {
                  isToAccount ? _toAccountId = newValue : _accountId = newValue;
                });
                manageTransferView(accountBloc);
              },
              items: snapshot.data.map((Account account) {
                return new DropdownMenuItem<String>(
                  value: account.id,
                  child: new Text(account.name),
                );
              }).toList(),
            );
          } else {
            return new LinearProgressIndicator();
          }
        });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      backgroundColor: Colors.red,
    ));
  }

  void onSave(TransactionBloc transactionBloc, AccountBloc accountBloc) {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors before submitting.');
    } else {
      if (!_isValidAccount() || !_isValidCategory()) {
        return;
      }

      if (_transactionType == UIData.transaction_type_transfer) {
        if (!_isValidToAccount()) {
          return;
        } else {
          double amount = double.parse(_amountFieldController.text);
          double toAmount;

          if (_showTransferToAmount) {
            toAmount = double.parse(_convertedAmountFieldController.text);
          } else {
            toAmount = amount;
          }

          transactionBloc.doTransfer.add(new TransferInput(
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
              amount,
              _categoryId,
              accountBloc,
              toAmount,
              _toAccountId));

          Navigator.pop(context, DismissDialogAction.save);
        }
      } else {
        double amount = double.parse(_amountFieldController.text);
        if (_transactionType == UIData.transaction_type_expense && amount > 0) {
          amount *= -1;
        }
        if (_transactionType == UIData.transaction_type_income && amount < 0) {
          amount *= -1;
        }

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
            amount,
            _categoryId,
            accountBloc));

        Navigator.pop(context, DismissDialogAction.save);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _transactionTime =
        TimeOfDay(hour: _transactionDate.hour, minute: _transactionDate.minute);
  }

  void manageTransferView(AccountBloc accountBloc) {
    if (_transactionType == UIData.transaction_type_transfer &&
        _accountId != null &&
        _toAccountId != null) {
      //check whether both accounts currency is same or not
      Account fromAccount =
          accountBloc.userAccountList.firstWhere((x) => x.id == _accountId);
      Account toAccount =
          accountBloc.userAccountList.firstWhere((x) => x.id == _toAccountId);

      if (fromAccount.currencyCode == toAccount.currencyCode) {
        setState(() {
          _showTransferToAmount = false;
        });
      } else {
        // if not same, show converted amount field
        _showTransferToAmount = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CategoryBloc categoryBloc = CategoryProvider.of(context);
    final AccountBloc accountBloc = AccountProvider.of(context);
    final TransactionBloc transactionBloc = TransactionProvider.of(context);

    return new Scaffold(
      key: _scaffoldKey,
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
            key: _formKey,
            autovalidate: _autovalidate,
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
                          manageTransferView(accountBloc);
                        });
                      },
                      items: <String>[
                        UIData.transaction_type_expense,
                        UIData.transaction_type_income,
                        UIData.transaction_type_transfer
                      ].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    )),
                new InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    hintText: 'Choose an account',
                  ),
                  isEmpty: _accountId == null,
                  child: buildAccountList(accountBloc),
                ),
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
                  validator: _validateAmount,
                ),
                new InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Choose a category',
                    errorText: _categoryErrorText,
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
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  controller: _descriptionFieldController,
                  validator: _validateDescription,
                ),
//                const SizedBox(height: 24.0),
                new _DateTimePicker(
                  labelText: 'Date',
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
                _transactionType == UIData.transaction_type_transfer
                    ? new InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'To Account',
                          hintText: 'Choose an account',
                        ),
                        isEmpty: _toAccountId == null,
                        child: buildAccountList(accountBloc, true),
                      )
                    : null,
                _showTransferToAmount ? const SizedBox(height: 24.0) : null,
                _showTransferToAmount
                    ? new TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Converted Amount',
                            prefixText: '\$',
                            suffixText: 'USD',
                            suffixStyle: const TextStyle(color: Colors.green)),
                        maxLines: 1,
                        controller: _convertedAmountFieldController,
                        validator: _validateAmount,
                      )
                    : null,
                const SizedBox(height: 24.0),
                new Text('* all fields are mandatory',
                    style: Theme.of(context).textTheme.caption),
              ].where((child) => child != null).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _validateAmount(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'Amount is required.';
    if (double.tryParse(value) == null) {
      return 'Please enter a valid amount.';
    }
    return null;
  }

  bool _isValidCategory() {
    if (_categoryId == null) {
      String error = 'Category is required.';
      showInSnackBar(error);
      setState(() {
        _categoryErrorText = error;
      });
      return false;
    } else {
      if (_categoryErrorText != null) {
        setState(() {
          _categoryErrorText = null;
        });
      }
      return true;
    }
  }

  bool _isValidAccount() {
    if (_accountId == null) {
      String error = 'Account is required.';
      showInSnackBar(error);
      setState(() {
        _accountErrorText = error;
      });
      return false;
    } else {
      if (_accountErrorText != null) {
        setState(() {
          _accountErrorText = null;
        });
      }
      return true;
    }
  }

  bool _isValidToAccount() {
    if (_toAccountId == null) {
      String error = 'Please select receiving account.';
      showInSnackBar(error);
      return false;
    } else {
      return true;
    }
  }

  String _validateDescription(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'Description is required.';
    return null;
  }
}

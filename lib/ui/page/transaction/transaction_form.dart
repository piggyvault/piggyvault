import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/bloc/category_bloc.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/providers/category_provider.dart';
import 'package:piggy_flutter/providers/transaction_provider.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/ui/widgets/date_time_picker.dart';
// TODO: BLoC

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class TransactionFormPage extends StatefulWidget {
  final Account account;
  final Transaction transaction;
  final String title;
  final bool isCopy;

  TransactionFormPage(
      {Key key,
      this.title,
      this.account,
      this.transaction,
      this.isCopy = false})
      : super(key: key);

  @override
  TransactionFormPageState createState() => new TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  TransactionEditDto transactionEditDto = new TransactionEditDto();
  TextEditingController _descriptionFieldController;
  TextEditingController _amountFieldController;

  final TextEditingController _convertedAmountFieldController =
      new TextEditingController();

  Account _account, _toAccount;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _formWasEdited = false;
  bool _showTransferToAmount = false;
  String _categoryErrorText, _accountErrorText, _toAccountId;
  DateTime _transactionDate = new DateTime.now();
  TimeOfDay _transactionTime;
  String _transactionType = UIData.transaction_type_expense;

  TransactionService _transactionService = new TransactionService();

  @override
  void initState() {
    super.initState();
    _transactionTime =
        TimeOfDay(hour: _transactionDate.hour, minute: _transactionDate.minute);

    if (widget.transaction == null) {
      _descriptionFieldController = new TextEditingController();
      _amountFieldController = new TextEditingController();
    } else {
      _account = widget.account;
      _transactionService
          .getTransactionForEdit(widget.transaction.id)
          .then((result) {
        setState(() {
          transactionEditDto = result;
          if (widget.isCopy) {
            transactionEditDto.id = null;
          } else {
            _transactionDate =
                DateTime.parse(transactionEditDto.transactionTime);
            _transactionTime = TimeOfDay(
                hour: _transactionDate.hour, minute: _transactionDate.minute);
          }

          if (transactionEditDto.amount > 0) {
            _transactionType = UIData.transaction_type_income;
          } else {
            _transactionType = UIData.transaction_type_expense;
          }

          _descriptionFieldController =
              new TextEditingController(text: transactionEditDto.description);
          _amountFieldController = new TextEditingController(
              text: transactionEditDto.amount.toString());
        });
      });
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
      appBar: new AppBar(
          title:
              new Text(widget.title == null ? 'New Transaction' : widget.title),
          actions: <Widget>[
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
            autovalidate: _autoValidate,
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
                          manageTransferView();
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
                  isEmpty: transactionEditDto.accountId == null,
                  child: buildAccountList(accountBloc),
                ),
                const SizedBox(height: 24.0),
                new TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(),
                      labelText: 'Amount',
                      prefixText:
                          _account == null ? null : _account.currencySymbol,
                      suffixText:
                          _account == null ? null : _account.currencyCode,
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
                  isEmpty: transactionEditDto.categoryId == null,
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
                new DateTimePicker(
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
                        isEmpty: _toAccount == null,
                        child: buildAccountList(accountBloc, true),
                      )
                    : null,
                _showTransferToAmount ? const SizedBox(height: 24.0) : null,
                _showTransferToAmount
                    ? new TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: new InputDecoration(
                            border: new OutlineInputBorder(),
                            labelText: 'Converted Amount',
                            prefixText: _toAccount == null
                                ? null
                                : _toAccount.currencySymbol,
                            suffixText: _toAccount == null
                                ? null
                                : _toAccount.currencyCode,
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

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _descriptionFieldController.dispose();
    _amountFieldController.dispose();
    _convertedAmountFieldController.dispose();
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
                value: transactionEditDto.categoryId,
                onChanged: (int newValue) {
                  setState(() {
                    transactionEditDto.categoryId = newValue;
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
          if (transactionEditDto != null &&
              transactionEditDto.accountId != null) {
            _account = snapshot.data.firstWhere(
                (account) => account.id == transactionEditDto.accountId);
          }
          return new DropdownButton<String>(
            value: isToAccount ? _toAccountId : transactionEditDto.accountId,
            onChanged: (String newValue) {
              setState(() {
                if (isToAccount) {
                  _toAccountId = newValue;
                  _toAccount = accountBloc.userAccountList
                      .firstWhere((account) => account.id == newValue);
                } else {
                  transactionEditDto.accountId = newValue;
                  _account = accountBloc.userAccountList
                      .firstWhere((account) => account.id == newValue);
                }
              });
              manageTransferView();
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
      },
    );
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
      _autoValidate = true; // Start validating on every change.
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

          transactionBloc.doTransfer(TransferInput(
              transactionEditDto.id,
              _descriptionFieldController.text,
              transactionEditDto.accountId,
              DateTime(
                      _transactionDate.year,
                      _transactionDate.month,
                      _transactionDate.day,
                      _transactionTime.hour,
                      _transactionTime.minute)
                  .toString(),
              amount,
              transactionEditDto.categoryId,
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

        transactionEditDto.description = _descriptionFieldController.text;
        transactionEditDto.transactionTime = new DateTime(
                _transactionDate.year,
                _transactionDate.month,
                _transactionDate.day,
                _transactionTime.hour,
                _transactionTime.minute)
            .toString();
        transactionEditDto.amount = amount;
        transactionEditDto.accountBloc = accountBloc;

        transactionBloc.saveTransaction(transactionEditDto);

        Navigator.pop(context, DismissDialogAction.save);
      }
    }
  }

  void manageTransferView() {
    if (_transactionType == UIData.transaction_type_transfer &&
        _account != null &&
        _toAccount != null) {
      // check whether both accounts currency is same or not
      if (_account.currencyCode == _toAccount.currencyCode) {
        setState(() {
          _showTransferToAmount = false;
        });
      } else {
        // if not same, show converted amount field
        _showTransferToAmount = true;
      }
    }
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
    if (transactionEditDto.categoryId == null) {
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
    if (transactionEditDto.accountId == null) {
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
    if (_toAccount == null) {
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

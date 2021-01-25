import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/categories/categories_bloc.dart';
import 'package:piggy_flutter/blocs/categories/categories_state.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_edit_dto.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/common/common_dialogs.dart';
import 'package:piggy_flutter/widgets/date_time_picker.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage(
      {Key key,
      @required this.transactionsBloc,
      this.title,
      this.account,
      this.transaction,
      this.isCopy = false,
      this.description})
      : super(key: key);

  final TransactionBloc transactionsBloc;
  final Account account;
  final Transaction transaction;
  final String title;
  final bool isCopy;
  final String description;

  @override
  TransactionFormPageState createState() => TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  TransactionEditDto transactionEditDto = TransactionEditDto();
  TextEditingController _descriptionFieldController;
  TextEditingController _amountFieldController;

  final TextEditingController _convertedAmountFieldController =
      TextEditingController();

  Account _account, _toAccount;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _formWasEdited = false;
  bool _showTransferToAmount = false;
  String _categoryErrorText, _accountErrorText, _toAccountId;
  DateTime _transactionDate = DateTime.now();
  TimeOfDay _transactionTime;
  String _transactionType = UIData.transaction_type_expense;

  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _transactionTime =
        TimeOfDay(hour: _transactionDate.hour, minute: _transactionDate.minute);

    if (widget.account != null) {
      _account = widget.account;
      transactionEditDto.accountId = _account.id;
    }

    if (widget.transaction == null) {
      _descriptionFieldController = widget.description == null
          ? TextEditingController()
          : _descriptionFieldController =
              TextEditingController(text: widget.description);

      _amountFieldController = TextEditingController();
    } else {
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
              TextEditingController(text: transactionEditDto.description);
          _amountFieldController =
              TextEditingController(text: transactionEditDto.amount.toString());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final _transactionTextStyle = TextStyle(
        color: _transactionType == UIData.transaction_type_income
            ? Colors.green
            : Colors.red);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title == null ? ' Transaction' : widget.title),
          actions: <Widget>[
            FlatButton(
                child: Text('SAVE', style: theme.textTheme.button),
                onPressed: () {
                  onSave();
                })
          ],
        ),
        body: BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is SavingTransaction) {
              showProgress(context);
            }

            if (state is TransactionSaved) {
              hideProgress(context);
              showSuccess(
                  context: context,
                  message: UIData.success,
                  icon: MaterialCommunityIcons.check);
            }
          },
          child: DropdownButtonHideUnderline(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Form(
                key: _formKey,
                onWillPop: _onWillPop,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Transaction Type',
                          hintText: 'Choose the type of transaction',
                        ),
                        isEmpty: _transactionType == null,
                        child: DropdownButton<String>(
                          value: _transactionType,
                          isDense: true,
                          onChanged: (String value) {
                            setState(() {
                              _transactionType = value;
                              manageTransferView();
                            });
                          },
                          items: <String>[
                            UIData.transaction_type_expense,
                            UIData.transaction_type_income,
                            UIData.transaction_type_transfer
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        hintText: 'Choose an account',
                      ),
                      isEmpty: transactionEditDto.accountId == null,
                      child: buildAccountList(),
                    ),
                    const SizedBox(height: 24.0),
                    PrimaryColorOverride(
                      child: TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount',
                            prefixText: _account == null
                                ? null
                                : _account.currencySymbol,
                            prefixStyle: _transactionTextStyle,
                            suffixText:
                                _account == null ? null : _account.currencyCode,
                            suffixStyle: _transactionTextStyle),
                        maxLines: 1,
                        controller: _amountFieldController,
                        validator: _validateAmount,
                      ),
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'Choose a category',
                        errorText: _categoryErrorText,
                      ),
                      isEmpty: transactionEditDto.categoryId == null,
                      child: buildCategoryList(),
                    ),
                    const SizedBox(height: 24.0),
                    PrimaryColorOverride(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Tell us about the transaction',
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                        keyboardType: TextInputType.multiline,
                        controller: _descriptionFieldController,
                        validator: _validateDescription,
                      ),
                    ),
                    DateTimePicker(
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
                        ? InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'To Account',
                              hintText: 'Choose an account',
                            ),
                            isEmpty: _toAccount == null,
                            child: buildAccountList(true),
                          )
                        : null,
                    _showTransferToAmount ? const SizedBox(height: 24.0) : null,
                    _showTransferToAmount
                        ? PrimaryColorOverride(
                            child: TextFormField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Converted Amount',
                                prefixText: _toAccount == null
                                    ? null
                                    : _toAccount.currencySymbol,
                                prefixStyle:
                                    const TextStyle(color: Colors.green),
                                suffixText: _toAccount == null
                                    ? null
                                    : _toAccount.currencyCode,
                                suffixStyle:
                                    const TextStyle(color: Colors.green),
                              ),
                              maxLines: 1,
                              controller: _convertedAmountFieldController,
                              validator: _validateAmount,
                            ),
                          )
                        : null,
                    const SizedBox(height: 24.0),
                    Text('* all fields are mandatory',
                        style: Theme.of(context).textTheme.caption),
                  ].where((child) => child != null).toList(),
                ),
              ),
            ),
          ),
        ));
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

  Widget buildCategoryList() =>
      BlocBuilder<CategoriesBloc, CategoriesState>(builder: (context, state) {
        if (state is CategoriesLoaded) {
          return DropdownButton<String>(
            value: transactionEditDto.categoryId,
            onChanged: (String value) {
              setState(() {
                transactionEditDto.categoryId = value;
              });
            },
            items: state.categories.map((Category category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
          );
        }
        return LinearProgressIndicator();
      });

  Widget buildAccountList([bool isToAccount = false]) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoaded) {
          if (transactionEditDto != null &&
              transactionEditDto.accountId != null) {
            _account = state.userAccounts.firstWhere(
                (account) => account.id == transactionEditDto.accountId);
          }
          return DropdownButton<String>(
            value: isToAccount ? _toAccountId : transactionEditDto.accountId,
            onChanged: (String value) {
              setState(() {
                if (isToAccount) {
                  _toAccountId = value;
                  _toAccount = state.userAccounts
                      .firstWhere((account) => account.id == value);
                } else {
                  transactionEditDto.accountId = value;
                  _account = state.userAccounts
                      .firstWhere((account) => account.id == value);
                }
              });
              manageTransferView();
            },
            items: state.userAccounts.map((Account account) {
              return DropdownMenuItem<String>(
                value: account.id,
                child: Text(account.name),
              );
            }).toList(),
          );
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }

  void onSave() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
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

          widget.transactionsBloc.add(DoTransfer(
              transferInput: TransferInput(
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
                  toAmount,
                  _toAccountId)));
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
        transactionEditDto.transactionTime = DateTime(
                _transactionDate.year,
                _transactionDate.month,
                _transactionDate.day,
                _transactionTime.hour,
                _transactionTime.minute)
            .toString();
        transactionEditDto.amount = amount;
        widget.transactionsBloc
            .add(SaveTransaction(transactionEditDto: transactionEditDto));
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

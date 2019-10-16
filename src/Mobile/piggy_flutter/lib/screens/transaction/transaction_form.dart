import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_edit_dto.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form_bloc.dart';
import 'package:piggy_flutter/utils/api_subscription.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/date_time_picker.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';
// TODO: BLoC

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
  bool _autoValidate = false;
  bool _formWasEdited = false;
  bool _showTransferToAmount = false;
  String _categoryErrorText, _accountErrorText, _toAccountId;
  DateTime _transactionDate = DateTime.now();
  TimeOfDay _transactionTime;
  String _transactionType = UIData.transaction_type_expense;

  final TransactionService _transactionService = TransactionService();
  TransactionFormBloc transactionFormBloc;
  StreamSubscription<ApiRequest> apiStreamSubscription;

  @override
  void initState() {
    super.initState();
    transactionFormBloc = TransactionFormBloc();
    apiStreamSubscription = apiSubscription(
        stream: transactionFormBloc.state, context: context, key: _scaffoldKey);

    _transactionTime =
        TimeOfDay(hour: _transactionDate.hour, minute: _transactionDate.minute);

    if (widget.account != null) {
      _account = widget.account;
      transactionEditDto.accountId = _account.id;
    }

    if (widget.transaction == null) {
      _descriptionFieldController = TextEditingController();
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
    final CategoryBloc categoryBloc = BlocProvider.of<CategoryBloc>(context);
    final AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);

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
                onSave(transactionFormBloc);
              })
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
                  child: buildAccountList(accountBloc),
                ),
                const SizedBox(height: 24.0),
                PrimaryColorOverride(
                  child: TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount',
                        prefixText:
                            _account == null ? null : _account.currencySymbol,
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
                  child: buildCategoryList(categoryBloc),
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
                        child: buildAccountList(accountBloc, true),
                      )
                    : null,
                _showTransferToAmount ? const SizedBox(height: 24.0) : null,
                _showTransferToAmount
                    ? PrimaryColorOverride(
                        child: TextFormField(
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Converted Amount',
                            prefixText: _toAccount == null
                                ? null
                                : _toAccount.currencySymbol,
                            prefixStyle: const TextStyle(color: Colors.green),
                            suffixText: _toAccount == null
                                ? null
                                : _toAccount.currencyCode,
                            suffixStyle: const TextStyle(color: Colors.green),
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
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _descriptionFieldController.dispose();
    _amountFieldController.dispose();
    _convertedAmountFieldController.dispose();
    apiStreamSubscription?.cancel();
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

  Widget buildCategoryList(CategoryBloc categoryBloc) =>
      StreamBuilder<List<Category>>(
          stream: categoryBloc.categories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DropdownButton<int>(
                value: transactionEditDto.categoryId,
                onChanged: (int value) {
                  setState(() {
                    transactionEditDto.categoryId = value;
                  });
                },
                items: snapshot.data.map((Category category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
              );
            } else {
              return LinearProgressIndicator();
            }
          });

  Widget buildAccountList(AccountBloc accountBloc, [bool isToAccount = false]) {
    return StreamBuilder<List<Account>>(
      stream: accountBloc.userAccounts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (transactionEditDto != null &&
              transactionEditDto.accountId != null) {
            _account = snapshot.data.firstWhere(
                (account) => account.id == transactionEditDto.accountId);
          }
          return DropdownButton<String>(
            value: isToAccount ? _toAccountId : transactionEditDto.accountId,
            onChanged: (String value) {
              setState(() {
                if (isToAccount) {
                  _toAccountId = value;
                  _toAccount = accountBloc.userAccountList
                      .firstWhere((account) => account.id == value);
                } else {
                  transactionEditDto.accountId = value;
                  _account = accountBloc.userAccountList
                      .firstWhere((account) => account.id == value);
                }
              });
              manageTransferView();
            },
            items: snapshot.data.map((Account account) {
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

  void onSave(TransactionFormBloc transactionFormBloc) async {
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

          transactionFormBloc.onTransfer(TransferInput(
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
              _toAccountId));
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
        transactionFormBloc.onSave(transactionEditDto);
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

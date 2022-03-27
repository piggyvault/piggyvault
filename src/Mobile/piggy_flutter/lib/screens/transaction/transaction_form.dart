import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:input_calculator/input_calculator.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/categories/categories_bloc.dart';
import 'package:piggy_flutter/blocs/categories/categories_state.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/common/common_dialogs.dart';
import 'package:piggy_flutter/widgets/date_time_picker.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage(
      {Key? key,
      required this.transactionsBloc,
      this.title,
      this.account,
      this.transaction,
      this.isCopy = false,
      this.description})
      : super(key: key);

  final TransactionBloc transactionsBloc;
  final Account? account;
  final Transaction? transaction;
  final String? title;
  final bool isCopy;
  final String? description;

  @override
  TransactionFormPageState createState() => TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  TransactionEditDto? transactionEditDto = TransactionEditDto();
  TextEditingController? _descriptionFieldController;

  Account? _account, _toAccount;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _formWasEdited = false;
  bool _showReceivingAmount = false;
  String? _categoryErrorText, _accountErrorText, _toAccountId;
  DateTime _transactionDate = DateTime.now();
  TimeOfDay? _transactionTime;
  String? _transactionType = UIData.transaction_type_expense;
  double _amount = 0;
  double _receivingAmount = 0;

  final TransactionService _transactionService = TransactionService();
  Object redrawAmountObject = Object();
  Object redrawReceivingAmountObject = Object();

  int _selectedTransactionTypeIndex = 0;

  final List<String> _transactionTypes = [
    UIData.transaction_type_expense,
    UIData.transaction_type_income,
    UIData.transaction_type_transfer
  ];

  @override
  void initState() {
    super.initState();

    _transactionTime =
        TimeOfDay(hour: _transactionDate.hour, minute: _transactionDate.minute);

    if (widget.account != null) {
      _account = widget.account;
      transactionEditDto!.accountId = _account!.id;
    }

    if (widget.transaction == null) {
      _descriptionFieldController = widget.description == null
          ? TextEditingController()
          : _descriptionFieldController =
              TextEditingController(text: widget.description);
    } else {
      _transactionService
          .getTransactionForEdit(widget.transaction!.id)
          .then((result) {
        setState(() {
          transactionEditDto = result;

          _amount = transactionEditDto!.amount!;
          redrawAmountObject = Object(); // fix to show amount in case of edit

          if (widget.isCopy) {
            transactionEditDto!.id = null;
          } else {
            _transactionDate =
                DateTime.parse(transactionEditDto!.transactionTime!);
            _transactionTime = TimeOfDay(
                hour: _transactionDate.hour, minute: _transactionDate.minute);
          }

          if (transactionEditDto!.amount! > 0) {
            _transactionType = UIData.transaction_type_income;
          } else {
            _transactionType = UIData.transaction_type_expense;
          }

          _selectedTransactionTypeIndex =
              _transactionTypes.indexOf(_transactionType!);

          _descriptionFieldController =
              TextEditingController(text: transactionEditDto!.description);
        });
      });
    }
  }

  static String format(double value, {String? symbol}) {
    return NumberFormat.simpleCurrency(
      name: symbol,
      decimalDigits: 2,
    ).format(value);
  }

  String valueFormat(double? value) {
    return format(value!, symbol: '');
  }

  @override
  Widget build(BuildContext context) {
    final _transactionTextStyle = TextStyle(
        color: _transactionType == UIData.transaction_type_income
            ? Colors.green
            : Colors.red);

    return NeumorphicTheme(
      themeMode: ThemeMode.light,
      theme: const NeumorphicThemeData(
        lightSource: LightSource.topLeft,
        accentColor: NeumorphicColors.accent,
        appBarTheme: NeumorphicAppBarThemeData(
          buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          textStyle: TextStyle(color: Colors.black54),
          iconTheme: IconThemeData(color: Colors.black54, size: 30),
        ),
        depth: 4,
        intensity: 0.9,
      ),
      child: Material(
        child: NeumorphicBackground(
          child: ScaffoldMessenger(
            key: scaffoldMessengerKey,
            child: Scaffold(
              appBar: NeumorphicAppBar(
                title:
                    Text(widget.title == null ? ' Transaction' : widget.title!),
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
                        children: <Widget?>[
                          NeumorphicToggle(
                            height: 50,
                            style: const NeumorphicToggleStyle(
                                //backgroundColor: Colors.red,
                                ),
                            selectedIndex: _selectedTransactionTypeIndex,
                            displayForegroundOnlyIfSelected: true,
                            children: [
                              ToggleElement(
                                background: const Center(
                                    child: Text(
                                  UIData.transaction_type_expense,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )),
                                foreground: Center(
                                    child: Text(
                                  UIData.transaction_type_expense,
                                  style: _transactionTextStyle.copyWith(
                                      fontWeight: FontWeight.w700),
                                )),
                              ),
                              ToggleElement(
                                background: const Center(
                                    child: Text(
                                  UIData.transaction_type_income,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )),
                                foreground: Center(
                                    child: Text(
                                  UIData.transaction_type_income,
                                  style: _transactionTextStyle.copyWith(
                                      fontWeight: FontWeight.w700),
                                )),
                              ),
                              ToggleElement(
                                background: const Center(
                                    child: Text(
                                  UIData.transaction_type_transfer,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )),
                                foreground: Center(
                                    child: Text(
                                  UIData.transaction_type_transfer,
                                  style: _transactionTextStyle.copyWith(
                                      fontWeight: FontWeight.w700),
                                )),
                              )
                            ],
                            thumb: Neumorphic(
                              style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(
                                    const BorderRadius.all(
                                        Radius.circular(12))),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedTransactionTypeIndex = value;
                                _transactionType = _transactionTypes[value];
                              });
                            },
                          ),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Account',
                              hintText: 'Choose an account',
                            ),
                            isEmpty: transactionEditDto!.accountId == null,
                            child: buildAccountList(),
                          ),
                          const SizedBox(height: 24.0),
                          CalculatorTextFormField(
                            key: ValueKey<Object>(redrawAmountObject),
                            initialValue: _amount,
                            validator: _validateAmount,
                            valueFormat: valueFormat,
                            style: _transactionTextStyle,
                            appBarBackgroundColor: PiggyAppTheme.nearlyWhite,
                            title: 'Amount',
                            inputDecoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Amount',
                                prefixText: _account == null
                                    ? null
                                    : _account!.currencySymbol,
                                prefixStyle: _transactionTextStyle,
                                suffixText: _account == null
                                    ? null
                                    : _account!.currencyCode,
                                suffixStyle: _transactionTextStyle),
                            onSubmitted: (value) {
                              setState(() {
                                _amount = value!;
                              });
                            },
                          ),
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              hintText: 'Choose a category',
                              errorText: _categoryErrorText,
                            ),
                            isEmpty: transactionEditDto!.categoryId == null,
                            child: buildCategoryList(),
                          ),
                          const SizedBox(height: 24.0),
                          PrimaryColorOverride(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Tell us about the transaction',
                                labelText: 'Description',
                              ),
                              maxLines: 2,
                              keyboardType: TextInputType.multiline,
                              controller: _descriptionFieldController,
                              validator: _validateDescription,
                              textCapitalization: TextCapitalization.sentences,
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
                          _showReceivingAmount
                              ? const SizedBox(height: 24.0)
                              : null,
                          _showReceivingAmount
                              ? CalculatorTextFormField(
                                  key: ValueKey<Object>(
                                      redrawReceivingAmountObject),
                                  initialValue: _receivingAmount,
                                  validator: _validateAmount,
                                  valueFormat: valueFormat,
                                  inputDecoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Converted Amount',
                                    prefixText: _toAccount == null
                                        ? null
                                        : _toAccount!.currencySymbol,
                                    prefixStyle:
                                        const TextStyle(color: Colors.green),
                                    suffixText: _toAccount == null
                                        ? null
                                        : _toAccount!.currencyCode,
                                    suffixStyle:
                                        const TextStyle(color: Colors.green),
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      _receivingAmount = value!;
                                    });
                                  },
                                )
                              : null,
                          const SizedBox(height: 24.0),
                          NeumorphicButton(
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(12)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 18),
                            child: const Center(
                              child: Text("SAVE",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                            ),
                            onPressed: () {
                              onSave();
                            },
                          ),
                          const SizedBox(height: 24.0),
                          Text('* all fields are mandatory',
                              style: Theme.of(context).textTheme.caption),
                        ].whereType<Widget>().toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _descriptionFieldController!.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subtitle1!
        .copyWith(color: theme.textTheme.caption!.color);

    return await (showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard unsaved changes?', style: dialogTextStyle),
              actions: <Widget>[
                TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                TextButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        )) ??
        false;
  }

  Widget buildCategoryList() =>
      BlocBuilder<CategoriesBloc, CategoriesState>(builder: (context, state) {
        if (state is CategoriesLoaded) {
          return DropdownButton<String>(
            value: transactionEditDto!.categoryId,
            onChanged: (String? value) {
              setState(() {
                transactionEditDto!.categoryId = value;
              });
            },
            items: state.categories.map((Category category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name!),
              );
            }).toList(),
          );
        }
        return const LinearProgressIndicator();
      });

  Widget buildAccountList([bool isToAccount = false]) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoaded) {
          if (transactionEditDto != null &&
              transactionEditDto!.accountId != null) {
            _account = state.userAccounts!.firstWhere(
                (account) => account.id == transactionEditDto!.accountId);
          }
          return DropdownButton<String>(
            value: isToAccount ? _toAccountId : transactionEditDto!.accountId,
            onChanged: (String? value) {
              setState(() {
                if (isToAccount) {
                  _toAccountId = value;
                  _toAccount = state.userAccounts!
                      .firstWhere((account) => account.id == value);
                } else {
                  transactionEditDto!.accountId = value;
                  _account = state.userAccounts!
                      .firstWhere((account) => account.id == value);
                }
              });
              manageTransferView();
            },
            items: state.userAccounts!
                .where((a) => a.isArchived == false)
                .map((Account account) {
              return DropdownMenuItem<String>(
                value: account.id,
                child: Text(account.name!),
              );
            }).toList(),
          );
        } else {
          return const LinearProgressIndicator();
        }
      },
    );
  }

  void showInSnackBar(String value) {
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }

  void onSave() {
    final FormState form = _formKey.currentState!;

    if (!form.validate()) {
      showInSnackBar('Please fix the errors before submitting.');
    } else {
      if (!_isValidAccount() || !_isValidCategory()) {
        return;
      }

      double amount = _amount;

      if (_transactionType == UIData.transaction_type_transfer) {
        if (!_isValidToAccount()) {
          return;
        } else {
          double toAmount;

          if (_showReceivingAmount) {
            toAmount = _receivingAmount;
          } else {
            toAmount = amount;
          }

          widget.transactionsBloc.add(DoTransfer(
              transferInput: TransferInput(
                  transactionEditDto!.id,
                  _descriptionFieldController!.text,
                  transactionEditDto!.accountId,
                  DateTime(
                          _transactionDate.year,
                          _transactionDate.month,
                          _transactionDate.day,
                          _transactionTime!.hour,
                          _transactionTime!.minute)
                      .toString(),
                  amount,
                  transactionEditDto!.categoryId,
                  toAmount,
                  _toAccountId)));
        }
      } else {
        if (_transactionType == UIData.transaction_type_expense && amount > 0) {
          amount *= -1;
        }
        if (_transactionType == UIData.transaction_type_income && amount < 0) {
          amount *= -1;
        }

        transactionEditDto!.description = _descriptionFieldController!.text;
        transactionEditDto!.transactionTime = DateTime(
                _transactionDate.year,
                _transactionDate.month,
                _transactionDate.day,
                _transactionTime!.hour,
                _transactionTime!.minute)
            .toString();
        transactionEditDto!.amount = amount;
        widget.transactionsBloc
            .add(SaveTransaction(transactionEditDto: transactionEditDto!));
      }
    }
  }

  void manageTransferView() {
    if (_transactionType == UIData.transaction_type_transfer &&
        _account != null &&
        _toAccount != null) {
      // check whether both accounts currency is same or not
      if (_account!.currencyCode == _toAccount!.currencyCode) {
        setState(() {
          _showReceivingAmount = false;
        });
      } else {
        // if not same, show converted amount field
        _showReceivingAmount = true;
      }
    }
  }

  String? _validateAmount(String? value) {
    _formWasEdited = true;
    if (value!.isEmpty) return 'Amount is required.';
    return null;
  }

  bool _isValidCategory() {
    if (transactionEditDto!.categoryId == null) {
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
    if (transactionEditDto!.accountId == null) {
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

  String? _validateDescription(String? value) {
    _formWasEdited = true;
    if (value!.isEmpty) return 'Description is required.';
    return null;
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:piggy_flutter/blocs/account_form/bloc.dart';
import 'package:piggy_flutter/blocs/account_types/bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/currencies/bloc.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({Key? key, this.title, this.account})
      : super(key: key);

  final String? title;
  final Account? account;

  @override
  _AccountFormScreenState createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  AccountFormModel? accountFormModel;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _formWasEdited = false;

  AccountFormBloc? accountFormBloc;
  TextEditingController? _nameFieldController;
  CurrenciesBloc? currenciesBloc;
  AccountTypesBloc? accountTypesBloc;

  @override
  void initState() {
    super.initState();
    accountFormBloc = AccountFormBloc(
        accountsBloc: BlocProvider.of<AccountsBloc>(context),
        accountRepository: RepositoryProvider.of<AccountRepository>(context));
    accountFormModel =
        AccountFormModel(id: widget.account?.id, isArchived: false);

    accountFormBloc!.add(AccountFormLoad(accountId: widget.account?.id));

    if (widget.account == null) {
      _nameFieldController = TextEditingController();
    } else {
      _nameFieldController = TextEditingController(text: widget.account!.name);
    }

    currenciesBloc = CurrenciesBloc(
        accountRepository: RepositoryProvider.of<AccountRepository>(context));
    currenciesBloc!.add(LoadCurrencies());

    accountTypesBloc = AccountTypesBloc(
        accountRepository: RepositoryProvider.of<AccountRepository>(context));
    accountTypesBloc!.add(AccountTypesLoad());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: NeumorphicAppBar(
            title: Text(widget.title!),
          ),
          body: BlocListener<AccountFormBloc, AccountFormState>(
            bloc: accountFormBloc,
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
              bloc: accountFormBloc,
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onWillPop: _onWillPop,
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: <Widget?>[
                          _nameField(theme),
                          BlocBuilder<CurrenciesBloc, CurrenciesState>(
                              bloc: currenciesBloc,
                              builder: (BuildContext context,
                                  CurrenciesState currenciesState) {
                                if (currenciesState is CurrenciesLoaded) {
                                  return InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Currency',
                                        hintText: 'Choose a currency',
                                      ),
                                      isEmpty:
                                          accountFormModel!.currencyId == null,
                                      child: DropdownButton<int>(
                                        value: accountFormModel!.currencyId,
                                        onChanged: (int? value) {
                                          setState(() {
                                            accountFormModel!.currencyId =
                                                value;
                                          });
                                        },
                                        items: currenciesState.currencies
                                            .map((Currency currency) {
                                          return DropdownMenuItem<int>(
                                            value: currency.id,
                                            child: Text(currency.name!),
                                          );
                                        }).toList(),
                                      ));
                                } else {
                                  return const LinearProgressIndicator();
                                }
                              }),
                          BlocBuilder<AccountTypesBloc, AccountTypesState>(
                            bloc: accountTypesBloc,
                            builder: (BuildContext context,
                                AccountTypesState accountTypeState) {
                              if (accountTypeState is AccountTypesLoaded) {
                                return InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    hintText: 'Choose an account type',
                                  ),
                                  isEmpty:
                                      accountFormModel!.accountTypeId == null,
                                  child: DropdownButton<int>(
                                    value: accountFormModel!.accountTypeId,
                                    onChanged: (int? value) {
                                      setState(() {
                                        accountFormModel!.accountTypeId = value;
                                      });
                                    },
                                    items: accountTypeState.accountTypes
                                        .map((AccountType type) {
                                      return DropdownMenuItem<int>(
                                        value: type.id,
                                        child: Text(type.name!),
                                      );
                                    }).toList(),
                                  ),
                                );
                              } else {
                                return const LinearProgressIndicator();
                              }
                            },
                          ),
                          const SizedBox(height: 8.0),
                          accountFormModel?.id == null
                              ? null
                              : CheckboxListTile(
                                  title: const Text("Archived"), //    <-- label
                                  value: accountFormModel!.isArchived,
                                  secondary: const Icon(Icons.archive),
                                  subtitle: const Text('Freeze this account.'),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (newValue) {
                                    setState(() {
                                      accountFormModel!.isArchived = newValue!;
                                    });
                                  },
                                ),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) {
      return true;
    }

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
        ) as FutureOr<bool>?) ??
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
        style: theme.textTheme.headline5,
      ),
    );
  }

  void onSave() {
    accountFormModel!.name = _nameFieldController!.text;

    if (_isValidAccount()) {
      accountFormBloc!.add(AccountFormSave(account: accountFormModel!));
    }
  }

  bool _isValidAccount() {
    if (accountFormModel!.currencyId == null) {
      const String error = 'Currency is required.';
      showInSnackBar(error);
      return false;
    } else if (accountFormModel!.accountTypeId == null) {
      const String error = 'Account type is required.';
      showInSnackBar(error);
      return false;
    }
    return true;
  }

  void showInSnackBar(String value) {
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }
}

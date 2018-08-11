import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_detail_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/account_detail_state.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';
import 'package:piggy_flutter/ui/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/ui/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/ui/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/ui/widgets/transaction_list.dart';
import 'package:piggy_flutter/utils/uidata.dart';

class AccountDetailPage extends StatefulWidget {
  final Account account;
  final TransactionService transactionService;

  AccountDetailPage(
      {Key key, this.account, TransactionService transactionService})
      : this.transactionService = transactionService ?? TransactionService(),
        super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  AccountDetailBloc bloc;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    bloc = AccountDetailBloc(
        transactionService: widget.transactionService,
        accountId: widget.account.id);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AccountDetailState>(
        stream: bloc.state,
        initialData: AccountDetailLoading('This Month'),
        builder:
            (BuildContext context, AsyncSnapshot<AccountDetailState> snapshot) {
          final state = snapshot.data;
          print('state is $state');

          return Scaffold(
            appBar: AppBar(
              title: Text(
                  '${widget.account.name} - ${widget.account.currentBalance} ${widget.account.currencySymbol}'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Row(children: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.chevron_left),
                        // color: color,
                        // onPressed: () { _handleArrowButtonPress(context, -1); },
                        tooltip: 'Page back'),
                    Text(state.title),
                    IconButton(
                        icon: const Icon(Icons.chevron_right),
                        // color: color,
                        // onPressed: () { _handleArrowButtonPress(context, 1); },
                        tooltip: 'Page forward')
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                ),
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
//            onSelected: showMenuSelection,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: UIData.adjust_balance,
                          child: ListTile(
                            leading: Icon(Icons.account_balance),
                            title: Text(UIData.adjust_balance),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              bottom: false,
              child: new Column(
                children: <Widget>[
                  // new Container(
                  //   margin: const EdgeInsets.only(top: 16.0),
                  //   child: new Row(children: <Widget>[
                  //     new IconButton(
                  //         icon: const Icon(Icons.chevron_left),
                  //         // color: color,
                  //         // onPressed: () { _handleArrowButtonPress(context, -1); },
                  //         tooltip: 'Page back'),
                  //     // new TabPageSelector(controller: controller),
                  //     new IconButton(
                  //         icon: const Icon(Icons.chevron_right),
                  //         // color: color,
                  //         // onPressed: () { _handleArrowButtonPress(context, 1); },
                  //         tooltip: 'Page forward')
                  //   ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  // ),
                  new Expanded(
                    child: Stack(
                      children: <Widget>[
                        // Fade in a loading screen when results are being fetched
                        LoadingWidget(visible: state is AccountDetailLoading),

                        // Fade in an Empty Result screen if the search contained
                        // no items
                        EmptyResultWidget(visible: state is AccountDetailEmpty),

                        // Fade in an error if something went wrong when fetching
                        // the results
                        ErrorDisplayWidget(
                            visible: state is AccountDetailError),

                        // Fade in the Result if available
                        TransactionList(
                          items: state is AccountDetailPopulated
                              ? state.result.items
                              : [],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                key: ValueKey<Color>(Theme.of(context).primaryColor),
                tooltip: 'Add new transaction',
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.add_circle_outline),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<DismissDialogAction>(
                        builder: (BuildContext context) => TransactionFormPage(
                              account: widget.account,
                            ),
                        fullscreenDialog: true,
                      ));
                }),
          );
        });
  }
}

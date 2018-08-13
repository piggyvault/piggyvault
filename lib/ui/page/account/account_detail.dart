import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_detail_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/account_detail_state.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/ui/widgets/add_transaction_fab.dart';
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
    bloc = AccountDetailBloc(accountId: widget.account.id);
    bloc.changeAccount(widget.account);
    bloc.onPageChanged(0);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return StreamBuilder<AccountDetailState>(
        stream: bloc.state,
        initialData: AccountDetailLoading(),
        builder:
            (BuildContext context, AsyncSnapshot<AccountDetailState> snapshot) {
          final state = snapshot.data;
          final account =
              state.account == null ? widget.account : state.account;
          debugPrint('######## state is $state');
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: <Widget>[
                  Text('${widget.account.name}'),
                  Text('${account.currentBalance} ${account.currencySymbol}')
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: Text(state.previousPageTitle,
                            style: textTheme.caption.copyWith(
                                color: Colors.white.withOpacity(0.6))),
                        onTap: () {
                          bloc.onPageChanged(-1);
                        },
                      ),
                      Text(
                        state.title,
                        style: textTheme.body2.copyWith(color: Colors.white),
                      ),
                      InkWell(
                        child: Text(state.nextPageTitle,
                            style: textTheme.caption.copyWith(
                                color: Colors.white.withOpacity(0.6))),
                        onTap: () {
                          bloc.onPageChanged(1);
                        },
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
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
            floatingActionButton: AddTransactionFab(
              account: widget.account,
              accountDetailBloc: bloc,
            ),
          );
        });
  }
}

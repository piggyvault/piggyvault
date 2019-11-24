import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_comment.dart';
import 'package:piggy_flutter/screens/transaction/transaction_detail_bloc.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/utils/api_subscription.dart';
import 'package:piggy_flutter/utils/common.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  TransactionDetailPage({Key key, this.transaction}) : super(key: key);

  @override
  TransactionDetailPageState createState() {
    return new TransactionDetailPageState();
  }
}

class TransactionDetailPageState extends State<TransactionDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formatter = DateFormat("EEE, MMM d, ''yy");
  final _commentTimeFormatter = DateFormat("h:mm a, EEE, MMM d, ''yy");
  final TextEditingController _commentController = new TextEditingController();
  TransactionDetailBloc _bloc;
  StreamSubscription _apiStreamSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = TransactionDetailBloc(widget.transaction);
    _apiStreamSubscription = apiSubscription(
        stream: _bloc.state, context: context, key: _scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: <Widget>[
          _transactionDetails(),
          ListTile(
            title: Text(
              'Comments',
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          _commentTile(),
          _transactionComments(),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(theme),
    );
  }

  Widget _bottomNavigationBar(ThemeData theme) {
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Hide actions if transaction created by another user
          return widget.transaction.creatorUserName == state.user.userName
              ? BottomAppBar(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TransactionFormPage(
                                transaction: widget.transaction,
                                title: 'Edit Transaction',
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TransactionFormPage(
                                transaction: widget.transaction,
                                title: 'Copy Transaction',
                                isCopy: true,
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                          showDeleteConfirmationDialog<DialogAction>(
                              context: context,
                              child: new AlertDialog(
                                  title: const Text('Delete Transaction?'),
                                  content: new Text(
                                      'Are you sure you want to delete transaction with description "${widget.transaction.description}" and amount ${widget.transaction.amount.toString()}${widget.transaction.accountCurrencySymbol}',
                                      style: dialogTextStyle),
                                  actions: <Widget>[
                                    new FlatButton(
                                        child: const Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(
                                              context, DialogAction.disagree);
                                        }),
                                    new FlatButton(
                                        child: const Text('DELETE'),
                                        onPressed: () {
                                          Navigator.pop(
                                              context, DialogAction.agree);
                                        })
                                  ]));
                        },
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        } else {
          return new Container();
        }
      },
    );
  }

  void dispose() {
    _bloc?.dispose();
    _commentController?.dispose();
    _apiStreamSubscription?.cancel();
    super.dispose();
  }

  void showDeleteConfirmationDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value == DialogAction.agree) {
        _bloc.deleteTransaction();
      }
    });
  }

  Widget _commentTile() {
    return StreamBuilder<String>(
      stream: _bloc.comment,
      builder: (context, snapshot) {
        return ListTile(
          title: PrimaryColorOverride(
            child: TextField(
              controller: _commentController,
              decoration: new InputDecoration(
                  labelText: 'Write a comment...', errorText: snapshot.error),
              onChanged: _bloc.changeComment,
            ),
          ),
          trailing: new OutlineButton(
            onPressed: (() {
              if (snapshot.hasData && snapshot.data != null) {
                _bloc.submitComment(widget.transaction.id);
                _commentController.clear();
              }
            }),
            borderSide: BorderSide.none,
            child: Text("Post", style: Theme.of(context).textTheme.button),
          ),
        );
      },
    );
  }

  Widget _transactionComments() {
    return StreamBuilder<List<TransactionComment>>(
        stream: _bloc.transactionComments,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Card(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.map((comment) {
                    return ListTile(
                      leading: const CircleAvatar(),
                      title: Text(comment.creatorUserName),
                      subtitle: Text(comment.content),
                      trailing: Text(
                          '${_commentTimeFormatter.format(DateTime.parse(comment.creationTime))}'),
                    );
                  }).toList()),
            );
          } else {
            return LinearProgressIndicator();
          }
        });
  }

  Widget _transactionDetails() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(widget.transaction.categoryName),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(
                '${widget.transaction.amount.toString()} ${widget.transaction.accountCurrencySymbol}'),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            subtitle: Text(widget.transaction.description),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
                '${_formatter.format(DateTime.parse(widget.transaction.transactionTime))}'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(widget.transaction.accountName),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(widget.transaction.creatorUserName),
          ),
        ],
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_comments/bloc.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/utils/common.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class TransactionDetailPage extends StatefulWidget {
  final TransactionDetailBloc transactionDetailBloc;
  final Transaction? transaction;

  const TransactionDetailPage(
      {Key? key, this.transaction, required this.transactionDetailBloc})
      : super(key: key);

  @override
  TransactionDetailPageState createState() {
    return TransactionDetailPageState();
  }
}

class TransactionDetailPageState extends State<TransactionDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formatter = DateFormat("EEE, MMM d, ''yy");
  final _commentTimeFormatter = DateFormat("h:mm a, EEE, MMM d, ''yy");
  final TextEditingController _commentController = TextEditingController();
  TransactionCommentsBloc? transactionCommentsBloc;

  @override
  void initState() {
    transactionCommentsBloc = TransactionCommentsBloc(
        transactionRepository:
            RepositoryProvider.of<TransactionRepository>(context));

    transactionCommentsBloc!
        .add(LoadTransactionComments(transactionId: widget.transaction!.id!));
    super.initState();
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
      child: Scaffold(
        key: _scaffoldKey,
        appBar: NeumorphicAppBar(
          title: const Text('Transaction Details'),
        ),
        body: BlocListener<TransactionDetailBloc, TransactionDetailState>(
          listener: (context, state) {
            if (state is TransactionDeleting) {
              showProgress(context);
            }

            if (state is TransactionDeleted) {
              hideProgress(context);
              Navigator.of(context).pop();
            }
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            children: <Widget>[
              _transactionDetails(),
              ListTile(
                title: Text(
                  'Comments',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              _commentTile(),
              _transactionComments(),
            ],
          ),
        ),
        bottomNavigationBar: _bottomNavigationBar(theme),
      ),
    );
  }

  Widget _bottomNavigationBar(ThemeData theme) {
    final TextStyle dialogTextStyle = theme.textTheme.subtitle1!
        .copyWith(color: theme.textTheme.caption!.color);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Hide actions if transaction created by another user
          return widget.transaction!.creatorUserName == state.user!.userName
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
                                transactionsBloc:
                                    BlocProvider.of<TransactionBloc>(context),
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
                                transactionsBloc:
                                    BlocProvider.of<TransactionBloc>(context),
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
                              child: AlertDialog(
                                  title: const Text('Delete Transaction?'),
                                  content: Text(
                                      'Are you sure you want to delete transaction "${widget.transaction!.description}" of ${widget.transaction!.amount.toMoney()}${widget.transaction!.accountCurrencySymbol}',
                                      style: dialogTextStyle),
                                  actions: <Widget>[
                                    TextButton(
                                        child: const Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(
                                              context, DialogAction.disagree);
                                        }),
                                    TextButton(
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
          return Container();
        }
      },
    );
  }

  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void showDeleteConfirmationDialog<T>(
      {required BuildContext context, Widget? child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child!,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
      if (value == DialogAction.agree) {
        widget.transactionDetailBloc
            .add(DeleteTransaction(transactionId: widget.transaction!.id!));
      }
    });
  }

  Widget _commentTile() {
    return ListTile(
      title: PrimaryColorOverride(
        child: TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Write a comment...',
            // errorText: snapshot.error
          ),
        ),
      ),
      trailing: OutlinedButton(
        onPressed: (() {
          transactionCommentsBloc!.add(PostTransactionComment(
              transactionId: widget.transaction!.id!,
              comment: _commentController.text));
          _commentController.clear();
        }),
        style: OutlinedButton.styleFrom(side: BorderSide.none),
        child: Text("Post", style: Theme.of(context).textTheme.button),
      ),
    );
  }

  Widget _transactionComments() {
    return BlocBuilder(
        bloc: transactionCommentsBloc,
        builder: (context, dynamic state) {
          if (state is TransactionCommentsLoaded) {
            return Card(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.comments.map((comment) {
                    return ListTile(
                      leading: const CircleAvatar(),
                      title: Text(comment.creatorUserName!),
                      subtitle: Text(comment.content!),
                      trailing: Text(_commentTimeFormatter
                          .format(DateTime.parse(comment.creationTime!))),
                    );
                  }).toList()),
            );
          } else {
            return const LinearProgressIndicator();
          }
          // TODO: handle transaction comments error
        });
  }

  Widget _transactionDetails() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(widget.transaction!.categoryName!),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(
                '${widget.transaction!.amount.toMoney()} ${widget.transaction!.accountCurrencySymbol}'),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: AutoSizeText(
              widget.transaction!.description!,
              maxLines: 3,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_formatter
                .format(DateTime.parse(widget.transaction!.transactionTime!))),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(widget.transaction!.accountName!),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(widget.transaction!.creatorUserName!),
          ),
        ],
      ),
    );
  }
}

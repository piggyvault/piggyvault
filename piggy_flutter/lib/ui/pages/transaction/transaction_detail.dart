import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_comment.dart';
import 'package:piggy_flutter/ui/pages/transaction/transaction_form.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  TransactionDetailPage({Key key, this.transaction}) : super(key: key);

  @override
  TransactionDetailPageState createState() {
    return new TransactionDetailPageState();
  }
}

class TransactionDetailPageState extends State<TransactionDetailPage> {
  final _formatter = DateFormat("EEE, MMM d, ''yy");
  final _commentTimeFormatter = DateFormat("h:mm a, EEE, MMM d, ''yy");
  final TextEditingController _commentController = new TextEditingController();
  // final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    // _transactionService
    //     .getTransactionForEdit(widget.transaction.id)
    //     .then((result) {
    //     });
  }

  @override
  Widget build(BuildContext context) {
    final TransactionBloc transactionBloc =
        BlocProvider.of<TransactionBloc>(context);
    // TODO - not the ideal place
    transactionBloc.transactionCommentsRefresh(widget.transaction.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: new ListView(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: <Widget>[
          _transactionDetails(),
          ListTile(
            title: Text(
              'Comments',
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          _commentTile(transactionBloc),
          _transactionComments(transactionBloc),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TransactionFormPage(
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
                    builder: (BuildContext context) => TransactionFormPage(
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentTile(TransactionBloc transactionBloc) {
    return StreamBuilder<String>(
      stream: transactionBloc.comment,
      builder: (context, snapshot) {
        return ListTile(
          title: TextField(
            controller: _commentController,
            decoration: new InputDecoration(
                labelText: 'Write a comment...', errorText: snapshot.error),
            onChanged: transactionBloc.changeComment,
          ),
          trailing: new OutlineButton(
            onPressed: (() {
              if (snapshot.hasData && snapshot.data != null) {
                transactionBloc.submitComment(widget.transaction.id);
                _commentController.clear();
              }
            }),
            borderSide: BorderSide.none,
            child: new Text("Post"),
          ),
        );
      },
    );
  }

  Widget _transactionComments(TransactionBloc transactionBloc) {
    return StreamBuilder<List<TransactionComment>>(
        stream: transactionBloc.transactionComments,
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
                      trailing: Text('${_commentTimeFormatter.format(
                  DateTime.parse(comment.creationTime))}'),
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
                '${widget.transaction.amount.toString()} ${widget.transaction
                  .accountCurrencySymbol}'),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            subtitle: Text(widget.transaction.description),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('${_formatter.format(
                  DateTime.parse(widget.transaction.transactionTime))}'),
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

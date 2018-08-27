import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';

import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/models/category_list_item.dart';
import 'package:piggy_flutter/models/recent_transactions_state.dart';
import 'package:piggy_flutter/ui/screens/category/category_form.dart';
import 'package:piggy_flutter/ui/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/ui/widgets/common/message_placeholder.dart';
import 'package:piggy_flutter/utils/common.dart';
import 'package:rxdart/rxdart.dart';

class CategoryListPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final CategoryBloc categoryBloc = BlocProvider.of<CategoryBloc>(context);
    final TransactionBloc transactionBloc =
        BlocProvider.of<TransactionBloc>(context);

    Stream<List<CategoryListItem>> categoriesWithTransactionCount = Observable
        .combineLatest2(
            categoryBloc.categories, transactionBloc.recentTransactionsState,
            (List<Category> categories,
                RecentTransactionsState recentTransactionsState) {
      return categories
          .map<CategoryListItem>((category) => CategoryListItem(
              category: category,
              noOfTransactions:
                  recentTransactionsState is RecentTransactionsPopulated
                      ? recentTransactionsState.result.transactions
                          .where((transaction) =>
                              transaction.categoryName == category.name)
                          .length
                      : 0))
          .toList();
    }).asBroadcastStream();

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Categories'),
      ),
      body: _categoryListBuilder(categoriesWithTransactionCount),
      drawer: CommonDrawer(),
      floatingActionButton: FloatingActionButton(
          key: ValueKey<Color>(Theme.of(context).buttonColor),
          tooltip: 'Add new category',
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => CategoryFormPage(
                        title: "Add Category",
                      ),
                  fullscreenDialog: true,
                ));
          }),
    );
  }

  Widget _categoryListBuilder(Stream<List<CategoryListItem>> stream) =>
      StreamBuilder<List<CategoryListItem>>(
          stream: stream,
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final categories = snapshot.data;
              if (categories.length > 0) {
                Iterable<Widget> categoryTiles = categories.map((category) {
                  return MergeSemantics(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(category.category.name
                            .substring(0, 1)
                            .toUpperCase()),
                      ),
                      title: Text(category.category.name),
                      subtitle: category.noOfTransactions > 0
                          ? Text(
                              '${category.noOfTransactions} transactions recently')
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute<DismissDialogAction>(
                                builder: (BuildContext context) =>
                                    CategoryFormPage(
                                      category: category.category,
                                      title: 'Edit Category',
                                    ),
                                fullscreenDialog: true,
                              ));
                        },
                      ),
                    ),
                  );
                });
                return ListView(children: categoryTiles.toList());
              } else {
                return MessagePlaceholder();
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          });
}

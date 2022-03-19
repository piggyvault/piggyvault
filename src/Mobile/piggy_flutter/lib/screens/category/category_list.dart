import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/category/category_detail.dart';
import 'package:piggy_flutter/screens/category/category_form.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/widgets/common/message_placeholder.dart';
import 'package:piggy_flutter/utils/common.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: _categoryListBuilder(),
      drawer: CommonDrawer(
        animationController: animationController,
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey<Color>(Theme.of(context).buttonColor),
          tooltip: 'Add new category',
          backgroundColor: PiggyAppTheme.nearlyDarkBlue,
          child: Icon(Icons.add, color: Theme.of(context).primaryColor),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => CategoryFormPage(
                    title: 'Add Category',
                    categoriesBloc: BlocProvider.of<CategoriesBloc>(context),
                  ),
                  fullscreenDialog: true,
                ));
          }),
    );
  }

  Widget _categoryListBuilder() => BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (BuildContext context, CategoriesState state) {
        if (state is CategoriesLoaded) {
          if (state.categories.isNotEmpty) {
            final Iterable<Widget> categoryTiles =
                state.categories.map((Category category) {
              return MergeSemantics(
                child: ListTile(
                  leading: CircleAvatar(
                      // child: Icon(
                      //   deserializeIcon(Map<String, dynamic>.from(
                      //       json.decode(category.icon))),
                      //   color: PiggyAppTheme.nearlyDarkBlue,
                      // ),
                      ),
                  title: Text(category.name!),
                  // subtitle: category.noOfTransactions > 0
                  //     ? Text(
                  //         '${category.noOfTransactions} transactions recently')
                  //     : null,

                  onTap: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute<CategoryDetailPage>(
                      builder: (BuildContext context) => CategoryDetailPage(
                        animationController: animationController,
                        category: category,
                        transactionRepository:
                            RepositoryProvider.of<TransactionRepository>(
                                context),
                      ),
                      fullscreenDialog: true,
                    ));
                  },
                ),
              );
            });
            return ListView(children: categoryTiles.toList());
          } else {
            return MessagePlaceholder();
          }
        }
        return const Center(child: CircularProgressIndicator());
      });
}

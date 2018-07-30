import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/providers/category_provider.dart';
import 'package:piggy_flutter/ui/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/ui/widgets/common/message_placeholder.dart';

class CategoryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('########## CategoryListPage  build');
    final categoryBloc = CategoryProvider.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Categories'),
      ),
      body: categoryListBuilder(categoryBloc),
      drawer: CommonDrawer(),
    );
  }

  Widget categoryListBuilder(categoryBloc) => StreamBuilder<List<Category>>(
        stream: categoryBloc.categories,
        initialData: null,
        builder: (context, snapshot) =>
            CategoryListWidget(snapshot.hasData ? snapshot.data : null),
      );
}

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (categories.length > 0) {
        Iterable<Widget> categoryTiles = categories.map((category) {
          return MergeSemantics(
            child: new ListTile(
//              dense: true,
              leading: new CircleAvatar(),
              title: new Text(category.name),
            ),
          );
        });
        return ListView(children: categoryTiles.toList());
      } else {
        return MessagePlaceholder();
      }
    }
  }

  CategoryListWidget(this.categories);
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';

import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/ui/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/ui/widgets/common/message_placeholder.dart';

class CategoryListPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final CategoryBloc categoryBloc = BlocProvider.of<CategoryBloc>(context);
    return new Scaffold(
      key: _scaffoldKey,
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

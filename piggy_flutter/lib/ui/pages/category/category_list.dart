import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';

import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/ui/pages/category/category_form.dart';
import 'package:piggy_flutter/ui/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/ui/widgets/common/message_placeholder.dart';
import 'package:piggy_flutter/utils/common.dart';

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
      body: _categoryListBuilder(categoryBloc),
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

  Widget _categoryListBuilder(categoryBloc) => StreamBuilder<List<Category>>(
      stream: categoryBloc.categories,
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final categories = snapshot.data;
          if (categories.length > 0) {
            Iterable<Widget> categoryTiles = categories.map((category) {
              return MergeSemantics(
                child: new ListTile(
                  leading: new CircleAvatar(
                    child: Text(category.name.substring(0, 1).toUpperCase()),
                  ),
                  title: new Text(category.name),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute<DismissDialogAction>(
                            builder: (BuildContext context) => CategoryFormPage(
                                  category: category,
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

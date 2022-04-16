import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
        appBar: NeumorphicAppBar(
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
      ),
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
                  leading: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: NeumorphicIcon(
                      deserializeIcon(Map<String, dynamic>.from(
                          json.decode(category.icon!)))!,
                      style: const NeumorphicStyle(
                        shape: NeumorphicShape.convex,
                        surfaceIntensity: 1.0,
                      ),
                    ),
                  ),
                  title: Text(category.name!),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    this.category,
    Key key,
    @required this.title,
    @required this.categoriesBloc,
  }) : super(key: key);

  final Category category;
  final CategoriesBloc categoriesBloc;
  final String title;

  @override
  CategoryFormPageState createState() => CategoryFormPageState();
}

class CategoryFormPageState extends State<CategoryFormPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _autoValidate = false;
  final bool _formWasEdited = false;

  TextEditingController _categorynameFieldController;

  @override
  void initState() {
    super.initState();

    if (widget.category == null) {
      _categorynameFieldController = TextEditingController();
    } else {
      _categorynameFieldController =
          TextEditingController(text: widget.category.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[submitButton(theme)],
      ),
      body: BlocListener<CategoriesBloc, CategoriesState>(
        listener: (BuildContext context, CategoriesState state) {
          if (state is CategoriesLoading) {
            showProgress(context);
          }

          if (state is CategorySaved) {
            hideProgress(context);
            showSuccess(
                context: context,
                message: UIData.success,
                icon: MaterialCommunityIcons.check);
          }
        },
        child: DropdownButtonHideUnderline(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              onWillPop: _onWillPop,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  _categoryField(theme),
                  const SizedBox(height: 24.0),
                  Text('* all fields are mandatory',
                      style: Theme.of(context).textTheme.caption),
                ].where((child) => child != null).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _categorynameFieldController?.dispose();
    super.dispose();
  }

  Widget _categoryField(ThemeData theme) {
    return PrimaryColorOverride(
      child: TextField(
        controller: _categorynameFieldController,
        decoration: const InputDecoration(
          labelText: 'Category name',
          border: OutlineInputBorder(),
          // errorText: snapshot.error
        ),
        style: theme.textTheme.headline,
      ),
    );
  }

  Widget submitButton(ThemeData theme) {
    return FlatButton(
      child: Text('SAVE', style: theme.textTheme.button),
      onPressed: () {
        saveCategory();
      },
    );
  }

  void saveCategory() {
    Category category;

    if (widget.category == null) {
      category = Category(id: null, icon: 'icon-question');
    } else {
      category = widget.category;
    }

    category.name = _categorynameFieldController.text;
    widget.categoriesBloc.add(CategorySave(category: category));
  }

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard unsaved changes?', style: dialogTextStyle),
              actions: <Widget>[
                FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                FlatButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        ) ??
        false;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }
}

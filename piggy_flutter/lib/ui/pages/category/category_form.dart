import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/ui/pages/category/category_form_bloc.dart';
import 'package:piggy_flutter/ui/widgets/api_subscription.dart';

class CategoryFormPage extends StatefulWidget {
  final Category category;
  final String title;

  CategoryFormPage({
    Key key,
    @required this.title,
    this.category,
  }) : super(key: key);

  @override
  CategoryFormPageState createState() => CategoryFormPageState();
}

class CategoryFormPageState extends State<CategoryFormPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _formWasEdited = false;

  StreamSubscription<ApiRequest> _apiStreamSubscription;
  CategoryFormBloc _bloc;
  TextEditingController _categorynameFieldController;
  @override
  void initState() {
    super.initState();
    _bloc = CategoryFormBloc(category: widget.category);
    if (widget.category == null) {
      _categorynameFieldController = TextEditingController();
    } else {
      _categorynameFieldController =
          TextEditingController(text: widget.category.name);
    }
    _apiStreamSubscription = apiSubscription(_bloc.state, context);
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
      body: DropdownButtonHideUnderline(
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
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _apiStreamSubscription?.cancel();
    _categorynameFieldController?.dispose();
    _bloc?.dispose();
    super.dispose();
  }

  Widget _categoryField(ThemeData theme) {
    return StreamBuilder(
      stream: _bloc.categoryName,
      builder: (context, snapshot) {
        return Container(
          child: TextField(
            controller: _categorynameFieldController,
            decoration: InputDecoration(
                labelText: 'Category name',
                filled: true,
                errorText: snapshot.error),
            style: theme.textTheme.headline,
            onChanged: _bloc.changeCategoryName,
          ),
        );
      },
    );
  }

  Widget submitButton(ThemeData theme) {
    return StreamBuilder(
      stream: _bloc.categoryName,
      builder: (context, snapshot) {
        return FlatButton(
          child: Text('SAVE',
              style: theme.textTheme.body1.copyWith(color: Colors.white)),
          onPressed: snapshot.hasData ? _bloc.submit : null,
        );
      },
    );
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

import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    this.category,
    Key? key,
    required this.title,
    required this.categoriesBloc,
  }) : super(key: key);

  final Category? category;
  final CategoriesBloc categoriesBloc;
  final String title;

  @override
  CategoryFormPageState createState() => CategoryFormPageState();
}

class CategoryFormPageState extends State<CategoryFormPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _formWasEdited = false;

  TextEditingController? _categoryNameFieldController;

  Icon? _icon;

  _pickIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(context,
        iconPackModes: [IconPack.fontAwesomeIcons]);

    if (icon != null) {
      _icon = Icon(icon);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.category == null) {
      _categoryNameFieldController = TextEditingController();
      _icon = Icon(deserializeIcon(Map<String, dynamic>.from(
          json.decode('{"pack":"fontAwesomeIcons","key":"question"}'))));
      setState(() {});
    } else {
      _categoryNameFieldController =
          TextEditingController(text: widget.category!.name);
      _icon = Icon(deserializeIcon(
          Map<String, dynamic>.from(json.decode(widget.category!.icon!))));
    }
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
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: NeumorphicAppBar(
            title: Text(widget.title),
          ),
          body: BlocListener<CategoriesBloc, CategoriesState>(
            listener: (BuildContext context, CategoriesState state) {
              if (state is CategorySaveFailure) {
                hideProgress(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onWillPop: _onWillPop,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Material(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1.0),
                                child: IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _icon,
                                  ),
                                  onPressed: _pickIcon,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: _categoryField(theme),
                            ),
                          ],
                        ),
                        width: double.infinity,
                      ),
                      const SizedBox(height: 24.0),
                      NeumorphicButton(
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 18),
                        child: const Center(
                          child: Text("SAVE",
                              style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        onPressed: () {
                          saveCategory();
                        },
                      ),
                      const SizedBox(height: 24.0),
                      Text('* all fields are mandatory',
                          style: Theme.of(context).textTheme.caption),
                    ].toList(),
                  ),
                ),
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
    _categoryNameFieldController?.dispose();
    super.dispose();
  }

  Widget _categoryField(ThemeData theme) {
    return PrimaryColorOverride(
      child: TextField(
        controller: _categoryNameFieldController,
        decoration: const InputDecoration(
          labelText: 'Category name',
          border: OutlineInputBorder(),
          // errorText: snapshot.error
        ),
        style: theme.textTheme.headline5,
      ),
    );
  }

  void saveCategory() {
    Category? category;

    if (widget.category == null) {
      category = Category(
          id: null, icon: '{"pack":"fontAwesomeIcons","key":"question"}');
    } else {
      category = widget.category;
    }

    category!.name = _categoryNameFieldController!.text;
    if (_icon != null) {
      category.icon = json.encode(serializeIcon(_icon!.icon!));
    }
    widget.categoriesBloc.add(CategorySave(category: category));
  }

  Future<bool> _onWillPop() async {
    if (!_formWasEdited) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subtitle1!
        .copyWith(color: theme.textTheme.caption!.color);

    return await (showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard unsaved changes?', style: dialogTextStyle),
              actions: <Widget>[
                TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                TextButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        ) as FutureOr<bool>?) ??
        false;
  }

  void showInSnackBar(String value) {
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }
}

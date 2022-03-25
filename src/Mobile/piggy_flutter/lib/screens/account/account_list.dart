import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/screens/account/account_group_list.dart';
import 'package:piggy_flutter/theme/theme.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController? animationController;

  @override
  _AccountListPageState createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage>
    with TickerProviderStateMixin {
  late Animation<double> topBarAnimation;
  late Animation<double> listAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  List<Widget> listViews = <Widget>[];

  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    _refreshCompleter = Completer<void>();

    super.initState();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PiggyAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          widget.animationController!.forward();
          return AnimatedBuilder(
            animation: widget.animationController!,
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: listAnimation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - listAnimation.value), 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: AppBar().preferredSize.height +
                            MediaQuery.of(context).padding.top,
                        bottom: 62 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: BlocBuilder<AccountsBloc, AccountsState>(
                        builder: (BuildContext context, AccountsState state) {
                          if (state is AccountsLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is AccountsLoaded) {
                            _refreshCompleter?.complete();
                            _refreshCompleter = Completer<void>();

                            return RefreshIndicator(
                              key: _refreshIndicatorKey,
                              onRefresh: () {
                                BlocProvider.of<AccountsBloc>(context)
                                    .add(LoadAccounts());
                                return _refreshCompleter!.future;
                              },
                              child: ListView(
                                controller: scrollController,
                                children: <Widget>[
                                  AccountGroupList(
                                      animationController:
                                          widget.animationController,
                                      accounts: state.userAccounts,
                                      title: 'Your Accounts'),
                                  AccountGroupList(
                                      animationController:
                                          widget.animationController,
                                      accounts: state.familyAccounts,
                                      title: 'Family Accounts')
                                ],
                              ),
                            );
                          }
                          return const Center(child: Text('Accounts'));
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: PiggyAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: PiggyAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Accounts',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: PiggyAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: PiggyAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

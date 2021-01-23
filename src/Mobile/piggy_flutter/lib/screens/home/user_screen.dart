import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/auth/auth_bloc.dart';
import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/screens/reports/reports_screen.dart';
import 'package:piggy_flutter/screens/settings/settings_screen.dart';
import 'package:piggy_flutter/theme/theme.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:styled_widget/styled_widget.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key key, @required this.animationController})
      : super(key: key);

  final AnimationController animationController;

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with TickerProviderStateMixin {
  Animation<double> topBarAnimation;
  double topBarOpacity = 0.0;
  Animation<double> bodyAnimation;
  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    bodyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

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

    addAllListData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PiggyAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI().padding(horizontal: 20),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  void addAllListData() {
    const int count = 3;

    listViews.add(UserCard(
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: widget.animationController,
          curve: Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn),
        ),
      ),
      animationController: widget.animationController,
    ).padding(bottom: 15));

    listViews.add(Settings(
      animationController: widget.animationController,
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: widget.animationController,
          curve: Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn),
        ),
      ),
    ));
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
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return listViews[index];
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
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
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
                                child: BlocBuilder<AuthBloc, AuthState>(builder:
                                    (BuildContext context, AuthState state) {
                                  if (state is AuthAuthenticated) {
                                    return Text(
                                      '${state.tenant.tenancyName}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: PiggyAppTheme.fontName,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22 + 6 - 6 * topBarOpacity,
                                        letterSpacing: 1.2,
                                        color: PiggyAppTheme.darkerText,
                                      ),
                                    );
                                  }
                                  return Text(
                                    'User not logged in',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: PiggyAppTheme.fontName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22 + 6 - 6 * topBarOpacity,
                                      letterSpacing: 1.2,
                                      color: PiggyAppTheme.darkerText,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    // child: Icon(
                                    //   Icons.calendar_today,
                                    //   color: PiggyAppTheme.grey,
                                    //   size: 18,
                                    // ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      focusColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.grey.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4.0),
                                      ),
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        // // setState(() {
                                        // //   isDatePopupOpen = true;
                                        // // });
                                        // showDemoDialog(
                                        //     context: context,
                                        //     bloc: recentTransactionsBloc);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 4,
                                            bottom: 4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // Text(
                                            //   '${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}',
                                            //   textAlign: TextAlign.left,
                                            //   style: TextStyle(
                                            //     fontFamily:
                                            //         PiggyAppTheme.fontName,
                                            //     fontWeight: FontWeight.normal,
                                            //     fontSize: 18,
                                            //     letterSpacing: -0.2,
                                            //     color:
                                            //         PiggyAppTheme.darkerText,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
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

class UserCard extends StatelessWidget {
  const UserCard(
      {Key key, @required this.animationController, @required this.animation})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  Widget _buildUserRow() {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
      if (state is AuthAuthenticated) {
        return <Widget>[
          Icon(Icons.account_circle)
              .decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              )
              .constrained(height: 50, width: 50)
              .padding(right: 10),
          <Widget>[
            Text('${state.user.name} ${state.user.surname}')
                .textColor(Colors.white)
                .fontSize(18)
                .fontWeight(FontWeight.w600)
                .padding(bottom: 5),
            Text(state.user.emailAddress)
                .textColor(Colors.white.withOpacity(0.6))
                .fontSize(12),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
        ].toRow();
      }

      return const Text('User not logged in');
    });
  }

  Widget _buildUserStats() {
    return <Widget>[
      BlocBuilder<AccountsBloc, AccountsState>(builder: (context, state) {
        if (state is AccountsLoaded) {
          return _buildUserStatsItem(
              state.userAccounts.length.toString(), 'Accounts');
        }
        return _buildUserStatsItem('-', 'Accounts');
      }),
      BlocBuilder<CategoriesBloc, CategoriesState>(builder: (context, state) {
        if (state is CategoriesLoaded) {
          return _buildUserStatsItem(
              state.categories.length.toString(), 'Categories');
        }
        return _buildUserStatsItem('-', 'Categories');
      })

      // _buildUserStatsItem('267', 'Track'),
      // _buildUserStatsItem('39', 'Coupons'),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .padding(vertical: 10);
  }

  Widget _buildUserStatsItem(String value, String text) => <Widget>[
        Text(value).fontSize(20).textColor(Colors.white).padding(bottom: 5),
        Text(text).textColor(Colors.white.withOpacity(0.6)).fontSize(12),
      ].toColumn();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: animation,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - animation.value), 0.0),
                  child: <Widget>[_buildUserRow(), _buildUserStats()]
                      .toColumn(
                          mainAxisAlignment: MainAxisAlignment.spaceAround)
                      .padding(horizontal: 20, vertical: 10)
                      .decorated(
                          color: Color(0xff3977ff),
                          borderRadius: BorderRadius.circular(20))
                      .elevation(
                        5,
                        shadowColor: Color(0xff3977ff),
                        borderRadius: BorderRadius.circular(20),
                      )
                      .height(175)
                      .alignment(Alignment.center)));
        });
  }
}

class ActionsRow extends StatelessWidget {
  Widget _buildActionItem(String name, IconData icon) {
    final Widget actionIcon = Icon(icon)
        .iconSize(20)
        .iconColor(Color(0xFF42526F))
        .alignment(Alignment.center)
        .ripple()
        .constrained(width: 50, height: 50)
        .backgroundColor(Color(0xfff6f5f8))
        .clipOval()
        .padding(bottom: 5);

    final Widget actionText =
        Text(name).textColor(Colors.black.withOpacity(0.8)).fontSize(12);

    return <Widget>[
      actionIcon,
      actionText,
    ].toColumn().padding(vertical: 20);
  }

  @override
  Widget build(BuildContext context) => <Widget>[
        _buildActionItem('Wallet', Icons.attach_money),
        _buildActionItem('Delivery', Icons.card_giftcard),
        _buildActionItem('Message', Icons.message),
        _buildActionItem('Service', Icons.room_service),
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceAround);
}

class SettingsItemModel {
  const SettingsItemModel(
      {@required this.color,
      @required this.description,
      @required this.icon,
      @required this.title});

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}

const List<SettingsItemModel> settingsItems = [
  SettingsItemModel(
    icon: Icons.insert_chart,
    color: Color(0xff8D7AEE),
    title: UIData.reports,
    description: 'See all available reports',
  ),
  SettingsItemModel(
    icon: Icons.settings,
    color: Color(0xffF468B7),
    title: UIData.settings,
    description: 'Default currency, notifications etc',
  ),
  // SettingsItemModel(
  //   icon: Icons.menu,
  //   color: Color(0xffFEC85C),
  //   title: 'General',
  //   description: 'Basic functional settings',
  // ),
  // SettingsItemModel(
  //   icon: Icons.notifications,
  //   color: Color(0xff5FD0D3),
  //   title: 'Notifications',
  //   description: 'Take over the news in time',
  // ),
  // SettingsItemModel(
  //   icon: Icons.question_answer,
  //   color: Color(0xffBFACAA),
  //   title: 'Support',
  //   description: 'We are here to help',
  // ),
];

class Settings extends StatelessWidget {
  const Settings(
      {Key key, @required this.animationController, @required this.animation})
      : super(key: key);
  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => settingsItems
      .map(
        (SettingsItemModel settingsItem) {
          return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - animation.value), 0.0),
                  child: SettingsItem(
                      settingsItem.icon,
                      settingsItem.color,
                      settingsItem.title,
                      settingsItem.description,
                      animationController),
                ),
              );
            },
          );
        },
      )
      .toList()
      .toColumn();
}

class SettingsItem extends StatefulWidget {
  const SettingsItem(this.icon, this.iconBgColor, this.title, this.description,
      this.animationController);

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String description;
  final AnimationController animationController;

  @override
  _SettingsItemState createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final settingsItem = ({Widget child}) => Styled.widget(child: child)
        .alignment(Alignment.center)
        .borderRadius(all: 15)
        .ripple()
        .backgroundColor(Colors.white, animate: true)
        .clipRRect(all: 25) // clip ripple
        .borderRadius(all: 25, animate: true)
        .elevation(
          pressed ? 0 : 20,
          borderRadius: BorderRadius.circular(25),
          shadowColor: Color(0x30000000),
        ) // shadow borderRadius
        .constrained(height: 80)
        .padding(vertical: 12) // margin
        .gestures(
          onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
          onTapDown: (details) => print('tapDown'),
          onTap: () async {
            if (widget.title == UIData.reports) {
              Navigator.of(context).push<void>(
                MaterialPageRoute<ReportsScreen>(
                  builder: (BuildContext context) => ReportsScreen(
                    animationController: widget.animationController,
                  ),
                ),
              );
            }
            if (widget.title == UIData.settings) {
              Navigator.of(context).push(
                MaterialPageRoute<SettingsScreen>(
                  builder: (BuildContext context) => SettingsScreen(
                      animationController: widget.animationController),
                ),
              );
            }
          },
        )
        .scale(all: pressed ? 0.95 : 1.0, animate: true)
        .animate(const Duration(milliseconds: 150), Curves.easeOut);

    final Widget icon = Icon(widget.icon)
        .iconColor(Colors.white)
        .iconSize(20)
        .padding(all: 12)
        .decorated(
          color: widget.iconBgColor,
          borderRadius: BorderRadius.circular(30),
        )
        .padding(left: 15, right: 10);

    final Widget title =
        Text(widget.title).bold().fontSize(16).padding(bottom: 5);

    final Widget description =
        Text(widget.description).textColor(Colors.black26).bold().fontSize(12);

    return settingsItem(
      child: <Widget>[
        icon,
        <Widget>[
          title,
          description,
        ].toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ].toRow(),
    );
  }
}

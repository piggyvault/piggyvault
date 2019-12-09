import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/dashboard/dashboard_page.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/screens/account/account_list.dart';
import 'package:piggy_flutter/screens/home/overview_screen.dart';
import 'package:piggy_flutter/screens/home/recent_transactions.dart';
import 'package:piggy_flutter/screens/transaction/transaction_detail.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';
import 'package:piggy_flutter/widgets/common/common.dart';

import '../fintness_app_theme.dart';
import 'bottom_bar_view.dart';

class TabIconData {
  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  int index;

  AnimationController animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/images/tab_1.png',
      selectedImagePath: 'assets/images/tab_1s.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/tab_2.png',
      selectedImagePath: 'assets/images/tab_2s.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/tab_3.png',
      selectedImagePath: 'assets/images/tab_3s.png',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/tab_4.png',
      selectedImagePath: 'assets/images/tab_4s.png',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}

class HomeScreen extends StatefulWidget {
  final StartPage startpage;

  HomeScreen({Key key, this.startpage = StartPage.Dashboard}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: PiggyAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    if (widget.startpage == StartPage.Dashboard) {
      tabBody = OverviewScreen(animationController: animationController);
    } else if (widget.startpage == StartPage.Accounts) {
      tabBody = AccountListPage();
    }

    initPlatformState();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FintnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
        drawer: CommonDrawer(
          animationController: animationController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // print(
      //     "########## Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
      var transactionData = result.notification.payload.additionalData;
      try {
        var transaction = Transaction(
            id: transactionData['TransactionId'],
            transactionTime: transactionData['TransactionTime'],
            description: transactionData['Description'],
            amount: double.tryParse(transactionData['Amount']),
            categoryName: transactionData['CategoryName'],
            creatorUserName: transactionData['CreatorUserName'],
            accountName: transactionData['AccountName']);
        // TODO: get data from Id rather than sending over notification
        // print(
        //     "########## Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
        Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (BuildContext context) => TransactionDetailPage(
                transaction: transaction,
                transactionDetailBloc:
                    BlocProvider.of<TransactionDetailBloc>(context),
              ),
              fullscreenDialog: true,
            ));
      } catch (e) {
        print(e);
      }
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () => Navigator.of(context).push(
            MaterialPageRoute<DismissDialogAction>(
              builder: (_) => TransactionFormPage(
                transactionsBloc: BlocProvider.of<TransactionBloc>(context),
              ),
            ),
          ),
          changeIndex: (int index) {
            if (index == 0) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      OverviewScreen(animationController: animationController);
                });
              });
            } else if (index == 1) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = RecentTransactionsPage(
                    animationController: animationController,
                  );
                });
              });
            } else if (index == 2) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = AccountListPage();
                });
              });
            } else if (index == 3) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = DashboardPage();
                  // TrainingScreen(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }
}

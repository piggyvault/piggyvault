import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/categorywise_recent_months_report/bloc.dart';
import 'package:piggy_flutter/blocs/categorywise_recent_months_report/categorywise_recent_months_report_bloc.dart';
import 'package:piggy_flutter/models/category_wise_recent_months_report_item.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/utils/common.dart';

class CategoryWiseRecentMonthsReportScreen extends StatefulWidget {
  const CategoryWiseRecentMonthsReportScreen(
      {Key? key, required this.animationController})
      : super(key: key);

  final AnimationController? animationController;

  static const String routeName =
      '/reports/categorywise-recent-months-report-screen';

  @override
  _CategoryWiseRecentMonthsReportScreenState createState() =>
      _CategoryWiseRecentMonthsReportScreenState();
}

class _CategoryWiseRecentMonthsReportScreenState
    extends State<CategoryWiseRecentMonthsReportScreen> {
  CategorywiseRecentMonthsReportBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CategorywiseRecentMonthsReportBloc(
        reportRepository: RepositoryProvider.of<ReportRepository>(context));
    _bloc!.add(CategorywiseRecentMonthsReportLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorywise Recent Months')),
      body: BlocBuilder<CategorywiseRecentMonthsReportBloc,
          CategorywiseRecentMonthsReportState>(
        bloc: _bloc,
        builder:
            (BuildContext context, CategorywiseRecentMonthsReportState state) {
          if (state is CategorywiseRecentMonthsReportLoaded) {
            return ListView(children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    onSelectAll: (b) {},
                    sortColumnIndex: 0,
                    sortAscending: true,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Category'),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text('3 Months Ago'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Last Month'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('This Month'),
                        numeric: true,
                      ),
                    ],
                    rows: state.result
                        .map(
                          (CategoryWiseRecentMonthsReportItem item) => DataRow(
                            cells: [
                              DataCell(
                                Text(item.categoryName!),
                                showEditIcon: false,
                                placeholder: false,
                              ),
                              DataCell(
                                Text(item.datasets[0].total.toMoney()),
                                showEditIcon: false,
                                placeholder: false,
                              ),
                              DataCell(
                                Text(item.datasets[1].total.toMoney()),
                                showEditIcon: false,
                                placeholder: false,
                              ),
                              DataCell(
                                Text(item.datasets[2].total.toMoney()),
                                showEditIcon: false,
                                placeholder: false,
                              )
                            ],
                          ),
                        )
                        .toList()),
              )
            ]);
          }
          return const LoadingWidget(
            visible: true,
          );
        },
      ),
      drawer: CommonDrawer(
        animationController: widget.animationController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

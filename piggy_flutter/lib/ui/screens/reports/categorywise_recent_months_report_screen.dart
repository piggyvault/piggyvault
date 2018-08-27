import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:piggy_flutter/ui/screens/reports/reports_bloc.dart';
import 'package:piggy_flutter/ui/widgets/common/common_drawer.dart';
import 'package:piggy_flutter/ui/widgets/common/loading_widget.dart';

class Dataset {
  final double total;
  Dataset(this.total);

  Dataset.fromJson(Map<String, dynamic> json) : total = json['total'];
}

class CategoryWiseRecentMonthsReportItem {
  final String categoryName;
  final List<Dataset> datasets;

  CategoryWiseRecentMonthsReportItem(this.categoryName, this.datasets);

  CategoryWiseRecentMonthsReportItem.fromJson(Map<String, dynamic> json)
      : categoryName = json['categoryName'],
        datasets =
            (json['datasets'] as List).map((i) => Dataset.fromJson(i)).toList();
}

class CategoryWiseRecentMonthsReportScreen extends StatefulWidget {
  static const String routeName =
      '/reports/categorywise-recent-months-report-screen';

  @override
  _CategoryWiseRecentMonthsReportScreenState createState() =>
      new _CategoryWiseRecentMonthsReportScreenState();
}

class _CategoryWiseRecentMonthsReportScreenState
    extends State<CategoryWiseRecentMonthsReportScreen> {
  final ReportsBloc _bloc = ReportsBloc();

  Widget bodyData() => StreamBuilder<List<CategoryWiseRecentMonthsReportItem>>(
        stream: _bloc.categoryWiseTransactionSummaryHistory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  onSelectAll: (b) {},
                  sortColumnIndex: 0,
                  sortAscending: true,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text("Category"),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text("3 Months Ago"),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text("Last Month"),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text("This Month"),
                      numeric: true,
                    ),
                  ],
                  rows: snapshot.data
                      .map(
                        (item) => DataRow(
                              cells: [
                                DataCell(
                                  Text(item.categoryName),
                                  showEditIcon: false,
                                  placeholder: false,
                                ),
                                DataCell(
                                  Text(item.datasets[0].total.toString()),
                                  showEditIcon: false,
                                  placeholder: false,
                                ),
                                DataCell(
                                  Text(item.datasets[1].total.toString()),
                                  showEditIcon: false,
                                  placeholder: false,
                                ),
                                DataCell(
                                  Text(item.datasets[2].total.toString()),
                                  showEditIcon: false,
                                  placeholder: false,
                                )
                              ],
                            ),
                      )
                      .toList()),
            );
          } else {
            return LoadingWidget(
              visible: true,
            );
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorywise Recent Months')),
      body: bodyData(),
      drawer: CommonDrawer(),
    );
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}

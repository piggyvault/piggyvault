import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class CategoryTransactionsBloc
    extends Bloc<CategoryTransactionsEvent, CategoryTransactionsState> {
  CategoryTransactionsBloc(
      {required this.transactionRepository, required this.transactionBloc})
      : assert(transactionRepository != null),
        assert(transactionBloc != null),
        super(CategoryTransactionsEmpty(null)) {
    transactionBlocSubscription = transactionBloc.stream.listen((state) {
      if (state is TransactionSaved) {
        if (this.state.filters != null) {
          add(FetchCategoryTransactions(input: this.state.filters!));
        }
      }
    });
  }
  final TransactionRepository transactionRepository;

  final TransactionBloc transactionBloc;
  late StreamSubscription transactionBlocSubscription;

  @override
  Stream<CategoryTransactionsState> mapEventToState(
    CategoryTransactionsEvent event,
  ) async* {
    if (event is FetchCategoryTransactions) {
      yield CategoryTransactionsLoading(event.input);

      try {
        final TransactionsResult result =
            await transactionRepository.getTransactions(event.input);
        if (result.isEmpty) {
          yield CategoryTransactionsEmpty(event.input);
        } else {
          yield CategoryTransactionsLoaded(
              allCategoryTransactions: result,
              filterdCategoryTransactions: result,
              filters: event.input);
        }
      } catch (e) {
        yield CategoryTransactionsError(event.input);
      }
    } else if (event is FilterCategoryTransactions) {
      if (state is CategoryTransactionsLoaded) {
        if (event.query == null || event.query == '') {
          yield CategoryTransactionsLoaded(
              allCategoryTransactions:
                  (state as CategoryTransactionsLoaded).allCategoryTransactions,
              filterdCategoryTransactions:
                  (state as CategoryTransactionsLoaded).allCategoryTransactions,
              filters: state.filters);
        } else {
          final List<Transaction> filteredTransactions =
              (state as CategoryTransactionsLoaded)
                  .allCategoryTransactions
                  .transactions
                  .where((Transaction t) => t.description!
                      .toLowerCase()
                      .contains(event.query.toLowerCase()))
                  .toList();
          final TransactionsResult filteredTransactionsResult =
              TransactionsResult(
                  sections: transactionRepository.groupTransactions(
                      transactions: filteredTransactions,
                      groupBy: TransactionsGroupBy.Date),
                  transactions: filteredTransactions);

          yield CategoryTransactionsLoaded(
              allCategoryTransactions:
                  (state as CategoryTransactionsLoaded).allCategoryTransactions,
              filterdCategoryTransactions: filteredTransactionsResult,
              filters: state.filters);
        }
      }
    }
  }

  @override
  Future<void> close() {
    transactionBlocSubscription.cancel();
    return super.close();
  }
}

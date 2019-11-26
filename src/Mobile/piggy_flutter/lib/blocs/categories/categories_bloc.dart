import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';

import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/repositories/category_repository.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository categoryRepository;

  final AuthBloc authBloc;
  StreamSubscription authBlocSubscription;

  CategoriesBloc({@required this.categoryRepository, @required this.authBloc})
      : assert(categoryRepository != null),
        assert(authBloc != null) {
    authBlocSubscription = authBloc.listen((state) {
      if (state is AuthAuthenticated) {
        add(LoadCategories());
      }
    });
  }

  @override
  CategoriesState get initialState => CategoriesLoading();

  @override
  Stream<CategoriesState> mapEventToState(
    CategoriesEvent event,
  ) async* {
    if (event is LoadCategories) {
      yield* _mapLoadCategoriesToState();
    }
  }

  Stream<CategoriesState> _mapLoadCategoriesToState() async* {
    try {
      final categories = await categoryRepository.getTenantCategories();
      yield CategoriesLoaded(categories);
    } catch (e) {
      CategoriesNotLoaded();
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }
}

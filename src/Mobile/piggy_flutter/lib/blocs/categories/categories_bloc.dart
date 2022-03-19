import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';

import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/category_repository.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({required this.categoryRepository, required this.authBloc})
      : assert(categoryRepository != null),
        assert(authBloc != null),
        super(CategoriesLoading()) {
    authBlocSubscription = authBloc.stream.listen((AuthState state) {
      if (state is AuthAuthenticated) {
        add(CategoriesLoad());
      }
    });
  }

  final CategoryRepository categoryRepository;
  final AuthBloc authBloc;

  late StreamSubscription<AuthState> authBlocSubscription;

  @override
  Stream<CategoriesState> mapEventToState(
    CategoriesEvent event,
  ) async* {
    if (event is CategoriesLoad) {
      yield* _mapLoadCategoriesToState();
    } else if (event is CategorySave) {
      yield CategoriesLoading();
      try {
        await categoryRepository.createOrUpdateCategory(event.category);
        yield CategorySaved();
        add(CategoriesLoad());
      } catch (error) {
        yield CategorySaveFailure(errorMessage: error.toString());
      }
    }
  }

  Stream<CategoriesState> _mapLoadCategoriesToState() async* {
    try {
      final List<Category> categories =
          await categoryRepository.getTenantCategories();
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

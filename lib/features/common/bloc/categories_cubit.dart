import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/bloc/categories_state.dart';
import 'package:resellio/features/common/data/api.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(
    this.apiService,
  ) : super(CategoriesInitial());

  final ApiService apiService;

  Future<void> getCategories() async {
    try {
      emit(CategoriesLoading());

      final response = await apiService.getCategories();
      if (response.success == false) {
        throw Exception('Failed to load categories: ${response.message}');
      }

      final categories = [
        for (final category in (response.data?['data'] as List<dynamic>))
          (category as Map<String, dynamic>)['categoryName'] as String,
      ];

      emit(CategoriesLoaded(categories));
    } catch (err) {
      emit(CategoriesError(err.toString()));
    }
  }
}

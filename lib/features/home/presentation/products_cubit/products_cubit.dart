
import 'package:final_project/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:final_project/features/home/data/models/product_model.dart';
import 'package:final_project/features/home/data/models/offer_model.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitialState());

  final HomeRemoteDataSource homeRemoteDataSource = HomeRemoteDataSource();

  /// The full, unfiltered product list fetched from the server.
  List<ProductModel> _allProducts = [];

  /// The currently displayed products (may be filtered by search).
  List<ProductModel> products = [];
  List categories = [];
  List<OfferModel> offers = [];

  bool isProductsLoading = false;
  bool isCategoriesLoading = false;
  bool isOffersLoading = false;

  Future<void> loadHomeData() async {
    if (_allProducts.isEmpty && categories.isEmpty && offers.isEmpty) {
      if (!isClosed) emit(GetHomeDataLoadingState());
    }
    await Future.wait([
      getProducts(),
      getCategories(),
      getOffers(),
    ]);
  }

  Future<void> getProducts() async {
    isProductsLoading = true;
    if (isClosed) return;
    emit(GetProductsLoadingState());
    try {
      _allProducts = await homeRemoteDataSource.getProducts();
      products = List.of(_allProducts);
      isProductsLoading = false;
      if (!isClosed) emit(GetProductsSuccessState(products: products));
    } catch (error) {
      isProductsLoading = false;
      if (!isClosed) emit(GetProductsFailureState(error: error.toString()));
    }
  }

  /// Filters [_allProducts] locally — no extra network request on every keystroke.
  /// Falls back to fetching all products if the cache is empty.
  Future<void> searchProducts(String query) async {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      // Restore the full list without hitting the network again.
      if (_allProducts.isNotEmpty) {
        products = List.of(_allProducts);
        if (!isClosed) emit(GetProductsSuccessState(products: products));
      } else {
        await getProducts();
      }
      return;
    }

    // If we haven't loaded all products yet, fetch them first.
    if (_allProducts.isEmpty) {
      if (isClosed) return;
      emit(SearchProductsLoadingState());
      try {
        _allProducts = await homeRemoteDataSource.getProducts();
      } catch (error) {
        if (!isClosed) emit(SearchProductsFailureState(error: error.toString()));
        return;
      }
    }

    if (isClosed) return;
    emit(SearchProductsLoadingState());

    // Score each matching product for sorting:
    //   0 → name starts with query        (highest relevance)
    //   1 → name contains query (not start)
    //   2 → description / color / arabic matches
    final scored = <({ProductModel product, int score})>[];

    for (final product in _allProducts) {
      final name    = product.name.toLowerCase();
      final desc    = product.description.toLowerCase();
      final arName  = (product.nameArabic ?? '').toLowerCase();
      final arDesc  = (product.descriptionArabic ?? '').toLowerCase();
      final color   = (product.color ?? '').toLowerCase();

      if (name.startsWith(q)) {
        scored.add((product: product, score: 0));
      } else if (name.contains(q)) {
        scored.add((product: product, score: 1));
      } else if (desc.contains(q) || arName.contains(q) || arDesc.contains(q) || color.contains(q)) {
        scored.add((product: product, score: 2));
      }
      // products that don't match any field are excluded
    }

    // Sort by score (stable sort keeps original order within same score).
    scored.sort((a, b) => a.score.compareTo(b.score));
    products = scored.map((e) => e.product).toList();

    if (!isClosed) emit(SearchProductsSuccessState(products: products));
  }

  /// Filters [_allProducts] by category ID client-side.
  /// Pass [categoryId] = null to clear the filter and show all products.
  void filterByCategory(String? categoryId) {
    if (_allProducts.isEmpty) return;

    if (categoryId == null) {
      products = List.of(_allProducts);
    } else {
      products = _allProducts
          .where((p) => p.categoryIds.contains(categoryId))
          .toList();
    }

    if (!isClosed) {
      emit(FilterByCategoryState(products: products, activeCategoryId: categoryId));
    }
  }

  Future<void> getCategories() async {
    isCategoriesLoading = true;
    if (isClosed) return;
    emit(GetCategoriesLoadingState());
    try {
      categories = await homeRemoteDataSource.getCategories();
      isCategoriesLoading = false;
      if (!isClosed) emit(GetCategoriesSuccessState());
    } catch (error) {
      isCategoriesLoading = false;
      if (!isClosed) emit(GetCategoriesFailureState(error: error.toString()));
    }
  }

  Future<void> addToCart(String productId) async {
    if (isClosed) return;
    emit(addToCartloding());
    try {
      await homeRemoteDataSource.addToCart(productId);
      if (!isClosed) emit(addToCartSuccess());
    } catch (error) {
      if (!isClosed) emit(addToCartFailure());
    }
  }

  Future<void> deleteProduct({required String productId}) async {
    emit(DeleteProductLoadingState(productId));

    try {
      await homeRemoteDataSource.deleteProduct(productId);

      emit(DeleteProductSuccessState());

      await getProducts();
    } catch (error) {
      emit(DeleteProductFailureState(error.toString()));
    }
  }

  Future<void> getOffers() async {
    isOffersLoading = true;
    if (isClosed) return;
    emit(GetOffersLoadingState());
    try {
      offers = await homeRemoteDataSource.getOffers();
      isOffersLoading = false;
      if (!isClosed) emit(GetOffersSuccessState(offers: offers));
    } catch (error) {
      isOffersLoading = false;
      if (!isClosed) emit(GetOffersFailureState(error: error.toString()));
    }
  }
}

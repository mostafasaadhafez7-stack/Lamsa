import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:final_project/features/home/data/models/product_model.dart';
import 'package:final_project/features/home/data/models/offer_model.dart';
import 'package:final_project/core/Token/token.dart';

class HomeRemoteDataSource {
  final Dio dio = Dio();

  Future<List<ProductModel>> getProducts() async {
    try {
      log(" get products");
      final Response response = await dio.get(
        "https://accessories-eshop.runasp.net/api/products",
        queryParameters: {'page':1,'pageSize': 230},
      );
      List<ProductModel> products = [];
      for (var element in response.data['items']) {
        final ProductModel model = ProductModel.fromJson(element);
        products.add(model);
      }
      log(products.toString());
      return products;
    } on DioException catch (e) {
      log('Error in getProducts: $e');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final normalizedQuery = query.trim();
      final Response response = await dio.get(
        "https://accessories-eshop.runasp.net/api/products",
        queryParameters: {
          if (normalizedQuery.isNotEmpty) 'searchTerm': normalizedQuery,
          'page': 1,
          'pageSize': 230,
        },
      );
      final products = ((response.data['items'] as List<dynamic>?) ?? [])
          .map(
            (element) => ProductModel.fromJson(element as Map<String, dynamic>),
          )
          .toList();

      if (normalizedQuery.isEmpty) return products;

      final q = normalizedQuery.toLowerCase();
      return products.where((product) {
        final nameMatches = product.name.toLowerCase().contains(q);
        final descMatches = product.description.toLowerCase().contains(q);
        final arNameMatches = (product.nameArabic ?? '').toLowerCase().contains(q);
        final arDescMatches = (product.descriptionArabic ?? '').toLowerCase().contains(q);
        final colorMatches = (product.color ?? '').toLowerCase().contains(q);
        return nameMatches || descMatches || arNameMatches || arDescMatches || colorMatches;
      }).toList();
    } on DioException catch (e) {
      log('Error in searchProducts: $e');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final Response response = await dio.get(
        "https://accessories-eshop.runasp.net/api/categories",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final body = response.data;
      List<dynamic> categories;

      if (body is List) {
        // Response is already a plain list of category objects
        categories = body;
      } else if (body is Map) {
        if (body['items'] is List) {
          // { "items": [...], "totalPages": ... }
          categories = body['items'] as List;
        } else if (body['categories'] is List) {
          // { "categories": [...] }
          categories = body['categories'] as List;
        } else if (body['categories'] is Map && (body['categories'] as Map)['items'] is List) {
          // { "categories": { "items": [...] } }
          categories = (body['categories'] as Map)['items'] as List;
        } else {
          categories = [];
        }
      } else {
        categories = [];
      }

      log('getCategories: fetched ${categories.length} categories');
      return categories;
    } on DioException catch (e) {
      log('Error in getCategories: $e');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<void> addToCart(String productId) async {
    try {
      await dio.post(
        'https://accessories-eshop.runasp.net/api/cart/items',
        data: {'productId': productId, 'quantity': 1},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      log('Error in addToCart: $e');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await dio.post(
        "https://accessories-eshop.runasp.net/api/products",

        options: Options(
          headers: {
            'content-type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: product.toJson(),
      );
    } on DioException catch (e) {
      log('Error in addProductttttttttt: ${e.response}');

      log('Errorrrrrrr: ${e.response?.data}');

      log('Error in addProduct: ${e.message}');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await dio.put(
        "https://accessories-eshop.runasp.net/api/products/${product.id}",
        data: product.toJson(),
      );
      log('Product updated successfully: ${product.toJson()}');
    } on DioException catch (e) {
      log('Error updating product: ${product.id}');
      log('Error in updateProduct: $e');
      log('Error: ${e.response?.data}');
      log('Error in updateProduct: ${e.message}');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await dio.delete(
        "https://accessories-eshop.runasp.net/api/products/$productId",

        options: Options(headers: {'Accept': 'application/json'}),
      );
      log('Product deleted successfully: $productId');
    } on DioException catch (e) {
      log('Error in deleteProduct: $e');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<List<OfferModel>> getOffers() async {
    try {
      log("get offers");
      final Response response = await dio.get(
        "https://accessories-eshop.runasp.net/api/offers",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {"page": 3},
      );
      log("offers response: ${response.data}");
      List<dynamic> rawOffers;
      if (response.data is List) {
        rawOffers = response.data;
      } else if (response.data is Map && response.data["offers"] != null) {
        rawOffers = response.data["offers"]["items"] ?? [];
      } else {
        rawOffers = response.data["items"] ?? [];
      }
      List<OfferModel> offers = [];
      for (var offer in rawOffers) {
        final OfferModel model = OfferModel.fromJson(offer);
        offers.add(model);
      }
      log(offers.toString());
      return offers;
    } on DioException catch (e) {
      log('Error in getOffers: $e');
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }
}

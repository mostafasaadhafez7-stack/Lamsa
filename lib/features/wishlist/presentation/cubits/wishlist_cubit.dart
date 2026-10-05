import 'dart:convert';
import 'dart:developer';
import 'package:final_project/core/Token/token.dart';
import 'package:final_project/features/home/data/models/product_model.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(WishlistInitialState()) {
    loadWishlist();
  }

  static const String _storageKey = 'user_wishlist';
  List<ProductModel> wishlist = [];

  Future<void> loadWishlist() async {
    try {
      final jsonString = await storage.read(key: _storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        wishlist = decoded
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        wishlist = [];
      }
      if (!isClosed) {
        emit(WishlistUpdatedState(wishlist: List.of(wishlist)));
      }
    } catch (e) {
      log('Error loading wishlist: $e');
      wishlist = [];
      if (!isClosed) {
        emit(WishlistUpdatedState(wishlist: []));
      }
    }
  }

  bool isFavorite(String? productId) {
    if (productId == null || productId.isEmpty) return false;
    return wishlist.any((item) => item.id == productId);
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final productId = product.id ?? '';
    if (productId.isEmpty) return;

    final index = wishlist.indexWhere((item) => item.id == productId);
    bool added = false;

    if (index >= 0) {
      wishlist.removeAt(index);
      added = false;
    } else {
      wishlist.insert(0, product);
      added = true;
    }

    await _saveWishlist();

    if (!isClosed) {
      emit(WishlistUpdatedState(
        wishlist: List.of(wishlist),
        lastToggledProductId: productId,
        isAdded: added,
      ));
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    wishlist.removeWhere((item) => item.id == productId);
    await _saveWishlist();
    if (!isClosed) {
      emit(WishlistUpdatedState(
        wishlist: List.of(wishlist),
        lastToggledProductId: productId,
        isAdded: false,
      ));
    }
  }

  Future<void> clearWishlist() async {
    wishlist.clear();
    await storage.delete(key: _storageKey);
    if (!isClosed) {
      emit(WishlistUpdatedState(wishlist: []));
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final jsonString = jsonEncode(
        wishlist.map((item) => item.toJson()).toList(),
      );
      await storage.write(key: _storageKey, value: jsonString);
    } catch (e) {
      log('Error saving wishlist: $e');
    }
  }
}

import 'package:final_project/features/home/data/models/product_model.dart';

abstract class WishlistState {}

class WishlistInitialState extends WishlistState {}

class WishlistLoadingState extends WishlistState {}

class WishlistUpdatedState extends WishlistState {
  final List<ProductModel> wishlist;
  final String? lastToggledProductId;
  final bool? isAdded;

  WishlistUpdatedState({
    required this.wishlist,
    this.lastToggledProductId,
    this.isAdded,
  });
}

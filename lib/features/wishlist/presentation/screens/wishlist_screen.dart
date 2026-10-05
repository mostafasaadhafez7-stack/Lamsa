import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/features/home/data/models/product_model.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_cubit.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_states.dart';
import 'package:final_project/features/home/presentation/screens/product_screen.dart';
import 'package:final_project/features/reviews/presentation/reviews_cubit/reviews_cubit.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key, this.onStartShopping});
  final VoidCallback? onStartShopping;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      listenWhen: (previous, current) =>
          current is addToCartSuccess || current is addToCartFailure,
      listener: (context, state) {
        if (state is addToCartSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Item added to cart successfully!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is addToCartFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to add item to cart. Please try again.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundClr,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundClr,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.textClr,
            ),
          ),
          centerTitle: true,
          title: Text(
            'MY WISHLIST',
            style: AppStyles.style20ExtraBold.copyWith(
              color: AppColors.textClr,
            ),
          ),
          actions: [
            BlocBuilder<WishlistCubit, WishlistState>(
              builder: (context, state) {
                final wishlist = context.read<WishlistCubit>().wishlist;
                if (wishlist.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'Clear Wishlist',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Clear Wishlist?'),
                        content: const Text(
                          'Are you sure you want to remove all items from your wishlist?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              context.read<WishlistCubit>().clearWishlist();
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 24),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, state) {
              final wishlist = context.read<WishlistCubit>().wishlist;

              if (wishlist.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primaryClr,
                  onRefresh: () => context.read<WishlistCubit>().loadWishlist(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryClr.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite_border_rounded,
                                  size: 56,
                                  color: AppColors.primaryClr,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Your Wishlist is Empty",
                                style: AppStyles.style20ExtraBold.copyWith(
                                  color: AppColors.textClr,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Save items you love by tapping the heart icon on any product.",
                                textAlign: TextAlign.center,
                                style: AppStyles.style14Regular.copyWith(
                                  color: AppColors.grayClr,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onStartShopping?.call();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryClr,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  "Explore Products",
                                  style: AppStyles.style14SemiBold.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryClr,
                onRefresh: () => context.read<WishlistCubit>().loadWishlist(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "${wishlist.length} item${wishlist.length == 1 ? '' : 's'} saved",
                          style: AppStyles.style13Regular.copyWith(color: AppColors.grayClr),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: wishlist.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                          itemBuilder: (context, index) {
                            final product = wishlist[index];
                            return _WishlistCard(product: product);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => ProductsCubit()),
                BlocProvider(create: (context) => ReviewCubit()),
              ],
              child: ProductDetails(product: product),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.borderSideClr, width: 1),
            ),
            color: AppColors.bottomBackgroundClr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      product.coverPictureUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.backgroundClr,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 35,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.style11Bold.copyWith(
                          color: AppColors.grayClr,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.style14SemiBold.copyWith(
                          color: AppColors.textClr,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "\$${product.price.toStringAsFixed(2)}",
                            style: AppStyles.style16Bold.copyWith(
                              color: AppColors.primaryClr,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Add to Cart',
                            onPressed: () {
                              context.read<ProductsCubit>().addToCart(product.id ?? '');
                            },
                            icon: Icon(
                              Icons.add_circle_rounded,
                              size: 32,
                              color: AppColors.primaryClr,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.read<WishlistCubit>().toggleFavorite(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Item removed from wishlist'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

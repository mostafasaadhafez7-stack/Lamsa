import 'package:final_project/features/home/data/models/product_model.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.product,
    this.size = 20,
    this.padding = const EdgeInsets.all(7),
    this.backgroundColor,
  });

  final ProductModel product;
  final double size;
  final EdgeInsets padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      buildWhen: (previous, current) {
        if (current is WishlistUpdatedState) {
          return current.lastToggledProductId == product.id || current.lastToggledProductId == null;
        }
        return true;
      },
      builder: (context, state) {
        final isFav = context.read<WishlistCubit>().isFavorite(product.id);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              context.read<WishlistCubit>().toggleFavorite(product);
              final newlyFav = !isFav;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        newlyFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        newlyFav ? 'Added to Wishlist ❤️' : 'Removed from Wishlist',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  backgroundColor: newlyFav ? const Color(0xFFC2185B) : Colors.grey.shade800,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFE53935) : Colors.white,
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }
}

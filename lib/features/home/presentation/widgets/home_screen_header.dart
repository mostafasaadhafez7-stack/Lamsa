import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/core/widgets/search_text_field.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'package:final_project/features/wishlist/presentation/cubits/wishlist_state.dart';
import 'package:final_project/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenHeader extends StatefulWidget {
  const HomeScreenHeader({super.key, this.onTabChange});
  final ValueChanged<int>? onTabChange;

  @override
  State<HomeScreenHeader> createState() => _HomeScreenHeaderState();
}

class _HomeScreenHeaderState extends State<HomeScreenHeader> {
  final GlobalKey<FormState> myKey = GlobalKey();
  final TextEditingController searchCtl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "LAMSA",
                style: AppStyles.style24ExtraBold.copyWith(
                  fontFamily: "Manrope",
                  color: AppColors.textClr,
                ),
              ),
              const Spacer(),
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, state) {
                  final count = context.read<WishlistCubit>().wishlist.length;
                  return IconButton(
                    tooltip: 'Wishlist',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WishlistScreen(
                            onStartShopping: () => widget.onTabChange?.call(0),
                          ),
                        ),
                      );
                    },
                    icon: Badge(
                      isLabelVisible: count > 0,
                      backgroundColor: AppColors.primaryClr,
                      label: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Icon(
                        count > 0 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: count > 0 ? const Color(0xFFE53935) : AppColors.textClr,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  widget.onTabChange?.call(2);
                },
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textClr,
                  size: 24,
                ),
              ),
            ],
          ),
          SearchTextField(
            controller: searchCtl,
            hintText: 'Search products...',
            prefixIcon: Icon(Icons.search_outlined),
          ),
        ],
      ),
    );
  }
}

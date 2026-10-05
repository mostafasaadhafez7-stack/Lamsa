import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_cubit.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomCategoriesHome extends StatefulWidget {
  const CustomCategoriesHome({super.key, this.onTabChange});
  final ValueChanged<int>? onTabChange;

  @override
  State<CustomCategoriesHome> createState() => _CustomCategoriesHomeState();
}

class _CustomCategoriesHomeState extends State<CustomCategoriesHome> {
  String? _selectedCategoryId; // null = "All"

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      buildWhen: (previous, current) =>
          current is GetCategoriesLoadingState ||
          current is GetCategoriesSuccessState ||
          current is GetCategoriesFailureState ||
          current is FilterByCategoryState ||
          current is ProductsInitialState,
      builder: (blocContext, state) {
        final cubit = blocContext.read<ProductsCubit>();

        if ((cubit.isCategoriesLoading ||
                state is GetCategoriesLoadingState ||
                state is ProductsInitialState) &&
            cubit.categories.isEmpty) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GetCategoriesFailureState && cubit.categories.isEmpty) {
          return SizedBox(
            height: 110,
            child: Center(
              child: Text(
                state.error ?? "Failed to load categories",
                style: AppStyles.style12Medium.copyWith(color: Colors.red),
              ),
            ),
          );
        }

        if (cubit.categories.isEmpty) {
          return const SizedBox(
            height: 110,
            child: Center(child: Text("No categories available")),
          );
        }

        // Build items list — "All" first, then real categories
        final allItems = <Map<String, dynamic>>[
          {'id': null, 'name': 'All', 'coverPictureUrl': null},
          ...cubit.categories.map((c) {
            final map = (c is Map)
                ? Map<String, dynamic>.from(c)
                : <String, dynamic>{};
            return {
              'id': map['id']?.toString(),
              'name': (map['name'] ?? '').toString(),
              'coverPictureUrl': map['coverPictureUrl']?.toString(),
            };
          }),
        ];

        return SizedBox(
          height: 110,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: allItems.length,
            itemBuilder: (_, index) {
              final item = allItems[index];
              final id = item['id'] as String?;
              final isSelected = _selectedCategoryId == id;
              final name = item['name'] as String;
              final imageUrl = item['coverPictureUrl'] as String?;

              return _CategoryChip(
                id: id,
                name: name,
                imageUrl: imageUrl,
                isSelected: isSelected,
                onTap: () {
                  // Toggle: tap selected → show all; tap new → filter
                  final newId = (_selectedCategoryId == id) ? null : id;
                  setState(() => _selectedCategoryId = newId);
                  cubit.filterByCategory(newId);
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Extracted to its own StatelessWidget so each chip has its own hit-test region.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  final String? id;
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selection ring around avatar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryClr
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: isSelected
                        ? AppColors.primaryClr.withValues(alpha: 0.12)
                        : AppColors.bottomBackgroundClr,
                    child: ClipOval(
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  _icon(isSelected),
                            )
                          : _icon(isSelected),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: AppStyles.style12Medium.copyWith(
                    color: isSelected ? AppColors.primaryClr : AppColors.textClr,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon(bool isSelected) => Icon(
        Icons.category_rounded,
        size: 30,
        color: isSelected ? AppColors.primaryClr : AppColors.grayClr,
      );
}

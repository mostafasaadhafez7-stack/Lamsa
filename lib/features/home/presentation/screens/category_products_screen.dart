import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_cubit.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_states.dart';
import 'package:final_project/features/home/data/models/product_model.dart';
import 'package:final_project/features/home/presentation/screens/product_screen.dart';
import 'package:final_project/features/reviews/presentation/reviews_cubit/reviews_cubit.dart';
import 'package:final_project/features/wishlist/presentation/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Sort options ───────────────────────────────────────────────────────────
enum SortOption { none, priceAsc, priceDesc, nameAsc, nameDesc }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.none:       return 'Default';
      case SortOption.priceAsc:  return 'Price: Low → High';
      case SortOption.priceDesc: return 'Price: High → Low';
      case SortOption.nameAsc:   return 'Name: A → Z';
      case SortOption.nameDesc:  return 'Name: Z → A';
    }
  }
}

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String? _selectedCategoryId;   // null = All
  SortOption _sortOption = SortOption.none;

  // Apply both filter & sort on the raw list from the cubit
  List<ProductModel> _applyFilters(List<ProductModel> all) {
    var list = all.toList();

    // Filter by category
    if (_selectedCategoryId != null) {
      list = list
          .where((p) => p.categoryIds.contains(_selectedCategoryId))
          .toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SortOption.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case SortOption.none:
        break;
    }

    return list;
  }

  void _openFilterSheet(BuildContext ctx, ProductsCubit cubit) {
    // Local copies for the sheet
    String? tempCategory = _selectedCategoryId;
    SortOption tempSort = _sortOption;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final categories = cubit.categories;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.bottomBackgroundClr,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.grayClr.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // ── Sort ──────────────────────────────────────────────
                  Text('Sort By',
                      style: AppStyles.style16SemiBold
                          .copyWith(color: AppColors.textClr)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: SortOption.values.map((opt) {
                      final sel = tempSort == opt;
                      return ChoiceChip(
                        label: Text(opt.label,
                            style: AppStyles.style12Medium.copyWith(
                                color: sel
                                    ? Colors.white
                                    : AppColors.textClr)),
                        selected: sel,
                        selectedColor: AppColors.primaryClr,
                        backgroundColor: AppColors.backgroundClr,
                        side: BorderSide(
                            color: sel
                                ? AppColors.primaryClr
                                : AppColors.borderSideClr),
                        onSelected: (_) =>
                            setSheetState(() => tempSort = opt),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Filter by Category ───────────────────────────────
                  Text('Filter by Category',
                      style: AppStyles.style16SemiBold
                          .copyWith(color: AppColors.textClr)),
                  const SizedBox(height: 10),

                  if (categories.isEmpty)
                    Text('No categories available',
                        style: AppStyles.style12Medium
                            .copyWith(color: AppColors.grayClr))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // "All" chip
                        _buildCategoryChip(
                          label: 'All',
                          isSelected: tempCategory == null,
                          onTap: () =>
                              setSheetState(() => tempCategory = null),
                        ),
                        ...categories.map((c) {
                          final map = (c is Map)
                              ? Map<String, dynamic>.from(c)
                              : <String, dynamic>{};
                          final id = map['id']?.toString();
                          final name = (map['name'] ?? '').toString();
                          return _buildCategoryChip(
                            label: name,
                            isSelected: tempCategory == id,
                            onTap: () =>
                                setSheetState(() => tempCategory = id),
                          );
                        }),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // ── Action buttons ───────────────────────────────────
                  Row(
                    children: [
                      // Reset
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              tempCategory = null;
                              tempSort = SortOption.none;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: AppColors.primaryClr),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Reset',
                              style: AppStyles.style14SemiBold.copyWith(
                                  color: AppColors.primaryClr)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Apply
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategoryId = tempCategory;
                              _sortOption = tempSort;
                            });
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryClr,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Apply',
                              style: AppStyles.style14SemiBold
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryClr
              : AppColors.backgroundClr,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryClr : AppColors.borderSideClr,
          ),
        ),
        child: Text(
          label,
          style: AppStyles.style12Medium.copyWith(
            color: isSelected ? Colors.white : AppColors.textClr,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit()
        ..getProducts()
        ..getCategories(),
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<ProductsCubit>();
          return Scaffold(
            backgroundColor: AppColors.backgroundClr,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundClr,
              elevation: 0,
              centerTitle: true,
              title: Text('Categories', style: AppStyles.style18ExtraBold),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    // ── Header row ─────────────────────────────────────
                    BlocBuilder<ProductsCubit, ProductsState>(
                      buildWhen: (p, c) =>
                          c is GetProductsSuccessState ||
                          c is GetProductsLoadingState ||
                          c is GetProductsFailureState,
                      builder: (_, state) {
                        final filtered = _applyFilters(cubit.products);
                        final hasFilters = _selectedCategoryId != null ||
                            _sortOption != SortOption.none;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Text(
                                'Showing ${filtered.length} product${filtered.length == 1 ? '' : 's'}',
                                style: AppStyles.style13Regular.copyWith(
                                    color: AppColors.grayClr),
                              ),
                              const Spacer(),
                              // Active filter badge
                              if (hasFilters)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryClr,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    hasFilters ? 'Active' : '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              // Sort & Filter button
                              GestureDetector(
                                onTap: () => _openFilterSheet(ctx, cubit),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: hasFilters
                                        ? AppColors.primaryClr
                                            .withValues(alpha: 0.1)
                                        : AppColors.profileCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasFilters
                                          ? AppColors.primaryClr
                                          : AppColors.borderSideClr,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        size: 18,
                                        color: hasFilters
                                            ? AppColors.primaryClr
                                            : AppColors.textClr,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Sort & Filter',
                                        style:
                                            AppStyles.style13Regular.copyWith(
                                          color: hasFilters
                                              ? AppColors.primaryClr
                                              : AppColors.textClr,
                                          fontWeight: hasFilters
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // ── Products grid ───────────────────────────────────
                    Expanded(
                      child: BlocBuilder<ProductsCubit, ProductsState>(
                        buildWhen: (p, c) =>
                            c is GetProductsLoadingState ||
                            c is GetProductsSuccessState ||
                            c is GetProductsFailureState ||
                            c is ProductsInitialState,
                        builder: (_, state) {
                          if ((state is GetProductsLoadingState ||
                                  state is ProductsInitialState) &&
                              cubit.products.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is GetProductsFailureState && cubit.products.isEmpty) {
                            return Center(
                              child: Text(
                                state.error ?? 'Failed to load products',
                                style: AppStyles.style14SemiBold
                                    .copyWith(color: Colors.red),
                              ),
                            );
                          }

                          final filtered = _applyFilters(cubit.products);

                          if (filtered.isEmpty) {
                            return RefreshIndicator(
                              color: AppColors.primaryClr,
                              onRefresh: () => Future.wait([
                                cubit.getProducts(),
                                cubit.getCategories(),
                              ]),
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.search_off_rounded,
                                            size: 64,
                                            color: AppColors.grayClr
                                                .withValues(alpha: 0.5)),
                                        const SizedBox(height: 12),
                                        Text('No products found',
                                            style: AppStyles.style18ExtraBold
                                                .copyWith(
                                                    color: AppColors.textClr)),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Try changing your filters',
                                          style: AppStyles.style13Regular
                                              .copyWith(
                                                  color: AppColors.grayClr),
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: () => setState(() {
                                            _selectedCategoryId = null;
                                            _sortOption = SortOption.none;
                                          }),
                                          child: Text('Clear Filters',
                                              style: AppStyles.style14SemiBold
                                                  .copyWith(
                                                      color: AppColors.primaryClr)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            color: AppColors.primaryClr,
                            onRefresh: () => Future.wait([
                              cubit.getProducts(),
                              cubit.getCategories(),
                            ]),
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: filtered.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (gridCtx, index) {
                              final product = filtered[index];
                              return _ProductCard(product: product, cubit: cubit);
                            },
                          ),
                        );
                      },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Simple product card ─────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.cubit});
  final ProductModel product;
  final ProductsCubit cubit;

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppColors.bottomBackgroundClr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.coverPictureUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Center(
                          child: Icon(Icons.image_not_supported_outlined, size: 35)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.style11Bold
                              .copyWith(color: AppColors.grayClr)),
                      Text(product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.style14SemiBold
                              .copyWith(color: AppColors.textClr)),
                      Row(
                        children: [
                          Text('\$${product.price}',
                              style: AppStyles.style16Bold),
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => cubit.addToCart(product.id ?? ''),
                            icon: Icon(Icons.add_circle_outlined,
                                size: 32, color: AppColors.primaryClr),
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
            top: 8,
            right: 8,
            child: FavoriteButton(product: product),
          ),
        ],
      ),
    );
  }
}

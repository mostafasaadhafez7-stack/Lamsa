import 'dart:async';
import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/core/widgets/custom_search_text_field.dart';
import 'package:final_project/features/home/presentation/products_cubit/products_cubit.dart';
import 'package:final_project/features/home/presentation/widgets/cutom_gridview_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  void _onSearchChanged(String query, BuildContext context) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        context.read<ProductsCubit>().searchProducts(query);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit()..getProducts(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.backgroundClr,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Search Products",
              style: AppStyles.style20ExtraBold.copyWith(color: AppColors.textClr),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textClr),
            ),
            backgroundColor: AppColors.backgroundClr,
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchTextField(
                      hintText: "Search products by name, color, description...",
                      controller: _searchController,
                      onChanged: (query) => _onSearchChanged(query, context),
                      prefixIcon: Icon(Icons.search, color: AppColors.grayClr),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _debounceTimer?.cancel();
                                _searchController.clear();
                                setState(() {});
                                context.read<ProductsCubit>().searchProducts('');
                              },
                              icon: Icon(Icons.cancel_outlined, color: AppColors.grayClr),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const CutomGridviewHome(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

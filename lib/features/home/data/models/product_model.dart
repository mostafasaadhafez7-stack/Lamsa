class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String coverPictureUrl;
  final int? stock;
  final List<String> categoryIds;
  final List<String>? productPictureUrls;
  final String sellerId;
  final String? nameArabic;
  final String? color;
  final String? descriptionArabic;

  ProductModel({
     this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.coverPictureUrl,
    required this.stock,
    required this.categoryIds,
    this.productPictureUrls,
    required this.sellerId,
    this.nameArabic,
    this.color,
    this.descriptionArabic,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      coverPictureUrl: json['coverPictureUrl'] ?? '',
      categoryIds: _parseCategoryIds(json),
      stock: (json['stock'] as num?)?.toInt(),
      productPictureUrls: (json['productPictures'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['productPictureUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      sellerId: json['sellerId'] ?? '',
      nameArabic: json['arabicName'] ?? json['nameArabic'] ?? '',
      color: json['color'] ?? '',
      descriptionArabic: json['arabicDescription'] ?? json['descriptionArabic'] ?? '',
    );
  }

  /// Handles two API shapes:
  ///   • categories: [{id: 1, name: "..."}, ...]   → extract 'id'
  ///   • categoryIds: [1, 2, ...]                  → convert to string
  static List<String> _parseCategoryIds(Map<String, dynamic> json) {
    // Prefer the full category objects list first
    final cats = json['categories'] as List<dynamic>?;
    if (cats != null && cats.isNotEmpty) {
      return cats.map((e) {
        if (e is Map) {
          // e.g. {id: 1, name: "Watches"}  → "1"
          return (e['id'] ?? e['categoryId'] ?? '').toString();
        }
        // e is a raw id (int or string)
        return e.toString();
      }).toList();
    }

    // Fall back to categoryIds raw list
    final ids = json['categoryIds'] as List<dynamic>?;
    if (ids != null) {
      return ids.map((e) => e.toString()).toList();
    }

    return [];
  }

  Map<String, dynamic> toJson() {
    return {
     'id': id ,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'coverPictureUrl': coverPictureUrl,
      'stock': stock,
      'categoryIds': categoryIds,
      'productPictureUrls': productPictureUrls,
      'nameArabic': nameArabic,
      'color': color,
      'descriptionArabic': descriptionArabic,
      'weight': 3581.52,
      'discountPercentage': 4,
    };
  }
}

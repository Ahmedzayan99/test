import 'package:project1/data/model/filtersModel.dart';
import 'package:project1/data/model/sectionsModel.dart';

class ProductModel {
  bool? error;
  String? message;
  String? minPrice;
  String? maxPrice;
  String? search;
  List<FiltersModel>? filters;
  List<Categories>? categories;
  List<String>? productTags;
  List<String>? restaurantTags;
  String? total;
  String? offset;
  List<ProductDetails>? data;

  ProductModel(
      {this.error,
      this.message,
      this.minPrice,
      this.maxPrice,
      this.search,
      this.filters,
      this.categories,
      this.productTags,
      this.restaurantTags,
      this.total,
      this.offset,
      this.data});

  ProductModel updateOfflineCart(
    List<ProductDetails>? data,
    String? total,
  ) {
    return ProductModel(
      data: data ?? this.data,
      total: total ?? this.total,
    );
  }

  ProductModel.fromJson(Map<String, dynamic> json) {
    error = json['error'] ?? "";
    message = json['message'] ?? "";
    minPrice = json['min_price'] ?? "";
    maxPrice = json['max_price'] ?? "";
    search = json['search'] ?? "";
    if (json['filters'] != null) {
      filters = <FiltersModel>[];
      json['filters'].forEach((v) {
        filters!.add(FiltersModel.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    productTags = json['product_tags'] == null ? List<String>.from([]) : (json['product_tags'] as List).map((e) => e.toString()).toList();
    restaurantTags = json['partner_tags'] == null ? List<String>.from([]) : (json['partner_tags'] as List).map((e) => e.toString()).toList();
    total = json['total'] ?? "";
    offset = json['offset'];
    if (json['data'] != null) {
      data = <ProductDetails>[];
      json['data'].forEach((v) {
        data!.add(ProductDetails.fromJson(v));
      });
    }
  }

}

class Categories {
  String? id;
  String? name;
  bool? isExpanded;

  Categories({this.id, this.name, this.isExpanded});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isExpanded = true;
  }
}



import 'package:project1/data/model/restaurantModel.dart';

class SearchModel {
  String? productId;
  String? productName;
  String? categoryId;
  String? productImage;
  String? type;
  List<RestaurantModel>? partnerDetails;

  SearchModel({this.productId, this.productName, this.categoryId, this.productImage, this.type, this.partnerDetails});

  SearchModel.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name '];
    categoryId = json['category_id '];
    productImage = json['product_image '];
    type = json['type'];
    if (json['partner_details'] != null) {
      partnerDetails = <RestaurantModel>[];
      json['partner_details'].forEach((v) {
        partnerDetails!.add(RestaurantModel.fromJson(v));
      });
    }
  }
}

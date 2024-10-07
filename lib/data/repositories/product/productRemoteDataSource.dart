import 'package:project1/data/model/productModel.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';


class ProductRemoteDataSource {
  //to getProduct
  Future<ProductModel> getProduct(
      {String? partnerId, String? latitude, String? longitude, String? userId, String? cityId, String? vegetarian}) async {
    try {
      //body of post request
      final body = {
        partnerIdKey: partnerId,
        filterByKey: filterByProductKey,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId,
        cityIdKey: cityId ?? "",
        vegetarianKey: vegetarian ?? ""
      };
      final result = await Api.post(body: body, url: Api.getProductsUrl, token: true, errorCode: false);
      return ProductModel.fromJson(result);
    } catch (e) {
      //print(e.toString());
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to getOfflineCart
  Future/* <ProductModel> */<List<ProductDetails>> getOfflineCart({String? latitude, String? longitude, String? cityId, String? productVariantIds}) async {
    try {
      //body of post request
      final body = {
        filterByKey: filterByProductKey,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        cityIdKey: cityId ?? "",
        productVariantIdsKey: productVariantIds ?? ""
      };
      final result = await Api.post(body: body, url: Api.getProductsUrl, token: true, errorCode: false);
      return (result['data'] as List).map((e) => ProductDetails.fromJson(e)).toList();//ProductDetails.fromJson(result['data']);
    } catch (e) {
      print(e.toString());
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to ManageOfflineCart
  Future<ProductModel> manageOfflineCart({String? latitude, String? longitude, String? cityId, String? productVariantIds}) async {
    try {
      //body of post request
      final body = {
        filterByKey: filterByProductKey,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        cityIdKey: cityId ?? "",
        productVariantIdsKey: productVariantIds ?? ""
      };
      final result = await Api.post(body: body, url: Api.getProductsUrl, token: true, errorCode: false);
      return ProductModel.fromJson(result);
    } catch (e) {
      print(e.toString());
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}

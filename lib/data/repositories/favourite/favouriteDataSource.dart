import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';


class FavouriteRemoteDataSource {
  Future<List<RestaurantModel>> getFavouriteRestaurants({String? userId, String? type}) async {
    try {
      final body = {
        userIdKey: userId,
        typeKey: type,
      };
      final result = await Api.post(body: body, url: Api.getFavoritesUrl, token: true, errorCode: true);
      //print("r4:${result['data']}");
      return (result['data'] as List).map((e) => RestaurantModel.fromJson(Map.from(e))).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future<List<ProductDetails>> getFavouriteProducts({String? userId, String? type}) async {
    try {
      final body = {
        userIdKey: userId,
        typeKey: type,
      };
      final result = await Api.post(body: body, url: Api.getFavoritesUrl, token: true, errorCode: true);
      return (result['data'] as List).map((e) => ProductDetails.fromJson(e)).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future favouriteAdd(String? userId, String? type, String? typeId) async {
    try {
      final body = {userIdKey: userId, typeKey: type, typeIdKey: typeId};
      final result = await Api.post(body: body, url: Api.addToFavoritesUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future favouriteRemove(String? userId, String? type, String? typeId) async {
    try {
      final body = {userIdKey: userId, typeKey: type, typeIdKey: typeId};
      final result = await Api.post(body: body, url: Api.removeFromFavoritesUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

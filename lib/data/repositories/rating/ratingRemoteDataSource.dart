import 'dart:convert';
import 'dart:io';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

class RatingRemoteDataSource {
  Future setProductRating(String? userId, List? productRatingData, String? orderId) async {
    try {
      Map<String, String> body = {userIdKey: userId!, orderIdKey: orderId!};
      Map<dynamic,File> filelist ={};
      for(int i=0;i<productRatingData!.length;i++){
        body["$productRatingDataKey[$i][product_id]"]=productRatingData[i]["product_id"];
        body["$productRatingDataKey[$i][rating]"]=productRatingData[i]["rating"];
        body["$productRatingDataKey[$i][comment]"]=productRatingData[i]["comment"];
        for(int j=0;j<productRatingData[i]["images"].length;j++){
          print('---${productRatingData[i]["images"][j]}');
        //  imagesList.add(productRatingData[i]["images"][j]);
        //  filelist[productRatingData[i]["images"][j]] = productRatingData[i]["images"][j];
        filelist.addAll({'$productRatingDataKey[$i][images][$j]':productRatingData[i]["images"][j]});
        //  print(filelist[productRatingData[i]["images"][j]]);
        }
      }
      //print("body:$body");
      print(filelist);
      //final response = await http.post(Uri.parse(Api.setProductRatingUrl), body: body, headers: Api.getHeaders());
      //final responseJson = Map.from(jsonDecode(response.body));
      final response = await Api.postApiFileProductRating(Uri.parse(Api.setProductRatingUrl), body, userId,filelist, orderId);
      final responseJson = json.decode(response);
      print(responseJson);

      if (responseJson['error']) {
        throw ApiMessageAndCodeException(errorMessage: responseJson['message'],errorStatusCode: responseJson["status_code"].toString());
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future setRiderRating(String? userId, String? riderId, String? rating, String? comment, String? orderId) async {
    try {
      final body = {userIdKey: userId, riderIdKey: riderId, ratingKey: rating, commentKey: comment, orderIdKey: orderId};
      final result = await Api.post(body: body, url: Api.setRiderRatingUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteProductRating(String? ratingId) async {
    try {
      final body = {ratingIdKey: ratingId};
      final result = await Api.post(body: body, url: Api.deleteProductRatingUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteRiderRating(String? ratingId) async {
    try {
      final body = {ratingIdKey: ratingId};
      final result = await Api.post(body: body, url: Api.deleteRiderRatingUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future setOrderRating(String? userId, String? orderId, String? rating, String? comment, List<File> images) async {
    try {
      Map<String, String?> body = {userIdKey: userId, orderIdKey: orderId, ratingKey: rating, commentKey: comment};
      List<File> imagesList = images;
      final response = await Api.postApiFile(Uri.parse(Api.setOrderRatingUrl), imagesList, body, userId, orderId, rating, comment);
      //print("body:$body");
      final responseJson = json.decode(response);
      //print(responseJson);
      if (responseJson['error']) {
        //print("error:"+responseJson['error']);
        throw ApiMessageAndCodeException(errorMessage: responseJson['message'],errorStatusCode: responseJson["status_code"].toString());
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteOrderRating(String? orderId) async {
    try {
      final body = {ratingIdKey: orderId};
      /* final response = await http.post(Uri.parse(Api.deleteOrderRatingUrl), body: body, headers: Api.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      if (responseJson['error']) {
        throw ApiMessageAndCodeException(errorMessage: responseJson['message'],errorStatusCode: responseJson["status_code"].toString());
      }

      return responseJson['data']; */
      final result = await Api.post(body: body, url:Api.deleteOrderRatingUrl, token: true, errorCode: true);
      return result['data'];
    } /* on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  */catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

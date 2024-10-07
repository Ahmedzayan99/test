import 'package:project1/app/app.dart';
import 'package:project1/data/localDataStore/authLocalDataSource.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiMessageAndCodeException implements Exception {
  final String errorMessage;
  String? errorStatusCode;

  ApiMessageAndCodeException({required this.errorMessage, this.errorStatusCode});

  //@override
  Map toError() => {"message": errorMessage, "code":errorStatusCode};

  @override
  String toString() => errorMessage;
}

class ApiMessageException implements Exception {
  final String errorMessage;

  ApiMessageException({required this.errorMessage});

  @override
  String toString() => errorMessage;
}

class Api {

  //jwt key tocken
  static Map<String, String> getHeaders() {
    String jwtToken = AuthLocalDataSource().getJwtTocken()!;
    print(jwtToken);
    return {"Authorization": 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3Mjc4NjkxNjIsImlzcyI6ImVyZXN0cm8iLCJleHAiOjE3NDA4MjkxNjIsInN1YiI6ImVyZXN0cm9fYXV0aGVudGljYXRpb24iLCJ1c2VyX2lkIjoiMjU1In0.Sq342rBF6CQsybrYmKO_doq205nxezbcbEOEihiWgJ8'};
  }

  static Future<dynamic> post({
    required Map<dynamic, dynamic> body,
    required String url,
    bool? token,
    bool? errorCode
  }) async {
    try {
      http.Response response;
      if(token!) {
        response = await http.post(Uri.parse(url), body: body, headers: Api.getHeaders());
      } else{
        response = await http.post(Uri.parse(url), body: body);
      }
      print("url:$url\nparameter:$body\njwtToken:${Api.getHeaders()}");
      if (response.statusCode == 503) {
       // isMaintenance(navigatorKey.currentContext!);
      }
      final responseJson = convertJson(response);
      print(responseJson);
      if (responseJson['error']) {
        if(errorCode!){
          throw ApiMessageAndCodeException(errorMessage: responseJson['message'],errorStatusCode: responseJson["status_code"].toString());}
        else{
          throw ApiMessageException(errorMessage: responseJson['message']);
        }
      }
      
      return responseJson;
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      print("state:: ${apiMessageAndCodeException.errorMessage.toString()} -- ${apiMessageAndCodeException.errorStatusCode.toString()}");
      if(errorCode!){
           print("instate:: ${apiMessageAndCodeException.errorMessage.toString()} -- ${apiMessageAndCodeException.errorStatusCode.toString()}");
        throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
      }
      else{
        throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString());
      }
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFile(Uri url, List<File> images, Map<String, String?> body, String? userId, String? productId, String? rating, String? comment) async {
    print("Uri is##############$url");
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
    
      body[userIdKey] = userId;
      body[productIdKey] = productId;
      body[ratingKey] = rating;
      body[commentKey] = comment;
      //print(body.toString());

      for (var i = 0; i < images.length; i++) {
        final mimeType = lookupMimeType(images[i].path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(imagesKey, images[i].path,contentType: MediaType('image', extension[1]));
        request.files.add(pic);
        print(images[i].path);
      }
        
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      print("images$response$responseData");
      if (res.statusCode == 503) {
   //     isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        print("response ********$response");
        return response;
      }/*  else {
        return null;
      } */
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      print("data::${e.errorMessage}::${e.errorStatusCode}");
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFileProductRating(Uri url, Map<String, String?> body, String? userId,Map<dynamic,File> filelist, String? orderId) async {
    print("Uri is##############$url");
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
    
      body[userIdKey] = userId;
      body[orderIdKey] = orderId;
      print(body.toString());

      print("file:${filelist.keys}- ${filelist.values}");
      if(filelist.isNotEmpty){
        
        filelist.forEach((key, value) async {
            final mimeType = lookupMimeType(value.path);
            var extension = mimeType!.split("/");
              var pic = await http.MultipartFile.fromPath(key, value.path,contentType: MediaType('image', extension[1]));
              print("key:$key");
              request.files.add(pic);
            });
      }

     /* if (images != null) {
        for (var i = 0; i < images.length; i++) {
          final mimeType = lookupMimeType(images[i].path);

          var extension = mimeType!.split("/");
          var pic = await http.MultipartFile.fromPath("$productRatingDataKey[$i]$imagesKey", images[i].path,contentType: MediaType('image', extension[1]));
          
          request.files.add(pic);
          print(images[i].path);
        }
      }*/
        
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      print("images$response$responseData");
      if (res.statusCode == 503) {
       // isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        print("response ********$response");
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFileProfilePic(Uri url, Map<String, File?> fileList, Map<String, String?> body, String? userId) async {
    print("Uri is##############$url");
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
    
      body[userIdKey] = userId;
      print(body[userIdKey].toString());

      fileList.forEach((key, value) async {
        final mimeType = lookupMimeType(value!.path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(key, value.path,contentType: MediaType('image', extension[1]));
        request.files.add(pic);
      });
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 503) {
        //isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        print("response ********$response");
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
  
  static convertJson(Response response){
    return json.decode(response.body);
  }
//api end points
static String loginUrl = "${baseUrl}login";
static String updateFcmUrl = "${baseUrl}update_fcm";
static String getLoginIdentityUrl = "${baseUrl}get_login_identity";
static String verifyUserUrl = "${baseUrl}verify_user";
static String registerUserUrl = "${baseUrl}register_user";
static String updateUserUrl = "${baseUrl}update_user";
static String isCityDeliverableUrl = "${baseUrl}is_city_deliverable";
static String getSliderImagesUrl = "${baseUrl}get_slider_images";
static String getOfferImagesUrl = "${baseUrl}get_offer_images";
static String getCategoriesUrl = "${baseUrl}get_categories";
static String getCitiesUrl = "${baseUrl}get_cities";
static String getProductsUrl = "${baseUrl}get_products";
static String validatePromoCodeUrl = "${baseUrl}validate_promo_code";
static String getPartnersUrl = "${baseUrl}get_partners";
static String addAddressUrl = "${baseUrl}add_address";
static String updateAddressUrl = "${baseUrl}update_address";
static String getAddressUrl = "${baseUrl}get_address";
static String deleteAddressUrl = "${baseUrl}delete_address";
static String getSettingsUrl = "${baseUrl}get_settings";
static String placeOrderUrl = "${baseUrl}place_order";
static String getOrdersUrl = "${baseUrl}get_orders";
static String setProductRatingUrl = "${baseUrl}set_product_rating";
static String deleteProductRatingUrl = "${baseUrl}delete_product_rating";
static String getProductRatingUrl = "${baseUrl}get_product_rating";
static String manageCartUrl = "${baseUrl}manage_cart";
static String getUserCartUrl = "${baseUrl}get_user_cart";
static String addToFavoritesUrl = "${baseUrl}add_to_favorites";
static String removeFromFavoritesUrl = "${baseUrl}remove_from_favorites";
static String getFavoritesUrl = "${baseUrl}get_favorites";
static String getNotificationsUrl = "${baseUrl}get_notifications";
static String updateOrderStatusUrl = "${baseUrl}update_order_status";
static String addTransactionUrl = "${baseUrl}add_transaction";
static String getSectionsUrl = "${baseUrl}get_sections";
static String transactionsUrl = "${baseUrl}transactions";
static String deleteOrderUrl = "${baseUrl}delete_order";
static String getTicketTypesUrl = "${baseUrl}get_ticket_types";
static String addTicketUrl = "${baseUrl}add_ticket";
static String editTicketUrl = "${baseUrl}edit_ticket";
static String sendMessageUrl = "${baseUrl}send_message";
static String getTicketsUrl = "${baseUrl}get_tickets";
static String getMessagesUrl = "${baseUrl}get_messages";
static String setRiderRatingUrl = "${baseUrl}set_rider_rating";
static String getRiderRatingUrl = "${baseUrl}get_rider_rating";
static String deleteRiderRatingUrl = "${baseUrl}delete_rider_rating";
static String getFaqsUrl = "${baseUrl}get_faqs";
static String getPromoCodesUrl = "${baseUrl}get_promo_codes";
static String removeFromCartUrl = "${baseUrl}remove_from_cart";
static String makePaymentsUrl = "${baseUrl}make_payments";
static String getPaypalLinkUrl = "${baseUrl}get_paypal_link";
static String paypalTransactionWebviewUrl = "${baseUrl}paypal_transaction_webview";
static String appPaymentStatusUrl = "${baseUrl}app_payment_status";
static String ipnUrl = "${baseUrl}ipn";
static String stripeWebhookUrl = "${baseUrl}stripe_webhook";
static String generatePaytmChecksumUrl = "${baseUrl}generate_paytm_checksum";
static String generatePaytmTxnTokenUrl = "${baseUrl}generate_paytm_txn_token";
static String validatePaytmChecksumUrl = "${baseUrl}validate_paytm_checksum";
static String validateReferCodeUrl = "${baseUrl}validate_refer_code";
static String flutterwaveWebviewUrl = "${baseUrl}flutterwave_webview";
static String flutterwavePaymentResponseUrl = "${baseUrl}flutterwave-payment-response";
static String getDeliveryChargesUrl = "${baseUrl}get_delivery_charges";
static String getLiveTrackingDetailsUrl = "${baseUrl}get_live_tracking_details";
static String deleteMyAccountUrl = "${baseUrl}delete_my_account";
static String sendWithdrawRequestUrl = "${baseUrl}send_withdrawal_request";
static String getWithdrawRequestUrl = "${baseUrl}get_withdrawal_request";
static String setOrderRatingUrl = "${baseUrl}set_order_rating";
static String deleteOrderRatingUrl = "${baseUrl}delete_order_rating";
static String getOrderRatingUrl = "${baseUrl}get_order_rating";
static String getPartnerRatingsUrl = "${baseUrl}get_partner_ratings";
static String signUpUrl = "${baseUrl}sign_up";
static String isOrderDeliverableUrl = "${baseUrl}is_order_deliverable";
static String createMidtransTransactionUrl = "${baseUrl}create_midtrans_transaction";
static String getMidtransTransactionStatusUrl = "${baseUrl}get_midtrans_transaction_status";
static String midtransWalletTransactionUrl = "${baseUrl}midtrans_wallet_transaction";
static String reOrderUrl = "${baseUrl}re_order";
static String searchProductUrl = "${baseUrl}search_product";
static String phonepeCheckSumUrl = "${baseUrl}phonepe_app";
static String verifyOtpUrl = "${baseUrl}verify_otp";
static String resendOtpUrl = "${baseUrl}resend_otp";

static String apiGetAddressSuggestions = "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=${googleAPiKeyAndroid}&input=";
static String apiGetLatLng = "https://maps.googleapis.com/maps/api/geocode/json?key=${googleAPiKeyAndroid}&place_id=";

}
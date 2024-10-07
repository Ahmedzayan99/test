import 'package:project1/data/model/cartModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

class CartRemoteDataSource {
//to manageCart
  Future<dynamic> manageCart(
      {String? userId, String? productVariantId, String? isSavedForLater, String? qty, String? addOnId, String? addOnQty}) async {
    try {
      //body of post request
      final body = {
        userIdKey: userId,
        productVariantIdKey: productVariantId,
        isSavedForLaterKey: isSavedForLater,
        qtyKey: qty,
        addOnIdKey: addOnId ?? "",
        addOnQtyKey: addOnQty ?? ""
      };
      final result = await Api.post(body: body, url: Api.manageCartUrl, token: true, errorCode: true);
      print("result:$result");
      return result;
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to placeOrder
  Future<dynamic> placeOrder(
      {String? userId,
      String? mobile,
      String? productVariantId,
      String? quantity,
      String? total,
      String? deliveryCharge,
      String? taxAmount,
      String? taxPercentage,
      String? finalTotal,
      String? latitude,
      String? longitude,
      String? promoCode,
      String? paymentMethod,
      String? addressId,
      String? isWalletUsed,
      String? walletBalanceUsed,
      String? activeStatus,
      String? orderNote,
      String? deliveryTip}) async {
    try {
      //body of post request
      final body = {
        userIdKey: userId,
        mobileKey: mobile,
        productVariantIdKey: productVariantId,
        quantityKey: quantity,
        totalKey: total,
        deliveryChargeKey: deliveryCharge,
        taxAmountKey: taxAmount,
        taxPercentageKey: taxPercentage,
        finalTotalKey: finalTotal,
        latitudeKey: latitude,
        longitudeKey: longitude,
        promoCodeKey: promoCode,
        paymentMethodKey: paymentMethod,
        addressIdKey: addressId,
        isWalletUsedKey: isWalletUsed,
        walletBalanceUsedKey: walletBalanceUsed,
        activeStatusKey: activeStatus,
        orderNoteKey: orderNote,
        deliveryTipKey: deliveryTip
      };
      final result = await Api.post(body: body, url: Api.placeOrderUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to removeCart
  Future<dynamic> removeCart({String? userId, String? productVariantId}) async {
    try {
      //body of post request
      final body = {userIdKey: userId, productVariantIdKey: productVariantId};
      final result = await Api.post(body: body, url: Api.removeFromCartUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to clearCart
  Future<dynamic> clearCart({String? userId /*, String? clearCart*/}) async {
    try {
      //body of post request
      final body = {userIdKey: userId /*, clearCartKey: clearCart*/};
      final result = await Api.post(body: body, url: Api.removeFromCartUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to getUserCart
  Future<CartModel> getCart({String? userId /*, String? isSavedForLater, String? restaurantId*/}) async {
    try {
      //body of post request
      final body = {userIdKey: userId /*, isSavedForLaterKey: isSavedForLater, restaurantIdKey: restaurantId*/};
      final result = await Api.post(body: body, url: Api.getUserCartUrl, token: true, errorCode: true);
      return CartModel.fromJson(result);
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}

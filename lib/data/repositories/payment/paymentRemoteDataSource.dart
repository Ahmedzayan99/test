import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';


class PaymentRemoteDataSource {
  Future<dynamic> getPayment(String? userId, String? orderId, String? amount) async {
    try {
      final body = {userIdKey: userId, orderIdKey: orderId, amountKey: amount};
      final result = await Api.post(body: body, url: Api.getPaypalLinkUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<dynamic> sendWalletRequest(String? userId, String? amount, String? paymentAddress) async {
    try {
      final body = {userIdKey: userId, amountKey: amount, paymentAddressKey: paymentAddressKey};
      final result = await Api.post(body: body, url: Api.sendWithdrawRequestUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  /*Future<List> getStripeWebhook() async {
    try {
      final body = {};

      final response = await http.post(Uri.parse(stripeWebhookUrl), body: body, headers: Api.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ApiMessageAndCodeException(errorMessage: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<String> addTransaction(String transactionType, String userId, String orderId, String type, String paymentMethod, String txnId, String amount, String status, String message) async {
    try {
      final body = {
      transactionTypeKey: transactionType,
      userIdKey: userId,
      orderIdKey:  orderId,
      typeKey : type,
      paymentMethodKey: paymentMethod,
      txnIdKey : txnId,
      amountKey : amount,
      statusKey : status,
      messageKey : message,
    };
      final response = await http.post(Uri.parse(addTransactionUrl), body: body, headers: Api.getHeaders());
      final Map<String, dynamic>responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw ApiMessageAndCodeException(errorMessage: responseJson['message']);
      }
      return responseJson['data'][type][0].toString();
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<String> placeOrder(String userId, String mobile, String productVariantId, String quantity, String total, String deliveryCharge,
      String taxAmount, String taxPercentage, String finalTotal, String latitude, String longitude, String promoCode, String paymentMethod, String addressId,
      String isWalletUsed, String walletBalanceUsed, String activeStatus, String orderNote, String deliveryTip) async {
    try {
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
        deliveryTipKey: deliveryTip,   //{optional}
      };
      final response = await http.post(Uri.parse(placeOrderUrl), body: body, headers: Api.getHeaders());
      final Map<String, dynamic>responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw ApiMessageAndCodeException(errorMessage: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }*/
}

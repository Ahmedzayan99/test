import 'package:project1/data/model/cartModel.dart';
import 'package:project1/data/repositories/cart/cartRemoteDataSource.dart';
import 'package:project1/utils/api.dart';

class CartRepository {
  static final CartRepository _cartRepository = CartRepository._internal();
  late CartRemoteDataSource _cartRemoteDataSource;

  factory CartRepository() {
    _cartRepository._cartRemoteDataSource = CartRemoteDataSource();
    return _cartRepository;
  }
  CartRepository._internal();

  //to manageCart
  Future<Map<String, dynamic>> manageCartData(
      {String? userId, String? productVariantId, String? isSavedForLater, String? qty, String? addOnId, String? addOnQty}) async {
        try{
    final result = await _cartRemoteDataSource.manageCart(
        userId: userId, productVariantId: productVariantId, isSavedForLater: isSavedForLater, qty: qty, addOnId: addOnId, addOnQty: addOnQty);
    return Map.from(result); //
        } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to placeOrder
  Future<Map<String, dynamic>> placeOrderData(
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
    final result = await _cartRemoteDataSource.placeOrder(
        userId: userId,
        mobile: mobile,
        productVariantId: productVariantId,
        quantity: quantity,
        total: total,
        deliveryCharge: deliveryCharge,
        taxAmount: taxAmount,
        taxPercentage: taxPercentage,
        finalTotal: finalTotal,
        latitude: latitude,
        longitude: longitude,
        promoCode: promoCode,
        paymentMethod: paymentMethod,
        addressId: addressId,
        isWalletUsed: isWalletUsed,
        walletBalanceUsed: walletBalanceUsed,
        activeStatus: activeStatus,
        orderNote: orderNote,
        deliveryTip: deliveryTip);
    return Map.from(result); //
  }

  //to removeFromCart
  Future<Map<String, dynamic>> removeFromCart({String? userId, String? productVariantId}) async {
    final result = await _cartRemoteDataSource.removeCart(userId: userId, productVariantId: productVariantId);
    return Map.from(result); //
  }

  //to clearCart
  Future<Map<String, dynamic>> clearCart({String? userId /*, String? clearCart*/}) async {
    final result = await _cartRemoteDataSource.clearCart(userId: userId /*, clearCart: clearCart*/);
    return Map.from(result); //
  }

  //to getCart
  Future<CartModel> getCartData(String? userId) async {
    try {
      CartModel result = await _cartRemoteDataSource.getCart(userId: userId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

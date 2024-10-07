import 'package:project1/data/model/cartModel.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/data/repositories/cart/cartRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//State
@immutable
abstract class GetCartState {}

class GetCartInitial extends GetCartState {}

class GetCart extends GetCartState {
  //to store cartDetails
  final List<CartModel> cartList;

  GetCart({required this.cartList});
}

class GetCartProgress extends GetCartState {
  GetCartProgress();
}

class GetCartSuccess extends GetCartState {
  final CartModel cartModel;
  GetCartSuccess(this.cartModel);
}

class GetCartFailure extends GetCartState {
  final String errorMessage, errorStatusCode;
  GetCartFailure(this.errorMessage, this.errorStatusCode);
}

class GetCartCubit extends Cubit<GetCartState> {
  final CartRepository _cartRepository;
  GetCartCubit(this._cartRepository) : super(GetCartInitial());

  //to getCart user
  getCartUser({String? userId}) {
    //emitting GetCartProgress state
    emit(GetCartProgress());
    //GetCart user with given user id details in api
    _cartRepository.getCartData(userId).then((value) => emit(GetCartSuccess(value))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("getCartError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(GetCartFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  CartModel getCartModel() {
    if (state is GetCartSuccess) {
      return (state as GetCartSuccess).cartModel;
    } else {
      return CartModel();
    }
  }

  void clearCartModel() {
    if (state is GetCartSuccess) {
      emit(GetCartInitial());
    }
  }

  getProductDetailsData(String id, ProductDetails productDetails) {
    if (state is GetCartSuccess) {
      return (state as GetCartSuccess)
          .cartModel
          .data!
          .firstWhere((element) => element.id == id, orElse: () => Data(productDetails: [productDetails]))
          .productDetails;
    } else {
      return [productDetails];
    }
  }

  void updateCartList(CartModel cartModel) {
    emit(GetCartSuccess(cartModel));
  }

  String getDeliveryStatus() {
    if (state is GetCartSuccess) {
      return (state as GetCartSuccess).cartModel.data![0].productDetails![0].partnerDetails![0].permissions!.deliveryOrders!;
    }
    return '0';
  }

  String cartPartnerId(){
    if (state is GetCartSuccess) {
      return (state as GetCartSuccess).cartModel.data![0].productDetails![0].partnerDetails![0].partnerId!;
    }
    return '';
  }
}

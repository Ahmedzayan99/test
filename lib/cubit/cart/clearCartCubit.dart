import 'package:project1/data/repositories/cart/cartRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//State
@immutable
abstract class ClearCartState {}

class ClearCartInitial extends ClearCartState {}

class ClearCart extends ClearCartState {
  //to clearCart
  final String? userId, productVariantId;

  ClearCart({this.userId, this.productVariantId});
}

class ClearCartProgress extends ClearCartState {
  ClearCartProgress();
}

class ClearCartSuccess extends ClearCartState {
  ClearCartSuccess();
}

class ClearCartFailure extends ClearCartState {
  final String errorMessage, errorStatusCode;
  ClearCartFailure(this.errorMessage, this.errorStatusCode);
}

class ClearCartCubit extends Cubit<ClearCartState> {
  final CartRepository _cartRepository;
  ClearCartCubit(this._cartRepository) : super(ClearCartInitial());

  //to clearCart user
  void clearCart({
    String? userId,
    //String? clearCart,
  }) {
    //emitting clearCartProgress state
    emit(ClearCartProgress());
    //clearCart user in api
    _cartRepository
        .clearCart(
      userId: userId,
      //clearCart: clearCart,
    )
        .then((result) {
      //success
      emit(ClearCartSuccess());
    }).catchError((e) {
      //failure
      ApiMessageAndCodeException cartException = e;
      //print("clearCartError:${apiMessageAndCodeException.errorMessage}");
      emit(ClearCartFailure(cartException.errorMessage.toString(), cartException.errorStatusCode.toString()));
    });
  }
}

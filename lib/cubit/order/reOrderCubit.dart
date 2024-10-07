import 'package:project1/data/model/cartModel.dart';
import 'package:project1/data/repositories/order/orderRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//State
@immutable
abstract class ReOrderState {}

class ReOrderInitial extends ReOrderState {}

class ReOrder extends ReOrderState {
  //to ReOrder
  final String? userId, productVariantId;

  ReOrder({this.userId, this.productVariantId});
}

class ReOrderProgress extends ReOrderState {
  ReOrderProgress();
}

class ReOrderSuccess extends ReOrderState {
  final List<Data> data;
  final String? totalQuantity, subTotal, taxPercentage, taxAmount;
  final double? overallAmount;
  final List<String>? variantId;
  ReOrderSuccess(this.data, this.totalQuantity, this.subTotal, this.taxPercentage, this.taxAmount, this.overallAmount, this.variantId);
}

class ReOrderFailure extends ReOrderState {
  final String errorMessage, errorStatusCode;
  ReOrderFailure(this.errorMessage, this.errorStatusCode);
}

class ReOrderCubit extends Cubit<ReOrderState> {
  final OrderRepository _orderRepository;
  ReOrderCubit(this._orderRepository) : super(ReOrderInitial());

  //to ReOrder
  void reOrder({String? orderId}) {
    //emitting ReOrderProgress state
    emit(ReOrderProgress());
    //ReOrder
    _orderRepository
        .reOrderData(
      orderId: orderId
    )
        .then((result) {
      //success
      emit(ReOrderSuccess(
          (result['cart'] as List).map((e) => Data.fromJson(e)).toList(),
          result['data']['total_quantity'],
          result['data']['sub_total'],
          result['data']['tax_percentage'],
          result['data']['tax_amount'],
          double.parse(result['data']['overall_amount']),
          result['data']['variant_id']));
    }).catchError((e) {
      //failure
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("ReOrderError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(ReOrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
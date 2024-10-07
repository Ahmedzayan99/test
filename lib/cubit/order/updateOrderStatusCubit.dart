import 'package:project1/data/model/orderModel.dart';
import 'package:project1/data/repositories/order/orderRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class UpdateOrderStatusState {}

class UpdateOrderStatusInitial extends UpdateOrderStatusState {}

class UpdateOrderStatus extends UpdateOrderStatusState {
  final OrderModel orderModel;

  UpdateOrderStatus({required this.orderModel});
}

class UpdateOrderStatusProgress extends UpdateOrderStatusState {
  UpdateOrderStatusProgress();
}

class UpdateOrderStatusSuccess extends UpdateOrderStatusState {
  final OrderModel orderModel;
  UpdateOrderStatusSuccess(this.orderModel);
}

class UpdateOrderStatusFailure extends UpdateOrderStatusState {
  final String errorMessage, errorStatusCode;
  UpdateOrderStatusFailure(this.errorMessage, this.errorStatusCode);
}

class UpdateOrderStatusCubit extends Cubit<UpdateOrderStatusState> {
  final OrderRepository _orderRepository;
  UpdateOrderStatusCubit(this._orderRepository) : super(UpdateOrderStatusInitial());

  //to getOrder user
  void getUpdateOrderStatus({
    String? status,
    String? orderId,
    String? reason,
  }) {
    //emitting GetOrderProgress state
    emit(UpdateOrderStatusProgress());
    //GetUpdateOrderStatus particular order details in api
    _orderRepository.updateOrderStatus(status, orderId, reason).then((value) => emit(UpdateOrderStatusSuccess(value))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("UpdateOrderStatusError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(UpdateOrderStatusFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void clearOrderStatus() {
    emit(UpdateOrderStatusInitial());
  }

}

import 'package:project1/data/model/orderLiveTrackingModel.dart';
import 'package:project1/data/repositories/order/orderRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//State
@immutable
abstract class OrderLiveTrackingState {}

class OrderLiveTrackingInitial extends OrderLiveTrackingState {}

class OrderLiveTracking extends OrderLiveTrackingState {
  final OrderLiveTrackingModel orderLiveTrackingList;

  OrderLiveTracking({required this.orderLiveTrackingList});
}

class OrderLiveTrackingProgress extends OrderLiveTrackingState {
  OrderLiveTrackingProgress();
}

class OrderLiveTrackingSuccess extends OrderLiveTrackingState {
  final OrderLiveTrackingModel orderLiveTracking;
  OrderLiveTrackingSuccess(this.orderLiveTracking);
}

class OrderLiveTrackingFailure extends OrderLiveTrackingState {
  final String errorMessage, errorStatusCode;
  OrderLiveTrackingFailure(this.errorMessage, this.errorStatusCode);
}

class OrderLiveTrackingCubit extends Cubit<OrderLiveTrackingState> {
  final OrderRepository _orderRepository;
  OrderLiveTrackingCubit(this._orderRepository) : super(OrderLiveTrackingInitial());

  //to getOrderLiveTracking rider
  void getOrderLiveTracking({
    String? orderId,
  }) {
    if (state is! OrderLiveTrackingSuccess) {
      //emitting OrderLiveTrackingProgress state
      emit(OrderLiveTrackingProgress());
    }
    //getOrderLiveTracking rider details in api
    _orderRepository.getOrderLiveTrackingData(orderId).then((value) => emit(OrderLiveTrackingSuccess(value))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderLiveTrackingError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(OrderLiveTrackingFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

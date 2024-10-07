import 'package:project1/data/model/orderModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderProgress extends OrderState {}

class OrderSuccess extends OrderState {
  final List<OrderModel> orderList;
  final int totalData;
  final bool hasMore;
  OrderSuccess(this.orderList, this.totalData, this.hasMore);
}

class OrderFailure extends OrderState {
  final String errorMessage, errorStatusCode;
  OrderFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());
  Future<List<OrderModel>> _fetchData({
    required String limit,
    String? offset,
    required String? userId,
    String? id,
    String? activeStatus
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId,
        idKey: id ?? "",
      };

      if (offset == null) {
        body.remove(offset);
      }
      if(activeStatus!=null){
        body[activeStatusKey] = activeStatus;
      }
      final result = await Api.post(body: body, url: Api.getOrdersUrl, token: true, errorCode: true);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      //print("orderError:${e.toString()}");
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchOrder(String limit, String userId, String id, String activeStatus) {
    emit(OrderProgress());
    _fetchData(limit: limit, userId: userId, id: id, activeStatus: activeStatus).then((value) {
      final List<OrderModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(OrderSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(OrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreOrderData(String limit, String? userId, String? id, String? activeStatus) {
    _fetchData(limit: limit, offset: (state as OrderSuccess).orderList.length.toString(), userId: userId, id: id, activeStatus: activeStatus).then((value) {
      //
      final oldState = (state as OrderSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.orderList);
      updatedUserDetails.addAll(usersDetails);
      emit(OrderSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderLoadMoreError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(OrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is OrderSuccess) {
      return (state as OrderSuccess).hasMore;
    } else {
      return false;
    }
  }

  void updateOrderRateData(OrderModel orderModel) {
    if (state is OrderSuccess) {
      List<OrderModel> currentOrder = (state as OrderSuccess).orderList;
      bool hasMore = (state as OrderSuccess).hasMore;
      int totalData = (state as OrderSuccess).totalData;
      int i = currentOrder.indexWhere((element) => element.id == orderModel.id);
      currentOrder[i] = orderModel;

      emit(OrderSuccess(List<OrderModel>.from(currentOrder), totalData, hasMore));
    }
  }

}

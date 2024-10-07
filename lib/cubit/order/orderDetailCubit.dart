import 'package:project1/data/model/orderModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailProgress extends OrderDetailState {}

class OrderDetailSuccess extends OrderDetailState {
  final List<OrderModel> orderList;
  final int totalData;
  final bool hasMore;
  OrderDetailSuccess(this.orderList, this.totalData, this.hasMore);
}

class OrderDetailFailure extends OrderDetailState {
  final String errorMessage, errorStatusCode;
  OrderDetailFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit() : super(OrderDetailInitial());
  Future<List<OrderModel>> _fetchData({required String limit, String? offset, required String? userId, String? id, String? activeStatus}) async {
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
      if (activeStatus != null) {
        body[activeStatusKey] = activeStatus;
      }
      final result = await Api.post(body: body, url: Api.getOrdersUrl, token: true, errorCode: true);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      //print("orderError:${e.toString()}");
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchOrderDetail(String limit, String userId, String id, String activeStatus) {
    emit(OrderDetailProgress());
    _fetchData(limit: limit, userId: userId, id: id, activeStatus: activeStatus).then((value) {
      final List<OrderModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(OrderDetailSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(OrderDetailFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreOrderDetailData(String limit, String? userId, String? id, String? activeStatus) {
    _fetchData(limit: limit, offset: (state as OrderDetailSuccess).orderList.length.toString(), userId: userId, id: id, activeStatus: activeStatus)
        .then((value) {
      //
      final oldState = (state as OrderDetailSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.orderList);
      updatedUserDetails.addAll(usersDetails);
      emit(OrderDetailSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderLoadMoreError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(OrderDetailFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is OrderDetailSuccess) {
      return (state as OrderDetailSuccess).hasMore;
    } else {
      return false;
    }
  }

  void updateOrderRiderRateData(String orderId, String newOrderRiderRate) {
    if (state is OrderDetailSuccess) {
      List<OrderModel> currentOrder = (state as OrderDetailSuccess).orderList;
      bool hasMore = (state as OrderDetailSuccess).hasMore;
      int totalData = (state as OrderDetailSuccess).totalData;
      int i = currentOrder.indexWhere((element) => element.id == orderId);
      if (i != -1) {
        currentOrder[i] = currentOrder[i].copyWith(orderRiderRating: newOrderRiderRate);
        emit(OrderDetailSuccess(List<OrderModel>.from(currentOrder), totalData, hasMore));
      }
    }
  }

}

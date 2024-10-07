import 'package:project1/data/model/orderModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class ActiveOrderState {}

class ActiveOrderInitial extends ActiveOrderState {}

class ActiveOrderProgress extends ActiveOrderState {}

class ActiveOrderSuccess extends ActiveOrderState {
  final List<OrderModel> activeOrderList;
  final int totalData;
  final bool hasMore;
  ActiveOrderSuccess(this.activeOrderList, this.totalData, this.hasMore);
}

class ActiveOrderFailure extends ActiveOrderState {
  final String errorMessage, errorStatusCode;
  ActiveOrderFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class ActiveOrderCubit extends Cubit<ActiveOrderState> {
  ActiveOrderCubit() : super(ActiveOrderInitial());
  Future<List<OrderModel>> _fetchData({
    required String limit,
    String? offset,
    required String? userId,
    String? id,
    String? activeStatus,
    String? isSelfPickup
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId,
        idKey: id ?? "",
        isSelfPickUpKey: isSelfPickup ?? ""
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

  void fetchActiveOrder(String limit, String userId, String id, String activeStatus, String isSelfPickup) {
    emit(ActiveOrderProgress());
    _fetchData(limit: limit, userId: userId, id: id, activeStatus: activeStatus, isSelfPickup: isSelfPickup).then((value) {
      final List<OrderModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(ActiveOrderSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(ActiveOrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreActiveOrderData(String limit, String? userId, String? id, String? activeStatus, String? isSelfPickup) {
    _fetchData(limit: limit, offset: (state as ActiveOrderSuccess).activeOrderList.length.toString(), userId: userId, id: id, activeStatus: activeStatus, isSelfPickup: isSelfPickup).then((value) {
      //
      final oldState = (state as ActiveOrderSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.activeOrderList);
      updatedUserDetails.addAll(usersDetails);
      emit(ActiveOrderSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("orderLoadMoreError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(ActiveOrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is ActiveOrderSuccess) {
      return (state as ActiveOrderSuccess).hasMore;
    } else {
      return false;
    }
  }
}

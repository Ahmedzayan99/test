import 'package:project1/utils/api.dart';
import 'package:project1/data/model/promoCodesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class PromoCodeState {}

class PromoCodeInitial extends PromoCodeState {}

class PromoCodeProgress extends PromoCodeState {}

class PromoCodeSuccess extends PromoCodeState {
  final List<PromoCodesModel> promoCodeList;
  final int totalData;
  final bool hasMore;
  PromoCodeSuccess(this.promoCodeList, this.totalData, this.hasMore);
}

class PromoCodeFailure extends PromoCodeState {
  final String errorMessage;
  PromoCodeFailure(this.errorMessage);
}

String? totalHasMore;

class PromoCodeCubit extends Cubit<PromoCodeState> {
  PromoCodeCubit() : super(PromoCodeInitial());
  Future<List<PromoCodesModel>> _fetchData({
    required String limit,
    String? offset,
    String? partnerId
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        partnerIdKey: partnerId
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getPromoCodesUrl, token: true, errorCode: false);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => PromoCodesModel.fromJson(e)).toList();
    } catch (e) {
      //print("promoCodeError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchPromoCode(String limit, String partnerId) {
    emit(PromoCodeProgress());
    _fetchData(limit: limit, partnerId: partnerId).then((value) {
      final List<PromoCodesModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(PromoCodeSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("promoCodeError:${e.toString()}");
      emit(PromoCodeFailure(e.toString()));
    });
  }

  void fetchMorePromoCodeData(String limit, String partnerId) {
    _fetchData(limit: limit, offset: (state as PromoCodeSuccess).promoCodeList.length.toString(), partnerId: partnerId).then((value) {
      //
      final oldState = (state as PromoCodeSuccess);
      final List<PromoCodesModel> usersDetails = value;
      final List<PromoCodesModel> updatedUserDetails = List.from(oldState.promoCodeList);
      updatedUserDetails.addAll(usersDetails);
      emit(PromoCodeSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("promoCodeLoadMoreError:${e.toString()}");
      emit(PromoCodeFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is PromoCodeSuccess) {
      return (state as PromoCodeSuccess).hasMore;
    } else {
      return false;
    }
  }

  promoCodeList() {
    if (state is PromoCodeSuccess) {
      return (state as PromoCodeSuccess).promoCodeList;
    }
    return [];
  }
}

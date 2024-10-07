import 'package:project1/data/model/deliveryBoyRatingModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class GetRiderRatingState {}

class GetRiderRatingInitial extends GetRiderRatingState {}

class GetRiderRatingProgress extends GetRiderRatingState {}

class GetRiderRatingSuccess extends GetRiderRatingState {
  final List<RiderRatingModel> riderRatingList;
  final int totalData;
  final bool hasMore;
  GetRiderRatingSuccess(this.riderRatingList, this.totalData, this.hasMore);
}

class GetRiderRatingFailure extends GetRiderRatingState {
  final String errorMessage, errorStatusCode;
  GetRiderRatingFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class GetRiderRatingCubit extends Cubit<GetRiderRatingState> {
  GetRiderRatingCubit() : super(GetRiderRatingInitial());
  Future<List<RiderRatingModel>> _fetchData({required String limit, String? offset, String? riderId}) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        riderIdKey: riderId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getRiderRatingUrl, token: true, errorCode: true);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => RiderRatingModel.fromJson(e)).toList();
    } catch (e) {
      //print("getRiderRatingError:${e.toString()}");
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  void fetchGetRiderRating(String limit, String riderId) {
    emit(GetRiderRatingProgress());
    _fetchData(limit: limit, riderId: riderId).then((value) {
      final List<RiderRatingModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(GetRiderRatingSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("getRiderRatingError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(GetRiderRatingFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreGetRiderRatingData(String limit, String riderId) {
    _fetchData(limit: limit, offset: (state as GetRiderRatingSuccess).riderRatingList.length.toString(), riderId: riderId).then((value) {
      //
      final oldState = (state as GetRiderRatingSuccess);
      final List<RiderRatingModel> usersDetails = value;
      final List<RiderRatingModel> updatedUserDetails = List.from(oldState.riderRatingList);
      updatedUserDetails.addAll(usersDetails);
      emit(GetRiderRatingSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("getRiderRatingLoadMoreError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(GetRiderRatingFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is GetRiderRatingSuccess) {
      return (state as GetRiderRatingSuccess).hasMore;
    } else {
      return false;
    }
  }
}

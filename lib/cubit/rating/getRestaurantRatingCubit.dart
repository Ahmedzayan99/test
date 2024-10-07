import 'package:project1/data/model/orderRatingModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class GetRestaurantRatingState {}

class GetRestaurantRatingInitial extends GetRestaurantRatingState {}

class GetRestaurantRatingProgress extends GetRestaurantRatingState {}

class GetRestaurantRatingSuccess extends GetRestaurantRatingState {
  final List<OrderRatingModel> restaurantRatingList;
  final int totalData;
  final bool hasMore;
  GetRestaurantRatingSuccess(this.restaurantRatingList, this.totalData, this.hasMore);
}

class GetRestaurantRatingFailure extends GetRestaurantRatingState {
  final String errorMessage, errorStatusCode;
  GetRestaurantRatingFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class GetRestaurantRatingCubit extends Cubit<GetRestaurantRatingState> {
  GetRestaurantRatingCubit() : super(GetRestaurantRatingInitial());
  Future<List<OrderRatingModel>> _fetchData({
    required String limit,
    String? offset,
    String? partnerId,
  }) async {
    try {
      //
      //body of post request
      final body = {limitKey: limit, offsetKey: offset ?? "", partnerIdKey: partnerId ?? ""};
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getPartnerRatingsUrl, token: true, errorCode: true);
      totalHasMore = result['total'].toString();
      return (result['data']['order_rating'] as List).map((e) => OrderRatingModel.fromJson(e)).toList();
    } catch (e) {
      //print("getRestaurantRatingError:${e.toString()}");
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  void fetchGetRestaurantRating(String limit, String partnerId) {
    emit(GetRestaurantRatingProgress());
    _fetchData(limit: limit, partnerId: partnerId).then((value) {
      final List<OrderRatingModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(GetRestaurantRatingSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      print("null${e.toString()}");
      //ApiMessageAndCodeException ratingException = e;
      //print("getRestaurantRatingError:${e.toString()}");
      emit(GetRestaurantRatingFailure(e.toString(), e.toString()));
    });
  }

  void fetchMoreGetRestaurantRatingData(String limit, String partnerId) {
    _fetchData(limit: limit, offset: (state as GetRestaurantRatingSuccess).restaurantRatingList.length.toString(), partnerId: partnerId)
        .then((value) {
      //
      final oldState = (state as GetRestaurantRatingSuccess);
      final List<OrderRatingModel> usersDetails = value;
      final List<OrderRatingModel> updatedUserDetails = List.from(oldState.restaurantRatingList);
      updatedUserDetails.addAll(usersDetails);
      emit(GetRestaurantRatingSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //ApiMessageAndCodeException ratingException = e;
      //print("getRestaurantRatingLoadMoreError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(GetRestaurantRatingFailure(e.toString(), e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is GetRestaurantRatingSuccess) {
      return (state as GetRestaurantRatingSuccess).hasMore;
    } else {
      return false;
    }
  }
}

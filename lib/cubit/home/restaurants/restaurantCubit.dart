import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantProgress extends RestaurantState {}

class RestaurantSuccess extends RestaurantState {
  final List<RestaurantModel> restaurantList;
  final int totalData;
  final bool hasMore;
  RestaurantSuccess(this.restaurantList, this.totalData, this.hasMore);
}

class RestaurantFailure extends RestaurantState {
  final String errorMessage;
  RestaurantFailure(this.errorMessage);
}

String? totalHasMore;

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit() : super(RestaurantInitial());
  Future<List<RestaurantModel>> _fetchData({
    required String limit,
    String? offset,
    String? topRatedPartner,
    String? cityId,
    String? latitude,
    String? longitude,
    String? userId,
    String? id,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        topRatedPartnerKey: topRatedPartner ?? "",
        cityIdKey: cityId ?? "",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId ?? "",
        idKey: id ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getPartnersUrl, token: true, errorCode: false);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => RestaurantModel.fromJson(e)).toList();
    } catch (e) {
      //print("restaurantError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchRestaurant(String limit, String? topRatedPartner, String? cityId, String? latitude, String? longitude, String? userId, String? id) {
    emit(RestaurantProgress());
    _fetchData(limit: limit, topRatedPartner: topRatedPartner, cityId: cityId, latitude: latitude, longitude: longitude, userId: userId, id: id)
        .then((value) {
      final List<RestaurantModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(RestaurantSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("restaurantError:${e.toString()}");
      emit(RestaurantFailure(e.toString()));
    });
  }

  void fetchMoreRestaurantData(
      String limit, String? topRatedPartner, String? cityId, String? latitude, String? longitude, String? userId, String? id) {
    _fetchData(
            limit: limit,
            offset: (state as RestaurantSuccess).restaurantList.length.toString(),
            topRatedPartner: topRatedPartner,
            cityId: cityId,
            latitude: latitude,
            longitude: longitude,
            userId: userId)
        .then((value) {
      //
      final oldState = (state as RestaurantSuccess);
      final List<RestaurantModel> usersDetails = value;
      final List<RestaurantModel> updatedUserDetails = List.from(oldState.restaurantList);
      updatedUserDetails.addAll(usersDetails);
      emit(RestaurantSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("restaurantsLoadMoreError:${e.toString()}");
      emit(RestaurantFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is RestaurantSuccess) {
      return (state as RestaurantSuccess).hasMore;
    } else {
      return false;
    }
  }
}

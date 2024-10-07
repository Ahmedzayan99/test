import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class TopRestaurantState {}

class TopRestaurantInitial extends TopRestaurantState {}

class TopRestaurantProgress extends TopRestaurantState {}

class TopRestaurantSuccess extends TopRestaurantState {
  final List<RestaurantModel> topRestaurantList;
  final int totalData;
  final bool hasMore;
  TopRestaurantSuccess(this.topRestaurantList, this.totalData, this.hasMore);
}

class TopRestaurantFailure extends TopRestaurantState {
  final String errorMessage;
  TopRestaurantFailure(this.errorMessage);
}

String? totalHasMore;

class TopRestaurantCubit extends Cubit<TopRestaurantState> {
  TopRestaurantCubit() : super(TopRestaurantInitial());
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
      //print("topRestaurantError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchTopRestaurant(String limit, String? topRatedPartner, String? cityId, String? latitude, String? longitude, String? userId, String? id) {
    emit(TopRestaurantProgress());
    _fetchData(limit: limit, topRatedPartner: topRatedPartner, cityId: cityId, latitude: latitude, longitude: longitude, userId: userId, id: id)
        .then((value) {
      final List<RestaurantModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(TopRestaurantSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("topRestaurantsError:${e.toString()}");
      emit(TopRestaurantFailure(e.toString()));
    });
  }

  void fetchMoreTopRestaurantData(
      String limit, String? topRatedPartner, String? cityId, String? latitude, String? longitude, String? userId, String? id) {
    _fetchData(
            limit: limit,
            offset: (state as TopRestaurantSuccess).topRestaurantList.length.toString(),
            topRatedPartner: topRatedPartner,
            cityId: cityId,
            latitude: latitude,
            longitude: longitude,
            userId: userId)
        .then((value) {
      //
      final oldState = (state as TopRestaurantSuccess);
      final List<RestaurantModel> usersDetails = value;
      final List<RestaurantModel> updatedUserDetails = List.from(oldState.topRestaurantList);
      updatedUserDetails.addAll(usersDetails);
      emit(TopRestaurantSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("topRestaurantLoadMoreError:${e.toString()}");
      emit(TopRestaurantFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TopRestaurantSuccess) {
      return (state as TopRestaurantSuccess).hasMore;
    } else {
      return false;
    }
  }
}

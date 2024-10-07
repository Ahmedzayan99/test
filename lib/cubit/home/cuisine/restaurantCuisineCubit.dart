import 'package:project1/data/model/cuisineModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class RestaurantCuisineState {}

class RestaurantCuisineInitial extends RestaurantCuisineState {}

class RestaurantCuisineProgress extends RestaurantCuisineState {}

class RestaurantCuisineSuccess extends RestaurantCuisineState {
  final List<CuisineModel> restaurantCuisineList;
  final int totalData;
  final bool hasMore;
  RestaurantCuisineSuccess(this.restaurantCuisineList, this.totalData, this.hasMore);
}

class RestaurantCuisineFailure extends RestaurantCuisineState {
  final String errorMessage;
  RestaurantCuisineFailure(this.errorMessage);
}

String? totalHasMore;

class RestaurantCuisineCubit extends Cubit<RestaurantCuisineState> {
  RestaurantCuisineCubit() : super(RestaurantCuisineInitial());
  Future<List<CuisineModel>> _fetchData({
    required String limit,
    String? offset,
    required String? type,
    String? partnerSlug,
  }) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      if (partnerSlug!= null) {
        body[partnerSlugKey] = partnerSlug;
      }
      final result = await Api.post(body: body, url: Api.getCategoriesUrl, token: true, errorCode: false);
      totalHasMore = result['total'].toString();
      print("totalHasMore:$totalHasMore");
      if (type == popularCategoriesKey) {
        return (result['popular_categories'] as List).map((e) => CuisineModel.fromJson(e)).toList();
      } else {
        return (result['data'] as List).map((e) => CuisineModel.fromJson(e)).toList();
      }
    } catch (e) {
      //print("cuisineError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchRestaurantCuisine(String limit, String type, String partnerSlug) {
    emit(RestaurantCuisineProgress());
    _fetchData(limit: limit, type: type, partnerSlug: partnerSlug).then((value) {
      final List<CuisineModel> usersDetails = value;
      final total = int.parse(totalHasMore!)/* value.length */;
      emit(RestaurantCuisineSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("RestaurantCuisineCubitError:${e.toString()}");
      emit(RestaurantCuisineFailure(e.toString()));
    });
  }

  void fetchMoreRestaurantCuisineData(String limit, String type, String partnerSlug) {
    _fetchData(limit: limit, offset: (state as RestaurantCuisineSuccess).restaurantCuisineList.length.toString(), type: type, partnerSlug: partnerSlug).then((value) {
      //
      final oldState = (state as RestaurantCuisineSuccess);
      final List<CuisineModel> usersDetails = value;
      final List<CuisineModel> updatedUserDetails = List.from(oldState.restaurantCuisineList);
      updatedUserDetails.addAll(usersDetails);
      emit(RestaurantCuisineSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("RestaurantCuisineLoadMoreError:${e.toString()}");
      emit(RestaurantCuisineFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is RestaurantCuisineSuccess) {
      return (state as RestaurantCuisineSuccess).hasMore;
    } else {
      return false;
    }
  }
}

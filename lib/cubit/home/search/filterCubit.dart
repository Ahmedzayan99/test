import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class FilterState {}

class FilterInitial extends FilterState {}

class FilterProgress extends FilterState {}

class FilterSuccess extends FilterState {
  final List<ProductDetails> filterList;
  final int totalData;
  final bool hasMore;
  FilterSuccess(this.filterList, this.totalData, this.hasMore);
}

class FilterFailure extends FilterState {
  final String errorMessage;
  FilterFailure(this.errorMessage);
}

String? totalHasMore;

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(FilterInitial());
  Future<List<ProductDetails>> _fetchData({
    required String limit,
    String? offset,
    String? categoryId,
    String? vegetarian,
    String? order,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
    String? filterBy,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        filterByKey: filterBy,
        categoryIdKey: categoryId ?? "",
        vegetarianKey: vegetarian ?? "",
        sortKey: "pv.price",
        orderKey: order,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId ?? "",
        cityIdKey: cityId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getProductsUrl, token: true, errorCode: false);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => ProductDetails.fromJson(e)).toList();
    } catch (e) {
      //print("filterError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchFilter(String limit, String categoryId, String vegetarian, String order, String? latitude, String? longitude, String? userId,
      String? cityId, String? filterBy) {
    emit(FilterProgress());
    _fetchData(
            limit: limit,
            categoryId: categoryId,
            vegetarian: vegetarian,
            order: order,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId,
            filterBy: filterBy)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(FilterSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("filterError:${e.toString()}");
      emit(FilterFailure(e.toString()));
    });
  }

  void fetchMoreFilterData(String limit, String categoryId, String vegetarian, String order, String? latitude, String? longitude, String? userId,
      String? cityId, String? filterBy) {
    _fetchData(
            limit: limit,
            offset: (state as FilterSuccess).filterList.length.toString(),
            categoryId: categoryId,
            vegetarian: vegetarian,
            order: order,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId,
            filterBy: filterBy)
        .then((value) {
      //
      final oldState = (state as FilterSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails = List.from(oldState.filterList);
      updatedUserDetails.addAll(usersDetails);
      emit(FilterSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("filterLoadMoreError:${e.toString()}");
      emit(FilterFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is FilterSuccess) {
      return (state as FilterSuccess).hasMore;
    } else {
      return false;
    }
  }
}

import 'package:project1/data/model/searchModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchProgress extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SearchModel> searchList;
  final int totalData;
  final bool hasMore;
  SearchSuccess(this.searchList, this.totalData, this.hasMore);
}

class SearchFailure extends SearchState {
  final String errorMessage;
  SearchFailure(this.errorMessage);
}

String? totalHasMore;

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  Future<List<SearchModel>> _fetchData({
    required String limit,
    String? offset,
    String? search,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        searchKey: search ?? "",
        //filterByKey: filterByResturentKey,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId ?? "",
        cityIdKey: cityId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.searchProductUrl, token: true, errorCode: false);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => SearchModel.fromJson(e)).toList();
    } catch (e) {
      //print("searchError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchSearch(String limit, String search, String? latitude, String? longitude, String? userId, String? cityId) {
    emit(SearchProgress());
    _fetchData(limit: limit, search: search, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId).then((value) {
      final List<SearchModel> usersDetails = value;
      final total = /*value.length*/ int.parse(totalHasMore!);
      emit(SearchSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("searchError:${e.toString()}");
      emit(SearchFailure(e.toString()));
    });
  }

  void fetchMoreSearchData(String limit, String search, String? latitude, String? longitude, String? userId, String? cityId) {
    _fetchData(
            limit: limit,
            offset: (state as SearchSuccess).searchList.length.toString(),
            search: search,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId)
        .then((value) {
      //
      final oldState = (state as SearchSuccess);
      final List<SearchModel> usersDetails = value;
      final List<SearchModel> updatedUserDetails = List.from(oldState.searchList);
      updatedUserDetails.addAll(usersDetails);
      emit(SearchSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("searchLoadMoreError:${e.toString()}");
      emit(SearchFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SearchSuccess) {
      return (state as SearchSuccess).hasMore;
    } else {
      return false;
    }
  }
}

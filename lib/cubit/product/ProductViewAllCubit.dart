import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class ProductViewAllState {}

class ProductViewAllInitial extends ProductViewAllState {}

class ProductViewAllProgress extends ProductViewAllState {}

class ProductViewAllSuccess extends ProductViewAllState {
  final List<ProductDetails> productList;
  final int totalData;
  final bool hasMore;
  ProductViewAllSuccess(this.productList, this.totalData, this.hasMore);
}

class ProductViewAllFailure extends ProductViewAllState {
  final String errorMessage;
  ProductViewAllFailure(this.errorMessage);
}

String? totalHasMore;

class ProductViewAllCubit extends Cubit<ProductViewAllState> {
  ProductViewAllCubit() : super(ProductViewAllInitial());

  Future<List<ProductDetails>> _fetchData({
    required String limit,
    String? offset,
    String? partnerId,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
    String? categoryId,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "0",
        partnerIdKey: partnerId,
        filterByKey: filterByProductKey,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId,
        cityIdKey: cityId ?? "",
        //categoryIdKey: categoryId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getProductsUrl, token: true, errorCode: false);
      totalHasMore = result['total'];
      return (result['data'] as List).map((e) => ProductDetails.fromJson(e)).toList();
    } catch (e) {
      //print(e.toString());
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchProduct(String limit, String? partnerId, String? latitude, String? longitude, String? userId, String? cityId, String? categoryId) {
    emit(ProductViewAllProgress());
    _fetchData(limit: limit, partnerId: partnerId, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId, categoryId: categoryId)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(ProductViewAllSuccess(usersDetails, total, total > usersDetails.length));
    }).catchError((e) {
      emit(ProductViewAllFailure(e.toString()));
    });
  }

  void fetchMoreProductData(
      String limit, String? partnerId, String? latitude, String? longitude, String? userId, String? cityId, String? categoryId) {
    _fetchData(
            limit: limit,
            offset: (state as ProductViewAllSuccess).productList.length.toString(),
            partnerId: partnerId,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId,
            categoryId: categoryId)
        .then((value) {
      //
      final oldState = (state as ProductViewAllSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails = List.from(oldState.productList);
      updatedUserDetails.addAll(usersDetails);
      emit(ProductViewAllSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(ProductViewAllFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is ProductViewAllSuccess) {
      return (state as ProductViewAllSuccess).hasMore;
    } else {
      return false;
    }
  }
}

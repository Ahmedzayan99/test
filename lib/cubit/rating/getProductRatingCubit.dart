import 'package:project1/data/model/productRatingModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class GetProductRatingState {}

class GetProductRatingInitial extends GetProductRatingState {}

class GetProductRatingProgress extends GetProductRatingState {}

class GetProductRatingSuccess extends GetProductRatingState {
  final List<ProductRatingModel> productRatingList;
  final int totalData;
  final bool hasMore;
  GetProductRatingSuccess(this.productRatingList, this.totalData, this.hasMore);
}

class GetProductRatingFailure extends GetProductRatingState {
  final String errorMessage, errorStatusCode;
  GetProductRatingFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class GetProductRatingCubit extends Cubit<GetProductRatingState> {
  GetProductRatingCubit() : super(GetProductRatingInitial());
  Future<List<ProductRatingModel>> _fetchData({
    required String limit,
    String? offset,
    String? productId,
  }) async {
    try {
      //
      //body of post request
      final body = {limitKey: limit, offsetKey: offset ?? "", productIdKey: productId ?? ""};
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getProductRatingUrl, token: true, errorCode: true);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => ProductRatingModel.fromJson(e)).toList();
    } catch (e) {
      //print("getProductRatingError:${e.toString()}");
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  void fetchGetProductRating(String limit, String productId) {
    emit(GetProductRatingProgress());
    _fetchData(limit: limit, productId: productId).then((value) {
      final List<ProductRatingModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(GetProductRatingSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException ratingException = e;
      //print("getProductRatingError:${e.toString()}");
      emit(GetProductRatingFailure(ratingException.errorMessage.toString(), ratingException.errorStatusCode.toString()));
    });
  }

  void fetchMoreGetProductRatingData(String limit, String productId) {
    _fetchData(limit: limit, offset: (state as GetProductRatingSuccess).productRatingList.length.toString(), productId: productId).then((value) {
      //
      final oldState = (state as GetProductRatingSuccess);
      final List<ProductRatingModel> usersDetails = value;
      final List<ProductRatingModel> updatedUserDetails = List.from(oldState.productRatingList);
      updatedUserDetails.addAll(usersDetails);
      emit(GetProductRatingSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException ratingException = e;
      //print("getProductRatingLoadMoreError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(GetProductRatingFailure(ratingException.errorMessage.toString(), ratingException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is GetProductRatingSuccess) {
      return (state as GetProductRatingSuccess).hasMore;
    } else {
      return false;
    }
  }
}

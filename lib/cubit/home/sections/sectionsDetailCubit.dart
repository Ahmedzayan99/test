import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class SectionsDetailState {}

class SectionsDetailInitial extends SectionsDetailState {}

class SectionsDetailProgress extends SectionsDetailState {}

class SectionsDetailSuccess extends SectionsDetailState {
  final List<ProductDetails> sectionsDetailList;
  final int totalData;
  final bool hasMore;
  SectionsDetailSuccess(this.sectionsDetailList, this.totalData, this.hasMore);
}

class SectionsDetailFailure extends SectionsDetailState {
  final String errorMessage;
  SectionsDetailFailure(this.errorMessage);
}

String? totalHasMore;

class SectionsDetailCubit extends Cubit<SectionsDetailState> {
  SectionsDetailCubit() : super(SectionsDetailInitial());
  Future<List<ProductDetails>> _fetchData({
    required String limit,
    String? offset,
    String? userId,
    String? latitude,
    String? longitude,
    String? cityId,
    String? sectionId,
  }) async {
    try {
      //
      //body of post request
      final body = {
        pLimitKey: limit,
        pOffsetKey: offset ?? "",
        userIdKey: userId ?? "",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        cityIdKey: cityId ?? "",
        sectionIdKey: sectionId ?? "", 
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getSectionsUrl, token: true, errorCode: false);
      //print("condition${sectionId==null}-----${sectionId!.isEmpty}");
      if(sectionId!.isEmpty){}else{
        totalHasMore = result['data'][0]['total'].toString();
      }
      return (result['data'][0]['product_details'] as List).map((e) => ProductDetails.fromJson(e)).toList();
    } catch (e) {
      //print("sectionsError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchSectionsDetail(String limit, String? userId, String? latitude, String? longitude, String? cityId, String? sectionId) {
    emit(SectionsDetailProgress());
    _fetchData(limit: limit, userId: userId, latitude: latitude, longitude: longitude, cityId: cityId, sectionId: sectionId).then((value) {
      //print(value[0].productDetails);
      final List<ProductDetails> usersDetails = value;
      //List<ProductDetails>? productDetails = value[0].productDetails;
      final total = int.parse(totalHasMore.toString());
      print("total > usersDetails.length${total > usersDetails.length}--$total--${usersDetails.length}");
      emit(SectionsDetailSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("sectionsdetailError:${e.toString()}");
      emit(SectionsDetailFailure(e.toString()));
    });
  }

  void fetchMoreSectionsDetailData(String limit, String? userId, String? latitude, String? longitude, String? cityId, String? sectionId) {
    _fetchData(
            limit: limit,
            offset: (state as SectionsDetailSuccess).sectionsDetailList.length.toString(),
            userId: userId,
            latitude: latitude,
            longitude: longitude,
            cityId: cityId,
            sectionId: sectionId)
        .then((value) {
      //
      final oldState = (state as SectionsDetailSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails = List.from(oldState.sectionsDetailList);
      updatedUserDetails.addAll(usersDetails);
      emit(SectionsDetailSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("sectionLoadMoreError:${e.toString()}");
      emit(SectionsDetailFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SectionsDetailSuccess) {
      return (state as SectionsDetailSuccess).hasMore;
    } else {
      return false;
    }
  }
}

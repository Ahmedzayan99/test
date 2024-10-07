import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class SectionsState {}

class SectionsInitial extends SectionsState {}

class SectionsProgress extends SectionsState {}

class SectionsSuccess extends SectionsState {
  final List<SectionsModel> sectionsList;
  final int totalData;
  final bool hasMore;
  SectionsSuccess(this.sectionsList, this.totalData, this.hasMore);
}

class SectionsFailure extends SectionsState {
  final String errorMessage;
  SectionsFailure(this.errorMessage);
}

String? totalHasMore;

class SectionsCubit extends Cubit<SectionsState> {
  SectionsCubit() : super(SectionsInitial());
  Future<List<SectionsModel>> _fetchData({
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
        //sectionIdKey: sectionId ?? "", 
      };
      if (offset == null) {
        body.remove(offset);
      }
      if(sectionId != null){
        body[sectionIdKey] = sectionId;
      }
      final result = await Api.post(body: body, url: Api.getSectionsUrl, token: true, errorCode: false);
      //print("condition${sectionId==null}-----${sectionId!.isEmpty}");
      if(sectionId!.isEmpty){}else{
        totalHasMore = result['data'][0]['total'].toString();
      }
      return (result['data'] as List).map((e) => SectionsModel.fromJson(e)).toList();
    } catch (e) {
      //print("sectionsError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchSections(String limit, String? userId, String? latitude, String? longitude, String? cityId, String? sectionId) {
    emit(SectionsProgress());
    _fetchData(limit: limit, userId: userId, latitude: latitude, longitude: longitude, cityId: cityId, sectionId: sectionId).then((value) {
      //print(value[0].productDetails);
      final List<SectionsModel> usersDetails = value;
      //List<ProductDetails>? productDetails = value[0].productDetails;
      final total = sectionId!.isEmpty?value.length:int.parse(totalHasMore.toString());
      emit(SectionsSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      //print("sectionsError:${e.toString()}");
      emit(SectionsFailure(e.toString()));
    });
  }

  void fetchMoreSectionsData(String limit, String? userId, String? latitude, String? longitude, String? cityId, String? sectionId) {
    _fetchData(
            limit: limit,
            offset: sectionId!.isEmpty?(state as SectionsSuccess).sectionsList.length.toString():(state as SectionsSuccess).sectionsList[0].productDetails!.length.toString(),
            userId: userId,
            latitude: latitude,
            longitude: longitude,
            cityId: cityId,
            sectionId: sectionId)
        .then((value) {
      //
      final oldState = (state as SectionsSuccess);
      final List<SectionsModel> usersDetails = value;
      final List<SectionsModel> updatedUserDetails = List.from(oldState.sectionsList);
      updatedUserDetails.addAll(usersDetails);
      emit(SectionsSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      //print("sectionLoadMoreError:${e.toString()}");
      emit(SectionsFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SectionsSuccess) {
      return (state as SectionsSuccess).hasMore;
    } else {
      return false;
    }
  }
}

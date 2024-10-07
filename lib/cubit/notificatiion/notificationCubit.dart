import 'package:project1/data/model/NotificationModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notificationList;
  final int totalData;
  final bool hasMore;
  NotificationSuccess(this.notificationList, this.totalData, this.hasMore);
}

class NotificationFailure extends NotificationState {
  final String errorMessage;
  NotificationFailure(this.errorMessage);
}

String? totalHasMore;

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  Future<List<NotificationModel>> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getNotificationsUrl, token: true, errorCode: false);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      //print("notificationError:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchNotification(String limit) {
    emit(NotificationProgress());
    _fetchData(limit: limit).then((value) {
      final List<NotificationModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(NotificationSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(NotificationFailure(e.toString()));
    });
  }

  void fetchMoreNotificationData(String limit) {
    _fetchData(limit: limit, offset: (state as NotificationSuccess).notificationList.length.toString()).then((value) {
      //
      final oldState = (state as NotificationSuccess);
      final List<NotificationModel> usersDetails = value;
      final List<NotificationModel> updatedUserDetails = List.from(oldState.notificationList);
      updatedUserDetails.addAll(usersDetails);
      emit(NotificationSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(NotificationFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is NotificationSuccess) {
      return (state as NotificationSuccess).hasMore;
    } else {
      return false;
    }
  }
}

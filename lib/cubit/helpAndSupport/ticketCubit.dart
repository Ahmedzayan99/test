import 'package:project1/data/model/ticketModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

@immutable
abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketProgress extends TicketState {}

class TicketSuccess extends TicketState {
  final List<TicketModel> ticketList;
  final int totalData;
  final bool hasMore;
  TicketSuccess(this.ticketList, this.totalData, this.hasMore);
}

class TicketFailure extends TicketState {
  final String errorMessage, errorStatusCode;
  TicketFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class TicketCubit extends Cubit<TicketState> {
  TicketCubit() : super(TicketInitial());
  Future<List<TicketModel>> getTicket({
    required String limit,
    String? offset,
    String? userId,
  }) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getTicketsUrl, token: true, errorCode: true);
      totalHasMore = result['total'].toString();
      return (result['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      //print("ticketError:${e.toString()}");
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchTicket(String limit, String userId) {
    emit(TicketProgress());
    getTicket(limit: limit, userId: userId).then((value) {
      final List<TicketModel> usersDetails = value;
      final total =  int.parse(totalHasMore!);
      emit(TicketSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException ticketException = e;
      emit(TicketFailure(ticketException.errorMessage.toString(), ticketException.errorStatusCode.toString()));
    });
  }

  void fetchMoreTicketData(String limit, String userId) {
    getTicket(limit: limit, offset: (state as TicketSuccess).ticketList.length.toString(), userId: userId).then((value) {
      //
      final oldState = (state as TicketSuccess);
      final List<TicketModel> usersDetails = value;
      final List<TicketModel> updatedUserDetails = List.from(oldState.ticketList);
      updatedUserDetails.addAll(usersDetails);
      emit(TicketSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException ticketException = e;
      emit(TicketFailure(ticketException.errorMessage.toString(), ticketException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TicketSuccess) {
      return (state as TicketSuccess).hasMore;
    } else {
      return false;
    }
  }

  void addTicket(TicketModel ticketModel) {
    print("addTicketStateCubit:${state.toString()}");
    if (state is TicketSuccess) {
      //
      List<TicketModel> currentTicket = (state as TicketSuccess).ticketList;
      bool hasMore = (state as TicketSuccess).hasMore;
      int totalData = (state as TicketSuccess).totalData;
      print("addTicketHasMore:$hasMore------$totalData");
      currentTicket.insert(0, ticketModel);
      emit(TicketSuccess(List<TicketModel>.from(currentTicket), totalData, hasMore));
    }
  }

  void editTicket(TicketModel ticketModel) {
    if (state is TicketSuccess) {
      //
      List<TicketModel> currentTicket = (state as TicketSuccess).ticketList;
      int i = currentTicket.indexWhere((element) => element.id == ticketModel.id);
      bool hasMore = (state as TicketSuccess).hasMore;
      int totalData = (state as TicketSuccess).totalData;
      currentTicket[i] = ticketModel;

      emit(TicketSuccess(List<TicketModel>.from(currentTicket), totalData, hasMore));
    }
  }
}

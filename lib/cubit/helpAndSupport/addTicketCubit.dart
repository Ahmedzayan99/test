import 'package:project1/data/repositories/helpAndSupport/helpAndSupportRepository.dart';
import 'package:project1/data/model/ticketModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddTicketState {}

class AddTicketInitial extends AddTicketState {}

class AddTicketProgress extends AddTicketState {}

class AddTicketSuccess extends AddTicketState {
  final TicketModel ticketModel;

  AddTicketSuccess(this.ticketModel);
}

class AddTicketFailure extends AddTicketState {
  final String errorCode, errorStatusCode;
  AddTicketFailure(this.errorCode, this.errorStatusCode);
}

class AddTicketCubit extends Cubit<AddTicketState> {
  final HelpAndSupportRepository _helpAndSupportRepository;

  AddTicketCubit(this._helpAndSupportRepository) : super(AddTicketInitial());

  void fetchAddTicket(String? ticketTypeId, String? subject, String? email, String? description, String? userId) {
    emit(AddTicketProgress());
    _helpAndSupportRepository.getAddTicket(ticketTypeId, subject, email, description, userId).then((value) {
      //print("addTicket:${TicketModel.fromJson(value[0])}");
      emit(AddTicketSuccess(TicketModel.fromJson(value[0])));
    }).catchError((e) {
      print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("addTicketError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(AddTicketFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

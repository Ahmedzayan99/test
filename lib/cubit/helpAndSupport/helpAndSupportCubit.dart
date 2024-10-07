import 'package:project1/data/model/helpAndSupportModel.dart';
import 'package:project1/data/repositories/helpAndSupport/helpAndSupportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HelpAndSupportState {}

class HelpAndSupportInitial extends HelpAndSupportState {}

class HelpAndSupportProgress extends HelpAndSupportState {}

class HelpAndSupportSuccess extends HelpAndSupportState {
  final List<HelpAndSupportModel> helpAndSupportList;

  HelpAndSupportSuccess(this.helpAndSupportList);
}

class HelpAndSupportFailure extends HelpAndSupportState {
  final String errorCode;

  HelpAndSupportFailure(this.errorCode);
}

class HelpAndSupportCubit extends Cubit<HelpAndSupportState> {
  final HelpAndSupportRepository _helpAndSupportRepository;

  HelpAndSupportCubit(this._helpAndSupportRepository) : super(HelpAndSupportInitial());

  void fetchHelpAndSupport() {
    emit(HelpAndSupportProgress());
    _helpAndSupportRepository.getHelpAndSupport().then((value) => emit(HelpAndSupportSuccess(value))).catchError((e) {
      //print("helpAndSupportError:${e.toString()}");
      emit(HelpAndSupportFailure(e.toString()));
    });
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';

//State
@immutable
abstract class ResendOtpState {}

class ResendOtpInitial extends ResendOtpState {}

class ResendOtpProgress extends ResendOtpState {
  ResendOtpProgress();
}

class ResendOtpSuccess extends ResendOtpState {
  ResendOtpSuccess();
}

class ResendOtpFailure extends ResendOtpState {
  final String errorMessage;
  ResendOtpFailure(this.errorMessage);
}

class ResendOtpCubit extends Cubit<ResendOtpState> {
  final AuthRepository _authRepository;
  ResendOtpCubit(this._authRepository) : super(ResendOtpInitial());

  //to signIn user
  void resentOtp({String? mobile}) {
    //emitting signInProgress state
    emit(ResendOtpProgress());
    //signIn user with given provider and also add user detials in api
    _authRepository.resentOtp(mobile: mobile).then((result) {
      //success
      emit(ResendOtpSuccess());
    }).catchError((e) {
      //failure
      //print("verifyUserError:${e.toString()}");
      emit(ResendOtpFailure(e.toString()));
    });
  }
}

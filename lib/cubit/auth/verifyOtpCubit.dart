import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';

//State
@immutable
abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpProgress extends VerifyOtpState {
  VerifyOtpProgress();
}

class VerifyOtpSuccess extends VerifyOtpState {
  VerifyOtpSuccess();
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;
  VerifyOtpFailure(this.errorMessage);
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _authRepository;
  VerifyOtpCubit(this._authRepository) : super(VerifyOtpInitial());

  //to signIn user
  void verifyOtp({String? mobile, String? otp}) {
    //emitting signInProgress state
    emit(VerifyOtpProgress());
    //signIn user with given provider and also add user detials in api
    _authRepository.verifyOtp(mobile: mobile, otp: otp).then((result) {
      //success
      emit(VerifyOtpSuccess());
    }).catchError((e) {
      //failure
      //print("verifyUserError:${e.toString()}");
      emit(VerifyOtpFailure(e.toString()));
    });
  }
}

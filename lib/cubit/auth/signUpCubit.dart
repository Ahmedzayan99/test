import 'package:project1/data/model/authModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';

//State
@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUp extends SignUpState {
  //to store authDetails
  final AuthModel authModel;

  SignUp({required this.authModel});
}

class SignUpProgress extends SignUpState {
  SignUpProgress();
}

class SignUpSuccess extends SignUpState {
  final AuthModel authModel;
  final String? message;
  SignUpSuccess({required this.authModel, this.message});
}

class SignUpFailure extends SignUpState {
  final String errorMessage;
  SignUpFailure(this.errorMessage);
}

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;
  SignUpCubit(this._authRepository) : super(SignUpInitial());

  //to signUp user
  void signUpUser({
    String? name,
    String? email,
    String? mobile,
    String? countryCode,
    //String? password,
    String? fcmId,
    String? friendCode,
    String? referCode,
    //String? latitude,
    //String? longitude
  }) {
    //emitting signUpProgress state
    //  emit(SignInProgress(authProvider));
    //signUp user with given provider and also add user details in api
    _authRepository
        .addUserData(
      name: name,
      email: email,
      mobile: mobile,
      countryCode: countryCode ?? "",
      //password: password,
      fcmId: fcmId ?? "",
      friendCode: friendCode ?? "",
      referCode: referCode ?? "",
      //latitude: latitude ?? "",
      //longitude: longitude ?? ""
    )
        .then((result) {
      //success
      emit(SignUpSuccess(authModel: AuthModel.fromJson(result)));
    }).catchError((e) {
      //failure
      //print("signUpUserError:${e.toString()}");
      emit(SignUpFailure(e.toString()));
    });
  }
}

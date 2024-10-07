import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/data/model/authModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';

//State
@immutable
abstract class SocialSignUpState {}

class SocialSignUpInitial extends SocialSignUpState {}

class SocialSignUp extends SocialSignUpState {
  //to store authDetails
  final AuthModel authModel;

  SocialSignUp({required this.authModel});
}

class SocialSignUpProgress extends SocialSignUpState {
  SocialSignUpProgress();
}

class SocialSignUpSuccess extends SocialSignUpState {
  final AuthModel authModel;
  final String? message;
  SocialSignUpSuccess({required this.authModel, this.message});
}

class SocialSignUpFailure extends SocialSignUpState {
  final String errorMessage;
  SocialSignUpFailure(this.errorMessage);
}

class SocialSignUpCubit extends Cubit<SocialSignUpState> {
  final AuthRepository _authRepository;
  SocialSignUpCubit(this._authRepository) : super(SocialSignUpInitial());

  //to socialSocialSignUp user
  // void socialSocialSignUpUser({
  //   AuthProviders? authProvider,
  //   String? friendCode,
  //   String? referCode,
  // }) {
  //   //emitting SocialSignUpProgress state
  //   //  emit(SocialSignUpProgress(authProvider));
  //   //socialSocialSignUp user details in api
  //   _authRepository.signInUser(authProvider!, referCode, friendCode).then((result) {
  //     print(result);
  //     //success
  //     emit(SocialSignUpSuccess(authModel: AuthModel.fromJson(result['data']), message: result['message']));
  //   }).catchError((e) {
  //     //failure
  //     print("socialSocialSignUp${e.toString()}");
  //     //print("socialSignInError:${e.toString()}");
  //     emit(SocialSignUpFailure(e.toString()));
  //   });
  // }
}

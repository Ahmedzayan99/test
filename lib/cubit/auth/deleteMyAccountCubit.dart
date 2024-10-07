import 'package:project1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';

//State
@immutable
abstract class DeleteMyAccountState {}

class DeleteMyAccountInitial extends DeleteMyAccountState {}

class DeleteMyAccountProgress extends DeleteMyAccountState {
  DeleteMyAccountProgress();
}

class DeleteMyAccountSuccess extends DeleteMyAccountState {
  DeleteMyAccountSuccess();
}

class DeleteMyAccountFailure extends DeleteMyAccountState {
  final String errorMessage, errorStatusCode;
  DeleteMyAccountFailure(this.errorMessage, this.errorStatusCode);
}

class DeleteMyAccountCubit extends Cubit<DeleteMyAccountState> {
  final AuthRepository _authRepository;
  DeleteMyAccountCubit(this._authRepository) : super(DeleteMyAccountInitial());

  //to delete my account
  void deleteMyAccount({String? userId}) {
    //emitting DeleteMyAccountProgress state
    emit(DeleteMyAccountProgress());
    //to delete my account
    _authRepository.deleteMyAccount(userId: userId).then((result) {
      //success
      emit(DeleteMyAccountSuccess());
    }).catchError((e) {
      //failure
      ApiMessageAndCodeException authException  = e;
      //print("deleteAccountError:${apiMessageAndCodeException.errorMessage}");
      emit(DeleteMyAccountFailure(authException.errorMessage.toString(), authException.errorStatusCode.toString()));
    });
  }
}

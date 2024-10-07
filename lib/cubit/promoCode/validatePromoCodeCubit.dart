import 'package:project1/utils/api.dart';
import 'package:project1/data/repositories/promoCode/promoCodeRepository.dart';
import 'package:project1/data/model/promoCodeValidateModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ValidatePromoCodeState {}

class ValidatePromoCodeIntial extends ValidatePromoCodeState {}

class ValidatePromoCodeFetchInProgress extends ValidatePromoCodeState {}

class ValidatePromoCodeFetchSuccess extends ValidatePromoCodeState {
  final PromoCodeValidateModel? promoCodeValidateModel;

  ValidatePromoCodeFetchSuccess({this.promoCodeValidateModel});
}

class ValidatePromoCodeFetchFailure extends ValidatePromoCodeState {
  final String errorMessage, errorStatusCode;
  ValidatePromoCodeFetchFailure(this.errorMessage, this.errorStatusCode);
}

class ValidatePromoCodeCubit extends Cubit<ValidatePromoCodeState> {
  final PromoCodeRepository _validatePromoCodeRepository;
  ValidatePromoCodeCubit(this._validatePromoCodeRepository) : super(ValidatePromoCodeIntial());

  //to ValidatePromoCode
  void getValidatePromoCode(String? promoCode, String? userId, String? finalTotal, String? walletBalanceUsed, String? partnerId) {
  
    //emitting ValidatePromoCodeFetchInProgress state
    emit(ValidatePromoCodeFetchInProgress());
    //ValidatePromoCode
    _validatePromoCodeRepository
        .validatePromoCodeData(promoCode: promoCode, userId: userId, finalTotal: finalTotal, walletBalanceUsed: walletBalanceUsed, partnerId: partnerId)
        .then((value) => emit(ValidatePromoCodeFetchSuccess(promoCodeValidateModel: value)))
        .catchError((e) {
        ApiMessageAndCodeException apiMessageAndCodeException = e;
        //print("validatePromoCodeError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(ValidatePromoCodeFetchFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

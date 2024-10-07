//State
import 'package:project1/data/repositories/payment/paymentRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SendWithdrawRequestState {}

class SendWithdrawRequestIntial extends SendWithdrawRequestState {}

class SendWithdrawRequestFetchInProgress extends SendWithdrawRequestState {}

class SendWithdrawRequestFetchSuccess extends SendWithdrawRequestState {
  final String? userId, amount, paymentAddress, walletAmount;

  SendWithdrawRequestFetchSuccess({this.userId, this.amount, this.paymentAddress, this.walletAmount});
}

class SendWithdrawRequestFetchFailure extends SendWithdrawRequestState {
  final String errorCode, errorStatusCode;
  SendWithdrawRequestFetchFailure(this.errorCode, this.errorStatusCode);
}

class SendWithdrawRequestCubit extends Cubit<SendWithdrawRequestState> {
  final PaymentRepository _paymentRepository;
  SendWithdrawRequestCubit(this._paymentRepository) : super(SendWithdrawRequestIntial());

  //to sendWithdrawRequest user
  void sendWithdrawRequest(String? userId, String? amount, String? paymentAddress) {
    //emitting SendWithdrawRequestProgress state
    emit(SendWithdrawRequestFetchInProgress());
    //SendWithdrawRequest in api
    _paymentRepository
        .sendWalletRequest(userId, amount, paymentAddress)
        .then((value) => emit(SendWithdrawRequestFetchSuccess(userId: userId, amount: amount, paymentAddress: paymentAddress, walletAmount: value)))
        .catchError((e) {
          ApiMessageAndCodeException apiMessageAndCodeException  = e;
          //print("sendWithdrawRequestError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(SendWithdrawRequestFetchFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

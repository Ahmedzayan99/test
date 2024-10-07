import 'package:project1/data/repositories/payment/paymentRemoteDataSource.dart';
import 'package:project1/utils/api.dart';

class PaymentRepository {
  static final PaymentRepository _paymentRepository = PaymentRepository._internal();
  late PaymentRemoteDataSource _paymentRemoteDataSource;

  factory PaymentRepository() {
    _paymentRepository._paymentRemoteDataSource = PaymentRemoteDataSource();
    return _paymentRepository;
  }

  PaymentRepository._internal();

  Future<String> getPayment(String? userId, String? orderId, String? amount) async {
    try {
      final result = await _paymentRemoteDataSource.getPayment(userId, orderId, amount);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<String> sendWalletRequest(String? userId, String? amount, String? paymentAddress) async {
    try {
      final result = await _paymentRemoteDataSource.sendWalletRequest(userId, amount, paymentAddress);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<String> getAppSettings(String? userId, String? orderId, String? amount) async {
    try {
      final result = await _paymentRemoteDataSource.getPayment(userId, orderId, amount);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

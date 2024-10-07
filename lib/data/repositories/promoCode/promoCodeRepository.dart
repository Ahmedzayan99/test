import 'package:project1/data/repositories/promoCode/promoCodeRemoteDataSource.dart';
import 'package:project1/data/model/promoCodeValidateModel.dart';
import 'package:project1/utils/api.dart';

class PromoCodeRepository {
  static final PromoCodeRepository _promoCodeRepository = PromoCodeRepository._internal();
  late PromoCodeRemoteDataSource _promoCodeRemoteDataSource;

  factory PromoCodeRepository() {
    _promoCodeRepository._promoCodeRemoteDataSource = PromoCodeRemoteDataSource();
    return _promoCodeRepository;
  }
  PromoCodeRepository._internal();

  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<PromoCodeValidateModel> validatePromoCodeData({String? promoCode, String? userId, String? finalTotal, String? walletBalanceUsed, String? partnerId}) async {
    try {
      final result = await _promoCodeRemoteDataSource.validatePromoCode(promoCode: promoCode, userId: userId, finalTotal: finalTotal, walletBalanceUsed: walletBalanceUsed, partnerId: partnerId);
      print("Type:$result");
      return result; //
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

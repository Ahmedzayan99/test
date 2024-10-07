import 'package:project1/data/model/promoCodeValidateModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';


class PromoCodeRemoteDataSource {
//to promoCode
  Future<PromoCodeValidateModel> validatePromoCode({String? promoCode, String? userId, String? finalTotal, String? walletBalanceUsed, String? partnerId}) async {
    try {
      //body of post request
      final body = {promoCodeKey: promoCode, userIdKey: userId, finalTotalKey: finalTotal, walletBalanceUsedKey: walletBalanceUsed, partnerIdKey: partnerId};
      final result = await Api.post(body: body, url: Api.validatePromoCodeUrl, token: true, errorCode: true);
      return PromoCodeValidateModel.fromJson(result['data'][0]);
    } catch (e) {
      print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}

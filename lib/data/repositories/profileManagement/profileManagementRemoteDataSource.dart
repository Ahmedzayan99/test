import 'dart:convert';
import 'dart:io';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';

class ProfileManagementRemoteDataSource {

  Future addProfileImage(File? images, String? userId) async {
    try {
      Map<String, String?> body = {userIdKey: userId};
      Map<String, File?> fileList = {
        imageKey: images,
      };
      var response = await Api.postApiFileProfilePic(Uri.parse(Api.updateUserUrl), fileList, body, userId);
      final res = json.decode(response);
      if (res['error']) {
        throw ApiMessageAndCodeException(errorMessage: res['message'],errorStatusCode: res["status_code"].toString());
      }
      return res['data'];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException  = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(),errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  

  Future<void> updateProfile({String? userId, String? email, String? name, String? mobile, String? referralCode}) async {
    try {
      //body of post request
      Map<String, String> body = {userIdKey: userId!, emailKey: email!, nameKey: name!, mobileKey: mobile!,  referralCodeKey: referralCode!};
      final result = await Api.post(body: body, url: Api.updateUserUrl, token: true, errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}

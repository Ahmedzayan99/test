import 'package:project1/data/model/addressModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/hiveBoxKey.dart';

class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddress(String? userId) async {
    try {
      final body = {userIdKey: userId};
      final result = await Api.post(body: body, url: Api.getAddressUrl, token: true, errorCode: true);
      return (result['data'] as List).map((e) => AddressModel.fromJson(Map.from(e))).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future addAddress(
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final body = {
        userIdKey: userId,
        mobileKey: mobile,
        addressKey: address,
        cityKey: city,
        latitudeKey: latitude,
        longitudeKey: longitude,
        areaKey: area ?? "",
        typeKey: type,
        nameKey: name,
        countryCodeKey: countryCode,
        alternateCountryCodeKey: alternateCountryCode,
        alternateMobileKey: alternateMobile,
        landmarkKey: landmark,
        pinCodeKey: pincode,
        stateKey: state,
        countryKey: country,
        isDefaultKey: isDefault
      };
      final result = await Api.post(body: body, url: Api.addAddressUrl, token: true, errorCode: true);
      return (result['data'] as List).first;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future updateAddress(
      String? id,
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final body = {
        idKey: id,
        userIdKey: userId,
        mobileKey: mobile,
        addressKey: address,
        cityKey: city ?? "",
        latitudeKey: latitude,
        longitudeKey: longitude,
        areaKey: area ?? "",
        typeKey: type ?? "",
        nameKey: name,
        countryCodeKey: countryCode,
        alternateCountryCodeKey: alternateCountryCode,
        alternateMobileKey: alternateMobile,
        landmarkKey: landmark ?? "",
        pinCodeKey: pincode,
        stateKey: state,
        countryKey: country,
        isDefaultKey: isDefault
      };
      final result = await Api.post(body: body, url: Api.updateAddressUrl, token: true, errorCode: true);
      return (result['data'] as List).first;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future deleteAddress(String? id) async {
    try {
      final body = {idKey: id};
      final result = await Api.post(body: body, url: Api.deleteAddressUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future checkCityDeliverable(String? name) async {
    try {
      final body = {nameKey: name};
      final result = await Api.post(body: body, url: Api.isCityDeliverableUrl, token: true, errorCode: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future checkIsOrderDeliverable(String? partnerId, String? latitude, String? longitude, String? addressId) async {
    try {
      final body = {partnerIdKey: partnerId, latitudeKey: latitude, longitudeKey: longitude, addressIdKey: addressId};
      final result = await Api.post(body: body, url: Api.isOrderDeliverableUrl, token: true, errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future checkDeliveryChargeCubit(String? userId, String? addressId, String? finalTotal) async {
    try {
      final body = {userIdKey: userId, addressIdKey: addressId, finalTotalKey: finalTotal};
      final result = await Api.post(body: body, url: Api.getDeliveryChargesUrl, token: true, errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}

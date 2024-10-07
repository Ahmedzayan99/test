import 'package:project1/data/localDataStore/addressLocalDataSource.dart';
import 'package:project1/data/model/addressModel.dart';
import 'package:project1/data/repositories/address/addressRemoteDataSource.dart';
import 'package:project1/utils/api.dart';

class AddressRepository {
  static final AddressRepository _addressRepository = AddressRepository._internal();
  late AddressRemoteDataSource _addressRemoteDataSource;
  late AddressLocalDataSource _addressLocalDataSource;

  factory AddressRepository() {
    _addressRepository._addressRemoteDataSource = AddressRemoteDataSource();
    _addressRepository._addressLocalDataSource = AddressLocalDataSource();
    return _addressRepository;
  }

  AddressRepository._internal();
  AddressLocalDataSource get addressLocalDataSource => _addressLocalDataSource;

  Future<List<AddressModel>> getAddress(String? userId) async {
    try {
      List<AddressModel> result = await _addressRemoteDataSource.getAddress(userId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getAddAddress(
      String? userId,
      String? mobile,
      String? address,
      String? cityId,
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
      final result = await _addressRemoteDataSource.addAddress(userId, mobile, address, cityId, latitude, longitude, area, type, name, countryCode, alternateCountryCode,
          alternateMobile, landmark, pincode, state, country, isDefault);
      _addressLocalDataSource.setCity(result['city']);
      _addressLocalDataSource.setLatitude(result['latitude']);
      _addressLocalDataSource.setLongitude(result['longitude']);
      _addressLocalDataSource.getCity();
      print("city:" + result['latitude'] + result['longitude'] + _addressLocalDataSource.getCity());
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getUpdateAddress(
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
      final result = await _addressRemoteDataSource.updateAddress(id ?? "", userId, mobile, address, city, latitude, longitude, area ?? "", type,
          name, countryCode, alternateCountryCode, alternateMobile ?? "", landmark ?? "", pincode ?? "", state ?? "", country ?? "", isDefault ?? "");
      _addressLocalDataSource.setCity(result['city']);
      _addressLocalDataSource.setLatitude(result['latitude']);
      _addressLocalDataSource.setLongitude(result['longitude']);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      print("Update Address:$e");
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getDeleteAddress(String? id) async {
    try {
      final result = await _addressRemoteDataSource.deleteAddress(id);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getCityDeliverable(String? name) async {
    try {
      final result = await _addressRemoteDataSource.checkCityDeliverable(name);
      //print("hellow"+result['city_id'].toString());
      await _addressLocalDataSource.setCityId(result['city_id']);
      //await _addressLocalDataSource.getCityId();

      return result['city_id'];
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getIsOrderDeliverable(String? partnerId, String? latitude, String? longitude, String? addressId) async {
    try {
      final result = await _addressRemoteDataSource.checkIsOrderDeliverable(partnerId, latitude, longitude, addressId);
      return result['message'];
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<Map> getDeliveryCharge(String? userId, String? addressId, String? finalTotal) async {
    try {
      final result = await _addressRemoteDataSource.checkDeliveryChargeCubit(userId, addressId, finalTotal);
      //await _addressLocalDataSource.setCityId(result);
      //await _addressLocalDataSource.getCityId();
      print("result is:${Map.from(result)['delivery_charge']}");

      return Map.from(result);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      print("error$e");
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

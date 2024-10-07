

import 'package:project1/data/model/boundaryPointsModel.dart';

class AddressModel {
  String? id;
  String? userId;
  String? name;
  String? type;
  String? mobile;
  String? alternateMobile;
  String? address;
  String? landmark;
  String? area;
  String? cityId;
  String? pincode;
  String? countryCode;
  String? alternateCountryCode;
  String? state;
  String? country;
  String? isDeliverable;
  String? latitude;
  String? longitude;
  String? isDefault;
  String? city;
  String? cityLatitude;
  String? cityLongitude;
  String? minimumFreeDeliveryOrderAmount;
  String? deliveryCharges;
  String? geolocationType;
  String? radius;
  List<BoundaryPoints>? boundaryPoints;

  AddressModel({this.id,
    this.userId,
    this.name,
    this.type,
    this.mobile,
    this.alternateMobile,
    this.address,
    this.landmark,
    this.area,
    this.cityId,
    this.pincode,
    this.countryCode,
    this.alternateCountryCode,
    this.state,
    this.country,
    this.isDeliverable,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.city,
    this.cityLatitude,
    this.cityLongitude,
    this.minimumFreeDeliveryOrderAmount,
    this.deliveryCharges,
    this.geolocationType,
    this.radius,
    this.boundaryPoints});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    userId = json['user_id'] ?? "";
    name = json['name'] ?? "";
    type = json['type'] ?? "";
    mobile = json['mobile'] ?? "";
    alternateMobile = json['alternate_mobile'] ?? "";
    address = json['address'] ?? "";
    landmark = json['landmark'] ?? "";
    area = json['area'] ?? "";
    cityId = json['city_id'] ?? "";
    pincode = json['pincode'] ?? "";
    countryCode = json['country_code'] ?? "";
    alternateCountryCode = json["alternate_country_code"] ?? "";
    state = json['state'] ?? "";
    country = json['country'] ?? "";
    isDeliverable = json['is_deliverable'] ?? "";
    latitude = json['latitude'] ?? "";
    longitude = json['longitude'] ?? "";
    isDefault = json['is_default'] ?? "";
    city = json['city'] ?? "";
    cityLatitude = json['city_latitude'] ?? "";
    cityLongitude = json['city_longitude'] ?? "";
    minimumFreeDeliveryOrderAmount =
        json['minimum_free_delivery_order_amount'] ?? "";
    deliveryCharges = json['delivery_charges'] ?? "";
    geolocationType = json['geolocation_type'] ?? "";
    radius = json['radius'] ?? "";
    if (json['boundary_points'] != null) {
      boundaryPoints = <BoundaryPoints>[];
      json['boundary_points'].forEach((v) {
        boundaryPoints!.add(BoundaryPoints.fromJson(v));
      });
    }
  }


  AddressModel copyWith({String? id, String? userId, String? mobile, String? address, String? city, String? latitude, String? longitude,
    String? area, String? type, String? name, String? countryCode, String? alternateCountryCode, String? alternateMobile, String? landmark, String? pincode, String? state, String? country, String? isDefault}) {
    return AddressModel(
        id: this.id,
        userId: this.userId,
        mobile: this.mobile,
        address: this.address,
        city: this.city,
        latitude: this.latitude,
        longitude: this.longitude,
        area: this.area,
        type: this.type,
        name: this.name,
        countryCode: this.countryCode,
        alternateCountryCode: this.alternateCountryCode,
        alternateMobile: this.alternateMobile,
        landmark: this.landmark,
        pincode: this.pincode,
        state: this.state,
        country: this.country,
        isDefault: isDefault ?? this.isDefault,
        );
  }
}
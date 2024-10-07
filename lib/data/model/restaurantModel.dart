import 'package:project1/data/model/permissionModel.dart';
import 'package:project1/data/model/restaurantWorkingTimeModel.dart';

class RestaurantModel {
  String? partnerId;
  String? isFavorite;
  String? isRestroOpen;
  String? partnerCookTime;
  String? distance;
  String? ownerName;
  String? priceForOne;
  String? email;
  List<String>? tags;
  String? mobile;
  String? partnerAddress;
  String? cityId;
  String? cityName;
  String? fcmId;
  String? latitude;
  String? longitude;
  String? balance;
  String? slug;
  String? partnerName;
  String? description;
  String? partnerIndicator;
  List<String>? gallery;
  String? partnerRating;
  Permissions? permissions;
  String? noOfRatings;
  String? accountNumber;
  String? accountName;
  String? bankCode;
  String? bankName;
  String? panNumber;
  String? cookingTime;
  String? status;
  String? commission;
  String? partnerProfile;
  String? nationalIdentityCard;
  String? addressProof;
  String? taxNumber;
  String? taxName;
  String? licenceName;
  String? licenceCode;
  List<String>? licenceProof;
  String? licenceStatus;
  String? dateAdded;
  List<RestaurantWorkingTimeModel>? partnerWorkingTime;

  RestaurantModel copyWith({String? isFavourite}) {
    return RestaurantModel(
      partnerId: partnerId,
      isFavorite: isFavourite ?? isFavorite,
      isRestroOpen: isRestroOpen,
      partnerCookTime: partnerCookTime,
      distance: distance,
      ownerName: ownerName,
      priceForOne: priceForOne,
      email: email,
      tags: tags,
      mobile: mobile,
      partnerAddress: partnerAddress,
      cityId: cityId,
      cityName: cityName,
      fcmId: fcmId,
      latitude: latitude,
      longitude: longitude,
      balance: balance,
      slug: slug,
      partnerName: partnerName,
      description: description,
      partnerIndicator: partnerIndicator,
      gallery: gallery,
      partnerRating: partnerRating,
      permissions: permissions,
      noOfRatings: noOfRatings,
      accountNumber: accountNumber,
      accountName: accountName,
      bankCode: bankCode,
      bankName: bankName,
      panNumber: panNumber,
      cookingTime: cookingTime,
      status: status,
      commission: commission,
      partnerProfile: partnerProfile,
      nationalIdentityCard: nationalIdentityCard,
      addressProof: addressProof,
      taxNumber: taxNumber,
      taxName: taxName,
      licenceName: licenceName,
      licenceCode: licenceCode,
      licenceProof: licenceProof,
      licenceStatus: licenceStatus,
      dateAdded: dateAdded,
      partnerWorkingTime: partnerWorkingTime,
    );
  }

  RestaurantModel(
      {this.partnerId,
      this.isFavorite,
      this.isRestroOpen,
      this.partnerCookTime,
      this.distance,
      this.ownerName,
      this.priceForOne,
      this.email,
      this.tags,
      this.mobile,
      this.partnerAddress,
      this.cityId,
      this.cityName,
      this.fcmId,
      this.latitude,
      this.longitude,
      this.balance,
      this.slug,
      this.partnerName,
      this.description,
      this.partnerIndicator,
      this.gallery,
      this.partnerRating,
      this.permissions,
      this.noOfRatings,
      this.accountNumber,
      this.accountName,
      this.bankCode,
      this.bankName,
      this.panNumber,
      this.cookingTime,
      this.status,
      this.commission,
      this.partnerProfile,
      this.nationalIdentityCard,
      this.addressProof,
      this.taxNumber,
      this.taxName,
      this.licenceName,
      this.licenceCode,
      this.licenceProof,
      this.licenceStatus,
      this.dateAdded,
      this.partnerWorkingTime});

  RestaurantModel.fromJson(Map<String, dynamic> json) {
    partnerId = json['partner_id'] ?? "";
    isFavorite = json['is_favorite'] ?? "";
    isRestroOpen = json['is_restro_open'] ?? "";
    partnerCookTime = json['partner_cook_time'] ?? "";
    distance = json['distance'] ?? "";
    ownerName = json['owner_name'] ?? "";
    email = json['email'] ?? "";
    priceForOne = json['price_for_one'] ?? "";
    tags = json['tags'] == null ? List<String>.from([]) : (json['tags'] as List).map((e) => e.toString()).toList();
    mobile = json['mobile'] ?? "";
    partnerAddress = json['partner_address'] ?? "";
    cityId = json['city_id'] ?? "";
    cityName = json['city_name'] ?? "";
    fcmId = json['fcm_id'] ?? "";
    latitude = json['latitude'] ?? "";
    longitude = json['longitude'] ?? "";
    balance = json['balance'] ?? "";
    slug = json['slug'] ?? "";
    partnerName = json['partner_name'] ?? "";
    description = json['description'] ?? "";
    partnerIndicator = json['partner_indicator'] ?? "";
    gallery = json['gallery'] == null ? List<String>.from([]) : (json['gallery'] as List).map((e) => e.toString()).toList();
    partnerRating = json['partner_rating'] ?? "0.0";
    permissions = json['permissions'] != null ? Permissions.fromJson(json['permissions']) : null;
    noOfRatings = json['no_of_ratings'] ?? "";
    accountNumber = json['account_number'] ?? "";
    accountName = json['account_name'] ?? "";
    bankCode = json['bank_code'] ?? "";
    bankName = json['bank_name'] ?? "";
    panNumber = json['pan_number'] ?? "";
    cookingTime = json['cooking_time'] ?? "";
    status = json['status'] ?? "";
    commission = json['commission'] ?? "";
    partnerProfile = json['partner_profile'] ?? "";
    nationalIdentityCard = json['national_identity_card'] ?? "";
    addressProof = json['address_proof'] ?? "";
    taxNumber = json['tax_number'] ?? "";
    taxName = json['tax_name'] ?? "";
    licenceName = json['licence_name'] ?? "";
    licenceCode = json['licence_code'] ?? "";
    licenceProof = json['licence_proof'] == null ? List<String>.from([]) : (json['licence_proof'] as List).map((e) => e.toString()).toList();
    licenceStatus = json['licence_status'] ?? "";
    dateAdded = json['date_added'] ?? "";
    if (json['partner_working_time'] != null) {
      partnerWorkingTime = <RestaurantWorkingTimeModel>[];
      json['partner_working_time'].forEach((v) {
        partnerWorkingTime!.add(RestaurantWorkingTimeModel.fromJson(v));
      });
    }
  }

}

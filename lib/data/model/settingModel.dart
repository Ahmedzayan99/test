class SettingModel {
  bool? error;
  int? allowModification;
  int? authenticationMode;
  String? message;
  Data? data;

  SettingModel({this.error, this.allowModification, this.message, this.data, this.authenticationMode});

  SettingModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    allowModification = json['allow_modification'];
    authenticationMode = json['authentication_mode'] ?? 0;
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

}
class Data {
  List<String>? logo;
  List<String>? privacyPolicy;
  List<String>? termsConditions;
  List<String>? fcmServerKey;
  List<String>? contactUs;
  List<String>? aboutUs;
  List<String>? currency;
  List<UserData>? userData;
  List<SystemSettings>? systemSettings;
  List<String>? tags;

  Data(
      {this.logo,
        this.privacyPolicy,
        this.termsConditions,
        this.fcmServerKey,
        this.contactUs,
        this.aboutUs,
        this.currency,
        this.userData,
        this.systemSettings,
        this.tags});

  Data.fromJson(Map<String, dynamic> json) {
    logo = json['logo'] == null ? List<String>.from([]) : (json['logo'] as List).map((e) => e.toString()).toList() ;
    privacyPolicy = json['privacy_policy'] == null ? List<String>.from([]) : (json['privacy_policy'] as List).map((e) => e.toString()).toList() ;
    termsConditions = json['terms_conditions'] == null ? List<String>.from([]) : (json['terms_conditions'] as List).map((e) => e.toString()).toList() ;
    fcmServerKey = json['fcm_server_key'] == null ? List<String>.from([]) : (json['fcm_server_key'] as List).map((e) => e.toString()).toList() ;
    contactUs = json['contact_us'] == null ? List<String>.from([]) : (json['contact_us'] as List).map((e) => e.toString()).toList() ;
    aboutUs = json['about_us'] == null ? List<String>.from([]) : (json['about_us'] as List).map((e) => e.toString()).toList() ;
    currency = json['currency'] == null ? List<String>.from([]) : (json['currency'] as List).map((e) => e.toString()).toList() ;

    if (json['user_data'] != null) {
      userData = <UserData>[];
      json['user_data'].forEach((v) {
        if (v.toString().isNotEmpty){
          userData!.add(UserData.fromJson(v));
      }
      });
    }
    if (json['system_settings'] != null) {
      systemSettings = <SystemSettings>[];
      json['system_settings'].forEach((v) {
        systemSettings!.add(SystemSettings.fromJson(v));
      });
    }
    tags = json['tags'] == null ? List<String>.from([]) : (json['tags'] as List).map((e) => e.toString()).toList();
  }

}

class UserData {
  String? id;
  String? username;
  String? email;
  String? mobile;
  String? balance;
  String? dob;
  String? referralCode;
  String? friendsCode;
  String? cityName;
  String? area;
  String? landmark;
  String? pincode;
  String? cartTotalItems;
  String? isFirstOrder;

  UserData(
      {this.id,
        this.username,
        this.email,
        this.mobile,
        this.balance,
        this.dob,
        this.referralCode,
        this.friendsCode,
        this.cityName,
        this.area,
        this.landmark,
        this.pincode,
        this.cartTotalItems,
        this.isFirstOrder});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    mobile = json['mobile'];
    balance = json['balance'];
    dob = json['dob'];
    referralCode = json['referral_code'];
    friendsCode = json['friends_code'];
    cityName = json['city_name'];
    area = json['area'];
    landmark = json['landmark'];
    pincode = json['pincode'];
    cartTotalItems = json['cart_total_items'];
    isFirstOrder = json['is_first_order'] ?? "0";
  }

}

class SystemSettings {
  String? systemConfigurations;
  String? systemTimezoneGmt;
  String? systemConfigurationsId;
  String? appName;
  String? supportNumber;
  String? supportEmail;
  String? currentVersion;
  String? currentVersionIos;
  String? isVersionSystemOn;
  String? currency;
  String? systemTimezone;
  String? isReferEarnOn;
  String? isEmailSettingOn;
  String? minReferEarnOrderAmount;
  String? referEarnBonus;
  String? referEarnMethod;
  String? maxReferEarnAmount;
  String? referEarnBonusTimes;
  String? minimumCartAmt;
  String? lowStockLimit;
  String? maxItemsCart;
  String? isRiderOtpSettingOn;
  String? cartBtnOnList;
  String? expandProductImages;
  String? isAppMaintenanceModeOn;
  String? customerAppAndroidLink;
  String? partnerAppAndroidLink;
  String? riderAppAndroidLink;
  String? customerAppIosLink;
  String? partnerAppIosLink;
  String? riderAppIosLink;

  SystemSettings(
      {this.systemConfigurations,
        this.systemTimezoneGmt,
        this.systemConfigurationsId,
        this.appName,
        this.supportNumber,
        this.supportEmail,
        this.currentVersion,
        this.currentVersionIos,
        this.isVersionSystemOn,
        this.currency,
        this.systemTimezone,
        this.isReferEarnOn,
        this.isEmailSettingOn,
        this.minReferEarnOrderAmount,
        this.referEarnBonus,
        this.referEarnMethod,
        this.maxReferEarnAmount,
        this.referEarnBonusTimes,
        this.minimumCartAmt,
        this.lowStockLimit,
        this.maxItemsCart,
        this.isRiderOtpSettingOn,
        this.cartBtnOnList,
        this.expandProductImages,
        this.isAppMaintenanceModeOn,
        this.customerAppAndroidLink,
        this.partnerAppAndroidLink,
        this.riderAppAndroidLink,
        this.customerAppIosLink,
        this.partnerAppIosLink,
        this.riderAppIosLink,
  });

  SystemSettings.fromJson(Map<String, dynamic> json) {
    systemConfigurations = json['system_configurations'];
    systemTimezoneGmt = json['system_timezone_gmt'];
    systemConfigurationsId = json['system_configurations_id'];
    appName = json['app_name'];
    supportNumber = json['support_number'];
    supportEmail = json['support_email'];
    currentVersion = json['current_version'];
    currentVersionIos = json['current_version_ios'];
    isVersionSystemOn = json['is_version_system_on'];
    currency = json['currency'];
    systemTimezone = json['system_timezone'];
    isReferEarnOn = json['is_refer_earn_on'];
    isEmailSettingOn = json['is_email_setting_on'];
    minReferEarnOrderAmount = json['min_refer_earn_order_amount'];
    referEarnBonus = json['refer_earn_bonus'];
    referEarnMethod = json['refer_earn_method'];
    maxReferEarnAmount = json['max_refer_earn_amount'];
    referEarnBonusTimes = json['refer_earn_bonus_times'];
    minimumCartAmt = json['minimum_cart_amt'];
    lowStockLimit = json['low_stock_limit'];
    maxItemsCart = json['max_items_cart'];
    isRiderOtpSettingOn = json['is_rider_otp_setting_on'];
    cartBtnOnList = json['cart_btn_on_list'];
    expandProductImages = json['expand_product_images'];
    isAppMaintenanceModeOn = json['is_app_maintenance_mode_on'];
    customerAppAndroidLink = json['customer_app_android_link'];
    partnerAppAndroidLink = json['partner_app_android_link'];
    riderAppAndroidLink = json['rider_app_android_link'];
    customerAppIosLink = json['customer_app_ios_link'];
    partnerAppIosLink = json['partner_app_ios_link'];
    riderAppIosLink = json['rider_app_ios_link'];
  }

}
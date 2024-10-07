import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/data/localDataStore/authLocalDataSource.dart';
import 'package:project1/data/repositories/auth/authRemoteDataSource.dart';
import 'package:project1/utils/api.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/authModel.dart';

class AuthRepository {
  static final AuthRepository _authRepository = AuthRepository._internal();
  late AuthLocalDataSource _authLocalDataSource;
  late AuthRemoteDataSource _authRemoteDataSource;

  factory AuthRepository() {
    _authRepository._authLocalDataSource = AuthLocalDataSource();
    _authRepository._authRemoteDataSource = AuthRemoteDataSource();
    return _authRepository;
  }
  AuthRepository._internal();
  AuthLocalDataSource get authLocalDataSource => _authLocalDataSource;
  //to get auth detials stored in hive box
  getLocalAuthDetails() {
    return {
      "isLogin": _authLocalDataSource.checkIsAuth(),
      "id": _authLocalDataSource.getId(),
      "ip_address": _authLocalDataSource.getIpAddress(),
      "username": _authLocalDataSource.getName(),
      "email": _authLocalDataSource.getEmail(),
      "mobile": _authLocalDataSource.getMobile(),
      "type": _authLocalDataSource.getType(),
      "image": _authLocalDataSource.getImage(),
      "balance": _authLocalDataSource.getBalance(),
      "rating": _authLocalDataSource.getRating(),
      "no_of_ratings": _authLocalDataSource.getNoOfRatings(),
      "activation_selector": _authLocalDataSource.getActivationSelector(),
      "activation_code": _authLocalDataSource.getActivationCode(),
      "forgotten_password_selector": _authLocalDataSource.getForgottenPasswordSelector(),
      "forgotten_password_code": _authLocalDataSource.getForgottenPasswordCode(),
      "forgotten_password_time": _authLocalDataSource.getForgottenPasswordTime(),
      "remember_selector": _authLocalDataSource.getRememberSelector(),
      "remember_code": _authLocalDataSource.getRememberCode(),
      "created_on": _authLocalDataSource.getCreatedOn(),
      "last_login": _authLocalDataSource.getLastLogin(),
      "active": _authLocalDataSource.getActive(),
      "company": _authLocalDataSource.getCompany(),
      "address": _authLocalDataSource.getAddress(),
      "bonus": _authLocalDataSource.getBonus(),
      "dob": _authLocalDataSource.getDob(),
      "country_code": _authLocalDataSource.getCountryCode(),
      "city": _authLocalDataSource.getCity(),
      "area": _authLocalDataSource.getArea(),
      "street": _authLocalDataSource.getStreet(),
      "pincode": _authLocalDataSource.getPinCode(),
      "serviceable_city": _authLocalDataSource.getServiceableCity(),
      "apikey": _authLocalDataSource.getApikey(),
      "referral_code": _authLocalDataSource.getReferralCode(),
      "friends_code": _authLocalDataSource.getFriendsCode(),
      "fcm_id": _authLocalDataSource.getFcmId(),
      "latitude": _authLocalDataSource.getLatitude(),
      "longitude": _authLocalDataSource.getLongitude(),
      "created_at": _authLocalDataSource.getCreatedAt()
    };
  }

  setLocalAuthDetails({
    bool? authStatus,
    String? id,
    String? ipAddress,
    String? name,
    String? email,
    String? mobile,
    String? type,
    String? image,
    String? balance,
    String? rating,
    String? noOfRatings,
    String? activationSelector,
    String? activationCode,
    String? forgottenPasswordSelector,
    String? forgottenPasswordCode,
    String? forgottenPasswordTime,
    String? rememberSelector,
    String? rememberCode,
    String? createdOn,
    String? lastLogin,
    String? active,
    String? company,
    String? address,
    String? bonus,
    String? dob,
    String? countryCode,
    String? city,
    String? area,
    String? street,
    String? pincode,
    String? serviceableCity,
    String? referralCode,
    String? friendsCode,
    String? fcmId,
    String? latitude,
    String? longitude,
    String? createdAt,
  }) {
    _authLocalDataSource.changeAuthStatus(authStatus);
    _authLocalDataSource.setId(id);
    _authLocalDataSource.setIpAddress(ipAddress);
    _authLocalDataSource.setName(name);
    _authLocalDataSource.setEmail(email);
    _authLocalDataSource.setMobile(mobile);
    _authLocalDataSource.setType(type);
    _authLocalDataSource.setImage(image);
    _authLocalDataSource.setBalance(balance);
    _authLocalDataSource.setRating(rating);
    _authLocalDataSource.setNoOfRatings(noOfRatings);
    _authLocalDataSource.setActivationSelector(activationSelector);
    _authLocalDataSource.setActivationCode(activationCode);
    _authLocalDataSource.setForgottenPasswordSelector(forgottenPasswordSelector);
    _authLocalDataSource.setForgottenPasswordCode(forgottenPasswordCode);
    _authLocalDataSource.setForgottenPasswordTime(forgottenPasswordTime);
    _authLocalDataSource.setRememberSelector(rememberSelector);
    _authLocalDataSource.setRememberCode(rememberCode);
    _authLocalDataSource.setCreatedOn(createdOn);
    _authLocalDataSource.setLastLogin(lastLogin);
    _authLocalDataSource.setActive(active);
    _authLocalDataSource.setCompany(company);
    _authLocalDataSource.setAddress(address);
    _authLocalDataSource.setBonus(bonus);
    _authLocalDataSource.setDob(dob);
    _authLocalDataSource.setCountryCode(countryCode);
    _authLocalDataSource.setCity(city);
    _authLocalDataSource.setArea(area);
    _authLocalDataSource.setStreet(street);
    _authLocalDataSource.setPinCode(pincode);
    _authLocalDataSource.setServiceableCity(serviceableCity);
    _authLocalDataSource.setReferralCode(referralCode);
    _authLocalDataSource.setFriendsCode(friendsCode);
    _authLocalDataSource.setFcmId(fcmId);
    _authLocalDataSource.setLatitude(latitude);
    _authLocalDataSource.setLongitude(longitude);
    _authLocalDataSource.setCreatedAt(createdAt);
  }

  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<Map<String, dynamic>> addUserData({
    String? name,
    String? email,
    String? mobile,
    String? countryCode,
    //String? password,
    String? fcmId,
    String? friendCode,
    String? referCode,
    /*, String? latitude, String? longitude*/
  }) async {
    final result = await _authRemoteDataSource.addUser(
        name: name,
        email: email,
        mobile: mobile,
        countryCode: countryCode ?? "",
        //password: password,
        fcmId: fcmId ?? "",
        friendCode: friendCode ?? "",
        referCode: referCode /*, latitude: latitude ?? "", longitude: longitude ?? ""*/);
    await _authLocalDataSource.setId(result['id']);
    await _authLocalDataSource.changeAuthStatus(true);
    await _authLocalDataSource.setName(result['username']);
    await _authLocalDataSource.setEmail(result['email']);
    await _authLocalDataSource.setMobile(result['mobile']);
    await _authLocalDataSource.setType(result['type']);
    await _authLocalDataSource.setImage(result['image']);
    await _authLocalDataSource.setActive(result['active']);
    await _authLocalDataSource.setCompany(result['company']);
    await _authLocalDataSource.setAddress(result['address']);
    await _authLocalDataSource.setCountryCode(result['country_code']);
    await _authLocalDataSource.setCity(result['city']);
    await _authLocalDataSource.setArea(result['area']);
    await _authLocalDataSource.setStreet(result['street']);
    await _authLocalDataSource.setPinCode(result['pincode']);
    await _authLocalDataSource.setServiceableCity(result['serviceable_city']);
    await _authLocalDataSource.setReferralCode(result['referral_code']);
    await _authLocalDataSource.setFriendsCode(result['friends_code']);
    await _authLocalDataSource.setFcmId(result['fcm_id']);
    await _authLocalDataSource.setLatitude(result['latitude']);
    await _authLocalDataSource.setLongitude(result['longitude']);
    return Map.from(result); //
  }

  //to login user's data to database. This will be in use when authenticating using phoneNumber
  Future<Map<String, dynamic>> login({String? mobile /*, String? password*/}) async {
    setLocalAuthDetails();
    final result = await _authRemoteDataSource.signInUser(mobile: mobile /*, password: password*/);
    await _authLocalDataSource.setId(result['id']);
    await _authLocalDataSource.changeAuthStatus(true);
    await _authLocalDataSource.setName(result['username']);
    await _authLocalDataSource.setEmail(result['email']);
    await _authLocalDataSource.setMobile(result['mobile']);
    await _authLocalDataSource.setType(result['type']);
    await _authLocalDataSource.setImage(result['image']);
    await _authLocalDataSource.setActive(result['active']);
    await _authLocalDataSource.setCompany(result['company']);
    await _authLocalDataSource.setAddress(result['address']);
    await _authLocalDataSource.setCountryCode(result['country_code']);
    await _authLocalDataSource.setCity(result['city']);
    await _authLocalDataSource.setArea(result['area']);
    await _authLocalDataSource.setStreet(result['street']);
    await _authLocalDataSource.setPinCode(result['pincode']);
    await _authLocalDataSource.setServiceableCity(result['serviceable_city']);
    await _authLocalDataSource.setReferralCode(result['referral_code']);
    await _authLocalDataSource.setFriendsCode(result['friends_code']);
    await _authLocalDataSource.setFcmId(result['fcm_id']);
    await _authLocalDataSource.setLatitude(result['latitude']);
    await _authLocalDataSource.setLongitude(result['longitude']);

    /* setLocalAuthDetails(
      authStatus: true,
      id: result['id'],ipAddress: result['ip_address'],name: result['username'],email: result['email'],mobile: result['mobile'],type: result['type'],image: result['image'],
      balance: result['balance'],
      rating: result['rating'],
      noOfRatings: result['no_of_ratings'],
      activationSelector: result['activation_selector'],
      activationCode: result['activation_code'],
      forgottenPasswordSelector: result['forgotten_password_selector'],
      forgottenPasswordCode: result['forgotten_password_code'],
      forgottenPasswordTime: result['forgotten_password_time'],
      rememberSelector: result['remember_selector'],
      rememberCode: result['remember_code'],
      createdOn: result['created_on'],
      lastLogin: result['last_login'],
      active: result['active'],
      company: result['company'],
      address: result['address'],
      bonus: result['bonus'],
      dob: result['dob'],
      countryCode: result['country_code'],
      city: result['city'],
      area: result['area'],
      street: result['street'],
      pincode: result['pincode'],
      serviceableCity: result['serviceable_city'],
      referralCode: result['referral_code'],
      friendsCode: result['friends_code'],
      fcmId: result['fcm_id'],
      latitude: result['latitude'],
      longitude: result['longitude'],
      createdAt: result['created_at'],
  ); */
    return Map.from(result); //
  }

  //to update fcmId user's data to database. This will be in use when authenticating using fcmId
  Future<Map<String, dynamic>> updateFcmId({String? userId, String? fcmId}) async {
    final result = await _authRemoteDataSource.updateFcmId(userId: userId, fcmId: fcmId);
    await _authLocalDataSource.changeAuthStatus(false);
    return Map.from(result); //
  }

  //to verify user's data to database. This will be in use when authenticating using phoneNumber
  Future<bool> verify({String? mobile}) async {
    final result = await _authRemoteDataSource.isUserExist(mobile!);
    return result; //
  }

  //to verify otp user's
  Future<bool> verifyOtp({String? mobile, String? otp}) async {
    final result = await _authRemoteDataSource.isVerifyOtp(mobile!, otp!);
    return result; //
  }

  //to resend otp user's
  Future<bool> resentOtp({String? mobile}) async {
    final result = await _authRemoteDataSource.isResendOtp(mobile!);
    return result; //
  }

  //to delete my account
  Future<bool> deleteMyAccount({String? userId}) async {
    try {
      final result = await _authRemoteDataSource.deleteMyAccount(userId!);
      print(result);
      return result; //
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      print(e);
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //refer and earn
  Future<String> geReferAndEarn(String? referCode) async {
    try {
      final result = await _authRemoteDataSource.referEarn(referCode);
      return Map.from(result).toString();
    } catch (e) {
      print("error$e");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  /*Future getAuthorData() async {
    try {
      final result = await _authRemoteDataSource.addUser();
      return result;
    } catch (e) {
      throw AuthException(errorMessage: e.toString());
    }
  }*//*

  Future<AuthModel> getUserDetailsById() async {
    try {
      final result = await _authRemoteDataSource.addUser();

      return AuthModel.fromJson(result);
    } catch (e) {
      throw AuthException(errorMessage: e.toString());
    }
  }
*/
  Future<void> signOut(AuthProviders authProvider) async {
    _authRemoteDataSource.signOut(authProvider);
    await _authLocalDataSource.changeAuthStatus(false);
    await _authLocalDataSource.setId("");
    await _authLocalDataSource.setName("");
    await _authLocalDataSource.setEmail("");
    await _authLocalDataSource.setMobile("");
    await _authLocalDataSource.setType("");
    await _authLocalDataSource.setImage("");
    await _authLocalDataSource.setActive("");
    await _authLocalDataSource.setCompany("");
    await _authLocalDataSource.setAddress("");
    await _authLocalDataSource.setCountryCode("");
    await _authLocalDataSource.setCity("");
    await _authLocalDataSource.setArea("");
    await _authLocalDataSource.setStreet("");
    await _authLocalDataSource.setPinCode("");
    await _authLocalDataSource.setServiceableCity("");
    await _authLocalDataSource.setReferralCode("");
    await _authLocalDataSource.setFriendsCode("");
    await _authLocalDataSource.setFcmId("");
    await _authLocalDataSource.setLatitude("");
    await _authLocalDataSource.setLongitude("");
    await AuthLocalDataSource.setJwtTocken("");
  }

  //First we signin user with given provider then add user details
  // Future<Map<String, dynamic>> signInUser(AuthProviders authProvider, String? referCode, String? friendCode) async {
  //   try {
  //     final result = await _authRemoteDataSource.socialSignInUser(
  //       authProvider,
  //     );
  //     final user = result['user'] as User;
  //     //bool isNewUser = result['isNewUser'] as bool;
  //
  //     //isNewUser = true;
  //     var registeredUser = await _authRemoteDataSource.socialLogIn(
  //       email: user.email ?? "",
  //       mobile: user.phoneNumber ?? "",
  //       name: user.displayName ?? "",
  //       type: getAuthTypeString(authProvider),
  //       referCode: referCode,
  //       friendCode: friendCode,
  //       countryCode: "",
  //     );
  //     if (registeredUser['error'] == true) {
  //       registeredUser = _authRemoteDataSource.socialLogIn(email: user.email);
  //       await _authLocalDataSource.setId(registeredUser['data']['id']);
  //       await _authLocalDataSource.changeAuthStatus(true);
  //       await _authLocalDataSource.setName(registeredUser['data']['username']);
  //       await _authLocalDataSource.setEmail(registeredUser['data']['email']);
  //       await _authLocalDataSource.setMobile(registeredUser['data']['mobile']);
  //       await _authLocalDataSource.setType(registeredUser['data']['type']);
  //       await _authLocalDataSource.setImage(registeredUser['data']['image']);
  //       await _authLocalDataSource.setActive(registeredUser['data']['active']);
  //       await _authLocalDataSource.setCompany(registeredUser['data']['company']);
  //       await _authLocalDataSource.setAddress(registeredUser['address']);
  //       await _authLocalDataSource.setCountryCode(registeredUser['country_code']);
  //       await _authLocalDataSource.setCity(registeredUser['data']['city']);
  //       await _authLocalDataSource.setArea(registeredUser['data']['area']);
  //       await _authLocalDataSource.setStreet(registeredUser['data']['street']);
  //       await _authLocalDataSource.setPinCode(registeredUser['data']['pincode']);
  //       await _authLocalDataSource.setServiceableCity(registeredUser['data']['serviceable_city']);
  //       await _authLocalDataSource.setReferralCode(registeredUser['data']['referral_code']);
  //       await _authLocalDataSource.setFriendsCode(registeredUser['data']['friends_code']);
  //       await _authLocalDataSource.setFcmId(registeredUser['data']['fcm_id']);
  //       await _authLocalDataSource.setLatitude(registeredUser['data']['latitude']);
  //       await _authLocalDataSource.setLongitude(registeredUser['data']['longitude']);
  //       await AuthLocalDataSource.setJwtTocken(registeredUser['token'].toString());
  //     } else {
  //       await _authLocalDataSource.setId(registeredUser['data']['id']);
  //       await _authLocalDataSource.changeAuthStatus(true);
  //       await _authLocalDataSource.setName(registeredUser['data']['username']);
  //       await _authLocalDataSource.setEmail(registeredUser['data']['email']);
  //       await _authLocalDataSource.setMobile(registeredUser['data']['mobile']);
  //       await _authLocalDataSource.setType(registeredUser['data']['type']);
  //       await _authLocalDataSource.setImage(registeredUser['data']['image']);
  //       await _authLocalDataSource.setActive(registeredUser['data']['active']);
  //       await _authLocalDataSource.setCompany(registeredUser['data']['company']);
  //       await _authLocalDataSource.setAddress(registeredUser['address']);
  //       await _authLocalDataSource.setCountryCode(registeredUser['country_code']);
  //       await _authLocalDataSource.setCity(registeredUser['data']['city']);
  //       await _authLocalDataSource.setArea(registeredUser['data']['area']);
  //       await _authLocalDataSource.setStreet(registeredUser['data']['street']);
  //       await _authLocalDataSource.setPinCode(registeredUser['data']['pincode']);
  //       await _authLocalDataSource.setServiceableCity(registeredUser['data']['serviceable_city']);
  //       await _authLocalDataSource.setReferralCode(registeredUser['data']['referral_code']);
  //       await _authLocalDataSource.setFriendsCode(registeredUser['data']['friends_code']);
  //       await _authLocalDataSource.setFcmId(registeredUser['data']['fcm_id']);
  //       await _authLocalDataSource.setLatitude(registeredUser['data']['latitude']);
  //       await _authLocalDataSource.setLongitude(registeredUser['data']['longitude']);
  //       await AuthLocalDataSource.setJwtTocken(registeredUser['token'].toString());
  //     }
  //     print("JWT TOKEN is : ${registeredUser['token']}");
  //
  //     //store jwt token
  //     /* await AuthLocalDataSource.setJwtTocken(
  //             registeredUser['token'].toString()); */
  //
  //     return registeredUser;
  //   } catch (e) {
  //     print(e.toString());
  //     signOut(authProvider);
  //     throw ApiMessageException(errorMessage: e.toString());
  //   }
  // }

  String getAuthTypeString(AuthProviders provider) {
    String authType;
    if (provider == AuthProviders.facebook) {
      authType = "facebook";
    } else if (provider == AuthProviders.google) {
      authType = "google";
    } else {
      authType = "apple";
    }
    return authType;
  }
}

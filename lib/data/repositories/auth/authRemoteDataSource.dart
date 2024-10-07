import 'dart:io';
import 'dart:math';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/data/localDataStore/authLocalDataSource.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/string.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  //final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //String? referCode;
  int count = 1;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _facebookSignin = FacebookLogin();

//to addUser
  Future<dynamic> addUser(
      {String? name,
      String? email,
      String? mobile,
      String? countryCode,
      //String? password,
      String? fcmId,
      String? friendCode,
      String? referCode /*, String? latitude, String? longitude*/}) async {
    try {
      //referEarn();
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        nameKey: name,
        emailKey: email,
        mobileKey: mobile,
        countryCodeKey: countryCode ?? "",
        referralCodeKey: referCode ?? "",
        //passwordKey: password,
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? "" /*, latitudeKey: latitude ?? "", longitudeKey: longitude ?? ""*/
      };
      final result = await Api.post(body: body, url: Api.registerUserUrl, token: false, errorCode: false);
      AuthLocalDataSource.setJwtTocken(result['token']);
      return result['data'];
    } catch (e) {
      print("error:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to addUser
  Future<dynamic> socialLogIn(
      {String? name, String? email, String? mobile, String? countryCode, String? fcmId, String? friendCode, String? referCode, String? type}) async {
    try {
      //referEarn();
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        nameKey: name,
        emailKey: email,
        mobileKey: mobile,
        countryCodeKey: countryCode ?? "",
        referralCodeKey: referCode ?? "",
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? "",
        typeKey: type ?? "",
      };
      final result = await Api.post(body: body, url: Api.signUpUrl, token: false, errorCode: false);
      AuthLocalDataSource.setJwtTocken(result['token']);
      return result;
    } catch (e) {
      print("error:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  final chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  //to referEarn
  Future referEarn(String? referCode) async {
    try {
      //body of post request
      final body = {referralCodeKey: referCode};
      final result = await Api.post(body: body, url: Api.validateReferCodeUrl, token: false, errorCode: false);
      if (!result['error']) {
        referCode = referCode;
      } else {
        if (count < 5) referEarn(referCode);
        count++;
      }

      return result;
    } catch (e) {
      print("e:${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to loginUser
  Future<dynamic> signInUser({String? mobile /*, String? password*/}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {mobileKey: mobile, /* passwordKey: password,*/ fcmIdKey: fcmToken};
      final result = await Api.post(body: body, url: Api.loginUrl, token: false, errorCode: false);
      AuthLocalDataSource.setJwtTocken(result['token']);

      return result['data'];
    } catch (e) {
      //print(e.toString());
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isUserExist(String mobile) async {
    try {
      final body = {
        mobileKey: mobile,
        isForgotPasswordKey: "0"
      };
      final result = await Api.post(body: body, url: Api.verifyUserUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    }  on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }  catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to verify otp user's exist
  Future<bool> isVerifyOtp(String mobile, String otp) async {
    try {
      final body = {
        mobileKey: mobile,
        otpKey: otp
      };
      final result = await Api.post(body: body, url: Api.verifyOtpUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    }  on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }  catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isResendOtp(String mobile) async {
    try {
      final body = {mobileKey: mobile};
      final result = await Api.post(body: body, url: Api.resendOtpUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to delete my account
  Future<bool> deleteMyAccount(String userId) async {
    try {
      final body = {
        userIdKey: userId,
      };
      final result = await Api.post(body: body, url: Api.deleteMyAccountUrl, token: true, errorCode: true);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageAndCodeException(errorMessage: result['message'], errorStatusCode: result["status_code"].toString());
      }
      return true;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to update fcmId of user's
  Future<dynamic> updateFcmId({String? userId, String? fcmId}) async {
    try {
      //body of post request
      final body = {userIdKey: userId, fcmIdKey: fcmId};
      final result = await Api.post(body: body, url: Api.updateFcmUrl, token: true, errorCode: false);
      return result['data'];
    } catch (e) {
      //print(e.toString());
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  // //SignIn user will accept AuthProvider (enum)
  // Future<Map<String, dynamic>> socialSignInUser(
  //     AuthProviders authProvider /* , {
  //   String? email,
  //   String? password,
  //   String? verificationId,
  //   String? smsCode,
  // } */
  //     ) async {
  //   //user creadential contains information of signin user and is user new or not
  //   Map<String, dynamic> result = {};
  //
  //   try {
  //     if (authProvider == AuthProviders.google) {
  //       UserCredential userCredential = await signInWithGoogle();
  //
  //       result['user'] = userCredential.user!;
  //       result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
  //     } else if (authProvider == AuthProviders.phone) {
  //       /* UserCredential userCredential = await signInWithPhoneNumber(
  //           verificationId: verificationId!, smsCode: smsCode!);
  //
  //       result['user'] = userCredential.user!;
  //       result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser; */
  //     } else if (authProvider == AuthProviders.facebook) {
  //       final faceBookAuthResult = await signInWithFacebook();
  //       if (faceBookAuthResult != null) {
  //         result['user'] = faceBookAuthResult.user!;
  //         result['isNewUser'] = faceBookAuthResult.additionalUserInfo!.isNewUser;
  //       } else {
  //         throw ApiMessageException(errorMessage: defaultErrorMessage);
  //       }
  //       print("facebook");
  //     } else if (authProvider == AuthProviders.apple) {
  //       UserCredential userCredential = await signInWithApple();
  //       result['user'] = _firebaseAuth.currentUser!;
  //       result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
  //     }
  //     return result;
  //   } on SocketException catch (_) {
  //     throw ApiMessageException(errorMessage: StringsRes.noInternet);
  //   }
  //   //firebase auht errors
  //   on FirebaseAuthException catch (e) {
  //     throw ApiMessageException(errorMessage: e.toString());
  //   } on ApiMessageException catch (e) {
  //     throw ApiMessageException(errorMessage: e.toString());
  //   } catch (e) {
  //     throw ApiMessageException(errorMessage: e.toString());
  //   }
  // }

  //signIn using google account
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw ApiMessageException(errorMessage: defaultErrorMessage);
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  Future<UserCredential?> signInWithFacebook() async {
    final res = await _facebookSignin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:

        // Send access token to server for validation and auth
        final FacebookAccessToken? accessToken = res.accessToken;
        AuthCredential authCredential = FacebookAuthProvider.credential(accessToken!.token);
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(authCredential);
        return userCredential;
      case FacebookLoginStatus.cancel:
        return null;

      case FacebookLoginStatus.error:
        return null;
      default:
        return null;
    }
  }

  // Future<UserCredential> signInWithApple() async {
  //   try {
  //     final AuthorizationResult appleResult = await AppleSignIn.performRequests([
  //       const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
  //     ]);
  //
  //     if (appleResult.status == AuthorizationStatus.authorized) {
  //       final appleIdCredential = appleResult.credential!;
  //       final oAuthProvider = OAuthProvider('apple.com');
  //       final credential = oAuthProvider.credential(
  //         idToken: String.fromCharCodes(appleIdCredential.identityToken!),
  //         accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
  //       );
  //       final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
  //       if (userCredential.additionalUserInfo!.isNewUser) {
  //         final user = userCredential.user!;
  //         final String givenName = appleIdCredential.fullName!.givenName ?? "";
  //
  //         final String familyName = appleIdCredential.fullName!.familyName ?? "";
  //         await user.updateDisplayName("$givenName $familyName");
  //         await user.reload();
  //       }
  //
  //       return userCredential;
  //     } else if (appleResult.status == AuthorizationStatus.error) {
  //       throw ApiMessageException(errorMessage: defaultErrorMessage);
  //     } else {
  //       throw ApiMessageException(errorMessage: defaultErrorMessage);
  //     }
  //   } catch (error) {
  //     throw ApiMessageException(errorMessage: error.toString());
  //   }
  // }

  Future<void> signOut(AuthProviders? authProvider) async {
    _firebaseAuth.signOut();
    if (authProvider == AuthProviders.google) {
      _googleSignIn.signOut();
    } else if (authProvider == AuthProviders.facebook) {
      _facebookSignin.logOut();
    } else if (AuthProviders.apple == AuthProviders.apple) {}
  }
}

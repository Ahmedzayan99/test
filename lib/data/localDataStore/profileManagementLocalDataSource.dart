import 'package:project1/utils/hiveBoxKey.dart';
import 'package:hive/hive.dart';

class ProfileManagementLocalDataSource {
  String getName() {
    return Hive.box(userdetailsBox).get(nameBoxKey, defaultValue: "");
  }

  String getUserUID() {
    return Hive.box(userdetailsBox).get(userUIdBoxKey, defaultValue: "");
  }

  String getEmail() {
    return Hive.box(userdetailsBox).get(emailBoxKey, defaultValue: "");
  }

  String getMobileNumber() {
    return Hive.box(userdetailsBox).get(mobileNumberBoxKey, defaultValue: "");
  }

  String getProfileUrl() {
    return Hive.box(userdetailsBox).get(profileUrlBoxKey, defaultValue: "");
  }

  String getFirebaseId() {
    return Hive.box(userdetailsBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  String getReferCode() {
    return Hive.box(userdetailsBox).get(referCodeBoxKey, defaultValue: "");
  }

  String getFCMToken() {
    return Hive.box(userdetailsBox).get(fcmTokenBoxKey, defaultValue: "");
  }
  //

  Future<void> setEmail(String email) async {
    Hive.box(userdetailsBox).put(emailBoxKey, email);
  }

  Future<void> setUserUId(String userId) async {
    Hive.box(userdetailsBox).put(userUIdBoxKey, userId);
  }

  Future<void> setName(String name) async {
    Hive.box(userdetailsBox).put(nameBoxKey, name);
  }

  Future<void> serProfilrUrl(String profileUrl) async {
    Hive.box(userdetailsBox).put(profileUrlBoxKey, profileUrl);
  }

  Future<void> setMobileNumber(String mobileNumber) async {
    Hive.box(userdetailsBox).put(mobileNumberBoxKey, mobileNumber);
  }

  Future<void> setFirebaseId(String firebaseId) async {
    Hive.box(userdetailsBox).put(firebaseIdBoxKey, firebaseId);
  }

  Future<void> setReferCode(String referCode) async {
    Hive.box(userdetailsBox).put(referCodeBoxKey, referCode);
  }

  Future<void> setFCMToken(String fcmToken) async {
    Hive.box(userdetailsBox).put(fcmTokenBoxKey, fcmToken);
  }
}

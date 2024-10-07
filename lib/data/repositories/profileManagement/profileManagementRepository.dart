
import 'package:project1/data/localDataStore/profileManagementLocalDataSource.dart';
import 'package:project1/data/repositories/profileManagement/profileManagementRemoteDataSource.dart';
import 'dart:io';

import 'package:project1/utils/api.dart';

class ProfileManagementRepository {
  static final ProfileManagementRepository _profileManagementRepository = ProfileManagementRepository._internal();
  late ProfileManagementLocalDataSource _profileManagementLocalDataSource;
  late ProfileManagementRemoteDataSource _profileManagementRemoteDataSource;

  factory ProfileManagementRepository() {
    _profileManagementRepository._profileManagementLocalDataSource = ProfileManagementLocalDataSource();
    _profileManagementRepository._profileManagementRemoteDataSource = ProfileManagementRemoteDataSource();

    return _profileManagementRepository;
  }

  ProfileManagementRepository._internal();

  ProfileManagementLocalDataSource get profileManagementLocalDataSource => _profileManagementLocalDataSource;

  Future<String> uploadProfilePicture(File? file, String? userId) async {
    try {
      final result = await _profileManagementRemoteDataSource.addProfileImage(file, userId);
      return result['image'].toString();
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //update profile method in remote data source
  Future<void> updateProfile({String? userId, String? email, String? name, String? mobile, String? referralCode}) async {
    try {
      await _profileManagementRemoteDataSource.updateProfile(userId: userId, email: email, name: name, mobile: mobile, referralCode: referralCode);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode:  apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      print(e.toString());
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

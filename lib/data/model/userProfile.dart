class UserProfile {
  final String? name;
  final String? userId;
  final String? firebaseId;
  final String? profileUrl;
  final String? email;
  final String? mobileNumber;
  final String? registeredDate;
  final String? referCode;
  final String? fcmToken;

  UserProfile(
      {this.email, this.fcmToken, this.referCode, this.firebaseId, this.mobileNumber, this.name, this.profileUrl, this.userId, this.registeredDate});

  static UserProfile fromJson(Map<String, dynamic> jsonData) {
    //torefer keys go profileMan.remoteRepo
    return UserProfile(
        mobileNumber: jsonData['mobile'],
        name: jsonData['name'],
        profileUrl: jsonData['profile'],
        registeredDate: jsonData['date_registered'],
        userId: jsonData['id'],
        firebaseId: jsonData['firebase_id'],
        referCode: jsonData['refer_code'],
        fcmToken: jsonData['fcm_id'],
        email: jsonData['email']);
  }

  UserProfile copyWith(
      {String? profileUrl, String? name, String? allTimeRank, String? allTimeScore, String? coins, String? status, String? mobile, String? email}) {
    return UserProfile(
      fcmToken: fcmToken,
      userId: userId,
      profileUrl: profileUrl ?? this.profileUrl,
      email: email ?? this.email,
      name: name ?? this.name,
      firebaseId: firebaseId,
      referCode: referCode,
      mobileNumber: mobile ?? mobileNumber,
      registeredDate: registeredDate,
    );
  }

  UserProfile copyWithProfileData(String? name, String? mobile, String? email) {
    return UserProfile(
      fcmToken: fcmToken,
      referCode: referCode,
      userId: userId,
      profileUrl: profileUrl,
      email: email,
      name: name,
      firebaseId: firebaseId,
      mobileNumber: mobile,
      registeredDate: registeredDate,
    );
  }
}

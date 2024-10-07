class RiderRatingModel {
  String? id;
  String? userId;
  String? RiderId;
  String? rating;
  String? comment;
  String? dataAdded;
  String? userName;
  String? userProfile;
  String? RiderRating;

  RiderRatingModel(
      {this.id, this.userId, this.RiderId, this.rating, this.comment, this.dataAdded, this.userName, this.userProfile, this.RiderRating});

  RiderRatingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    RiderId = json['rider_id'];
    rating = json['rating'];
    comment = json['comment'];
    dataAdded = json['data_added'];
    userName = json['user_name'];
    userProfile = json['user_profile'];
    RiderRating = json['rider_rating'];
  }

}

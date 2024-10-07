class ProductRatingModel {
  String? id;
  String? userId;
  String? orderId;
  String? rating;
  List<String>? images;
  String? comment;
  String? dataAdded;
  String? userName;
  String? userProfile;

  ProductRatingModel(
      {this.id,
      this.userId,
      this.orderId,
      this.rating,
      this.images,
      this.comment,
      this.dataAdded,
      this.userName,
      this.userProfile});

  ProductRatingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    rating = json['rating'];
    images = json['images'].cast<String>();
    comment = json['comment'];
    dataAdded = json['data_added'];
    userName = json['user_name'];
    userProfile = json['user_profile'];
  }

}

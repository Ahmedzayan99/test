class FavouriteModel {
  String? id;
  String? title;
  String? dateCreated;

  FavouriteModel({this.id, this.title, this.dateCreated});

  FavouriteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    dateCreated = json['date_created'];
  }

}
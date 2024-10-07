class HelpAndSupportModel {
  String? id;
  String? title;
  String? dateCreated;

  HelpAndSupportModel({this.id, this.title, this.dateCreated});

  HelpAndSupportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    dateCreated = json['date_created'];
  }

}
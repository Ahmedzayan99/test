class CategoriesModel {
  String? id;
  String? name;

  CategoriesModel({this.id, this.name});

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
class ProductAddOnsModel {
  String? id;
  String? productId;
  String? title;
  String? description;
  String? price;
  String? calories;

  ProductAddOnsModel(
      {this.id,
        this.productId,
        this.title,
        this.description,
        this.price,
        this.calories});

  ProductAddOnsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    title = json['title'];
    description = json['description'];
    price = json['price'];
    calories = json['calories'];
  }

}
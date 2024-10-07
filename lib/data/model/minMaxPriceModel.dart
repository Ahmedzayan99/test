class MinMaxPriceModel {
  dynamic minPrice;
  dynamic maxPrice;
  dynamic specialPrice;
  dynamic maxSpecialPrice;
  dynamic discountInPercentage;

  MinMaxPriceModel(
      {this.minPrice,
        this.maxPrice,
        this.specialPrice,
        this.maxSpecialPrice,
        this.discountInPercentage});

  MinMaxPriceModel.fromJson(Map<String, dynamic> json) {
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    specialPrice = json['special_price'];
    maxSpecialPrice = json['max_special_price'];
    discountInPercentage = json['discount_in_percentage'];
  }

}
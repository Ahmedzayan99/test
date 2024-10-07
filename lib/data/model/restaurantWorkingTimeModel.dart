class RestaurantWorkingTimeModel {
  String? id;
  String? restaurantId;
  String? day;
  String? openingTime;
  String? closingTime;
  String? isOpen;
  String? dateCreated;

  RestaurantWorkingTimeModel(
      {this.id,
        this.restaurantId,
        this.day,
        this.openingTime,
        this.closingTime,
        this.isOpen,
        this.dateCreated});

  RestaurantWorkingTimeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['partner_id'];
    day = json['day'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    isOpen = json['is_open'];
    dateCreated = json['date_created'];
  }

}
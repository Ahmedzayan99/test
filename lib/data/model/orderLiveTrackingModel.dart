class OrderLiveTrackingModel {
  String? id;
  String? orderId;
  String? orderStatus;
  String? latitude;
  String? longitude;
  String? dateCreated;

  OrderLiveTrackingModel(
      {this.id,
        this.orderId,
        this.orderStatus,
        this.latitude,
        this.longitude,
        this.dateCreated});

  OrderLiveTrackingModel.fromJson(Map<String, dynamic> json) {
    print(json);
    id = json['id'];
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    dateCreated = json['date_created'];
  }

}
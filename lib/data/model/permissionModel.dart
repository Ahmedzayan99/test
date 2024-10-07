class Permissions {
  String? customerPrivacy;
  String? viewOrderOtp;
  String? assignRider;
  String? isEmailSettingOn;
  String? deliveryOrders;
  String? selfPickup;

  Permissions({this.customerPrivacy, this.viewOrderOtp, this.assignRider, this.isEmailSettingOn, this.deliveryOrders, this.selfPickup});

  Permissions.fromJson(Map<String, dynamic> json) {
    customerPrivacy = json['customer_privacy'];
    viewOrderOtp = json['view_order_otp'];
    assignRider = json['assign_rider'];
    isEmailSettingOn = json['is_email_setting_on'];
    deliveryOrders = json['delivery_orders'];
    selfPickup = json['self_pickup'];
  }

}

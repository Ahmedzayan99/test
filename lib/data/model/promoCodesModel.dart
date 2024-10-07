class PromoCodesModel {
  String? id;
  String? promoCode;
  String? message;
  String? startDate;
  String? endDate;
  String? discount;
  String? repeatUsage;
  String? minOrderAmt;
  String? noOfUsers;
  String? discountType;
  String? maxDiscountAmt;
  String? image;
  String? noOfRepeatUsage;
  String? status;
  String? remainingDays;

  PromoCodesModel(
      {this.id,
        this.promoCode,
        this.message,
        this.startDate,
        this.endDate,
        this.discount,
        this.repeatUsage,
        this.minOrderAmt,
        this.noOfUsers,
        this.discountType,
        this.maxDiscountAmt,
        this.image,
        this.noOfRepeatUsage,
        this.status,
        this.remainingDays});

  PromoCodesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    promoCode = json['promo_code'];
    message = json['message'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    discount = json['discount'];
    repeatUsage = json['repeat_usage'];
    minOrderAmt = json['min_order_amt'];
    noOfUsers = json['no_of_users'];
    discountType = json['discount_type'];
    maxDiscountAmt = json['max_discount_amt'];
    image = json['image'];
    noOfRepeatUsage = json['no_of_repeat_usage'];
    status = json['status'];
    remainingDays = json['remaining_days'];
  }

}
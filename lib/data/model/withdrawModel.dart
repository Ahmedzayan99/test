class WithdrawModel {
  String? id;
  String? userId;
  String? paymentType;
  String? paymentAddress;
  String? amountRequested;
  String? remarks;
  String? status;
  String? dateCreated;

  WithdrawModel({this.id, this.userId, this.paymentType, this.paymentAddress, this.amountRequested, this.remarks, this.status, this.dateCreated});

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    paymentType = json['payment_type'];
    paymentAddress = json['payment_address'];
    amountRequested = json['amount_requested'];
    remarks = json['remarks'];
    status = json['status'];
    dateCreated = json['date_created'];
  }

}

class TransactionModel {
  String? id;
  String? transactionType;
  String? userId;
  String? orderId;
  String? type;
  String? txnId;
  String? payuTxnId;
  String? amount;
  String? status;
  String? currencyCode;
  String? payerEmail;
  String? message;
  String? transactionDate;
  String? dateCreated;

  TransactionModel(
      {this.id,
        this.transactionType,
        this.userId,
        this.orderId,
        this.type,
        this.txnId,
        this.payuTxnId,
        this.amount,
        this.status,
        this.currencyCode,
        this.payerEmail,
        this.message,
        this.transactionDate,
        this.dateCreated});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionType = json['transaction_type'];
    userId = json['user_id'];
    orderId = json['order_id'];
    type = json['type'];
    txnId = json['txn_id'];
    payuTxnId = json['payu_txn_id'];
    amount = json['amount'];
    status = json['status'];
    currencyCode = json['currency_code'];
    payerEmail = json['payer_email'];
    message = json['message'];
    transactionDate = json['transaction_date'];
    dateCreated = json['date_created'];
  }

}
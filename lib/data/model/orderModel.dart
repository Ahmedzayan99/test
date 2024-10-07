import 'package:project1/data/model/addOnsDataModel.dart';

class OrderModel {
  String? id;
  String? userId;
  String? riderId;
  String? addressId;
  String? mobile;
  String? total;
  String? deliveryCharge;
  String? isDeliveryChargeReturnable;
  String? walletBalance;
  String? totalPayable;
  String? promoCode;
  String? promoDiscount;
  String? discount;
  String? finalTotal;
  String? paymentMethod;
  String? latitude;
  String? longitude;
  String? address;
  String? deliveryTime;
  String? deliveryDate;
  List<List>? status;
  String? activeStatus;
  String? dateAdded;
  String? otp;
  String? isSelfPickUp;
  String? ownerNote;
  String? selfPickupTime;
  String? reason;
  String? notes;
  String? deliveryTip;
  String? username;
  String? countryCode;
  String? name;
  String? riderMobile;
  String? riderName;
  String? riderImage;
  String? riderRating;
  String? riderNoOfRatings;
  String? totalTaxPercent;
  String? totalTaxAmount;
  String? invoiceHtml;
  List<OrderItems>? orderItems;
  String? orderProductRating;
  String? orderRiderRating;

  OrderModel(
      {this.id,
      this.userId,
      this.riderId,
      this.addressId,
      this.mobile,
      this.total,
      this.deliveryCharge,
      this.isDeliveryChargeReturnable,
      this.walletBalance,
      this.totalPayable,
      this.promoCode,
      this.promoDiscount,
      this.discount,
      this.finalTotal,
      this.paymentMethod,
      this.latitude,
      this.longitude,
      this.address,
      this.deliveryTime,
      this.deliveryDate,
      this.status,
      this.activeStatus,
      this.dateAdded,
      this.otp,
      this.isSelfPickUp,
      this.ownerNote,
      this.selfPickupTime,
      this.reason,
      this.notes,
      this.deliveryTip,
      this.username,
      this.countryCode,
      this.name,
      this.riderMobile,
      this.riderName,
      this.riderImage,
      this.riderRating,
      this.riderNoOfRatings,
      this.totalTaxPercent,
      this.totalTaxAmount,
      this.invoiceHtml,
      this.orderItems,
      this.orderProductRating,
      this.orderRiderRating});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    riderId = json['rider_id'];
    addressId = json['address_id'];
    mobile = json['mobile'];
    total = json['total'];
    deliveryCharge = json['delivery_charge'];
    isDeliveryChargeReturnable = json['is_delivery_charge_returnable'];
    walletBalance = json['wallet_balance'];
    totalPayable = json['total_payable'];
    promoCode = json['promo_code'];
    promoDiscount = json['promo_discount'];
    discount = json['discount'];
    finalTotal = json['final_total'];
    paymentMethod = json['payment_method'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    deliveryTime = json['delivery_time'];
    deliveryDate = json['delivery_date'];
    if (json['status'] != null) {
      status = <List>[];
      json['status'].forEach((v) {
        status!.add((v));
      });
    }
    activeStatus = json['active_status'];
    dateAdded = json['date_added'];
    otp = json['otp'];
    isSelfPickUp = json['is_self_pick_up'];
    ownerNote = json['owner_note'];
    selfPickupTime = json['self_pickup_time'];
    reason = json['reason'];
    notes = json['notes'];
    deliveryTip = json['delivery_tip'];
    username = json['username'];
    countryCode = json['country_code'];
    name = json['name'];
    riderMobile = json['rider_mobile'];
    riderName = json['rider_name'];
    riderImage = json['rider_image'];
    riderRating = json['rider_rating'];
    riderNoOfRatings = json['rider_no_of_ratings'];
    totalTaxPercent = json['total_tax_percent'];
    totalTaxAmount = json['total_tax_amount'];
    invoiceHtml = json['invoice_html'];
    if (json['order_items'] != null) {
      orderItems = <OrderItems>[];
      json['order_items'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    orderProductRating = json["order_product_rating"] ?? "";
    orderRiderRating = json["order_rider_rating"] ?? "";
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? riderId,
    String? addressId,
    String? mobile,
    String? total,
    String? deliveryCharge,
    String? isDeliveryChargeReturnable,
    String? walletBalance,
    String? totalPayable,
    String? promoCode,
    String? promoDiscount,
    String? discount,
    String? finalTotal,
    String? paymentMethod,
    String? latitude,
    String? longitude,
    String? address,
    String? deliveryTime,
    String? deliveryDate,
    List<List>? status,
    String? activeStatus,
    String? dateAdded,
    String? otp,
    String? isSelfPickUp,
    String? ownerNote,
    String? selfPickupTime,
    String? reason,
    String? notes,
    String? deliveryTip,
    String? username,
    String? countryCode,
    String? name,
    String? riderMobile,
    String? riderName,
    String? riderImage,
    String? riderRating,
    String? riderNoOfRatings,
    String? totalTaxPercent,
    String? totalTaxAmount,
    String? invoiceHtml,
    List<OrderItems>? orderItems,
    String? orderProductRating,
    String? orderRiderRating,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      riderId: riderId ?? this.riderId,
      addressId: addressId ?? this.addressId,
      mobile: mobile ?? this.mobile,
      total: total ?? this.total,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      isDeliveryChargeReturnable: isDeliveryChargeReturnable ?? this.isDeliveryChargeReturnable,
      walletBalance: walletBalance ?? this.walletBalance,
      totalPayable: totalPayable ?? this.totalPayable,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      discount: discount ?? this.discount,
      finalTotal: finalTotal ?? this.finalTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      activeStatus: activeStatus ?? this.activeStatus,
      dateAdded: dateAdded ?? this.dateAdded,
      otp: otp ?? this.otp,
      isSelfPickUp: isSelfPickUp ?? this.isSelfPickUp,
      ownerNote: ownerNote ?? this.ownerNote,
      selfPickupTime: selfPickupTime ?? this.selfPickupTime,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      deliveryTip: deliveryTip ?? this.deliveryTip,
      username: username ?? this.username,
      countryCode: countryCode ?? this.countryCode,
      name: name ?? this.name,
      riderMobile: riderMobile ?? this.riderMobile,
      riderName: riderName ?? this.riderName,
      riderImage: riderImage ?? this.riderImage,
      riderRating: riderRating ?? this.riderRating,
      riderNoOfRatings: riderNoOfRatings ?? this.riderNoOfRatings,
      totalTaxPercent: totalTaxPercent ?? this.totalTaxPercent,
      totalTaxAmount: totalTaxAmount ?? this.totalTaxAmount,
      invoiceHtml: invoiceHtml ?? this.invoiceHtml,
      orderItems: orderItems ?? this.orderItems,
      orderProductRating: orderProductRating ?? this.orderProductRating,
      orderRiderRating: orderRiderRating ?? this.orderRiderRating,
    );
  }

}


class OrderItems {
  String? id;
  String? userId;
  String? orderId;
  String? partnerId;
  String? isCredited;
  String? productName;
  String? variantName;
  List<AddOnsDataModel>? addOns;
  String? productVariantId;
  String? quantity;
  String? price;
  String? discountedPrice;
  String? taxPercent;
  String? taxAmount;
  String? discount;
  String? subTotal;
  String? dateAdded;
  String? productId;
  String? isCancelable;
  String? cancelableTill;
  String? isReturnable;
  String? image;
  String? name;
  String? indicator;
  String? type;
  String? orderCounter;
  List<RestaurantDetails>? partnerDetails;
  String? varaintIds;
  String? variantValues;
  String? attrName;
  String? imageSm;
  String? imageMd;

  OrderItems(
      {this.id,
      this.userId,
      this.orderId,
      this.partnerId,
      this.isCredited,
      this.productName,
      this.variantName,
      this.productVariantId,
      this.quantity,
      this.price,
      this.discountedPrice,
      this.taxPercent,
      this.taxAmount,
      this.discount,
      this.subTotal,
      this.dateAdded,
      this.productId,
      this.isCancelable,
      this.cancelableTill,
      this.isReturnable,
      this.image,
      this.name,
      this.indicator,
      this.type,
      this.orderCounter,
      this.partnerDetails,
      this.varaintIds,
      this.variantValues,
      this.attrName,
      this.imageSm,
      this.imageMd});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    partnerId = json['partner_id'];
    isCredited = json['is_credited'];
    productName = json['product_name'];
    variantName = json['variant_name'];
    if (json['add_ons'] != null) {
      addOns = <AddOnsDataModel>[];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOnsDataModel.fromJson(v));
      });
    }
    productVariantId = json['product_variant_id'];
    quantity = json['quantity'];
    price = json['price'];
    discountedPrice = json['discounted_price'];
    taxPercent = json['tax_percent'];
    taxAmount = json['tax_amount'];
    discount = json['discount'];
    subTotal = json['sub_total'];
    dateAdded = json['date_added'];
    productId = json['product_id'];
    isCancelable = json['is_cancelable'];
    cancelableTill = json['cancelable_till']??"";
    isReturnable = json['is_returnable'];
    image = json['image'];
    name = json['name'];
    indicator = json['indicator'];
    type = json['type'];
    orderCounter = json['order_counter'];
    if (json['partner_details'] != null) {
      partnerDetails = <RestaurantDetails>[];
      json['partner_details'].forEach((v) {
        partnerDetails!.add(RestaurantDetails.fromJson(v));
      });
    }
    varaintIds = json['varaint_ids'];
    variantValues = json['variant_values'];
    attrName = json['attr_name'];
    imageSm = json['image_sm'];
    imageMd = json['image_md'];
  }

}

class RestaurantDetails {
  String? partnerId;
  String? isFavorite;
  String? isRestroOpen;
  String? partnerCookTime;
  String? distance;
  String? ownerName;
  String? email;
  List<String>? tags;
  String? mobile;
  String? partnerAddress;
  String? cityId;
  String? cityName;
  String? fcmId;
  String? latitude;
  String? longitude;
  String? balance;
  String? slug;
  String? partnerName;
  String? description;
  String? partnerIndicator;
  List<String>? gallery;
  String? partnerRating;
  String? noOfRatings;
  String? accountNumber;
  String? accountName;
  String? bankCode;
  String? bankName;
  String? cookingTime;
  String? status;
  String? commission;
  String? partnerProfile;
  String? nationalIdentityCard;
  String? addressProof;
  String? taxNumber;
  String? dateAdded;

  RestaurantDetails(
      {this.partnerId,
      this.isFavorite,
      this.isRestroOpen,
      this.partnerCookTime,
      this.distance,
      this.ownerName,
      this.email,
      this.tags,
      this.mobile,
      this.partnerAddress,
      this.cityId,
      this.cityName,
      this.fcmId,
      this.latitude,
      this.longitude,
      this.balance,
      this.slug,
      this.partnerName,
      this.description,
      this.partnerIndicator,
      this.gallery,
      this.partnerRating,
      this.noOfRatings,
      this.accountNumber,
      this.accountName,
      this.bankCode,
      this.bankName,
      this.cookingTime,
      this.status,
      this.commission,
      this.partnerProfile,
      this.nationalIdentityCard,
      this.addressProof,
      this.taxNumber,
      this.dateAdded});

  RestaurantDetails.fromJson(Map<String, dynamic> json) {
    partnerId = json['partner_id'];
    isFavorite = json['is_favorite'];
    isRestroOpen = json['is_restro_open'];
    partnerCookTime = json['partner_cook_time'];
    distance = json['distance'];
    ownerName = json['owner_name'];
    email = json['email'];
    tags = json['tags'].cast<String>();
    mobile = json['mobile'];
    partnerAddress = json['partner_address'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    fcmId = json['fcm_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    balance = json['balance'];
    slug = json['slug'];
    partnerName = json['partner_name'];
    description = json['description'];
    partnerIndicator = json['partner_indicator'];
    gallery = json['gallery'].cast<String>();
    partnerRating = json['partner_rating'];
    noOfRatings = json['no_of_ratings'];
    accountNumber = json['account_number'];
    accountName = json['account_name'];
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
    cookingTime = json['cooking_time'];
    status = json['status'];
    commission = json['commission'];
    partnerProfile = json['partner_profile'];
    nationalIdentityCard = json['national_identity_card'];
    addressProof = json['address_proof'];
    taxNumber = json['tax_number'];
    dateAdded = json['date_added'];
  }

}

import 'package:project1/data/model/minMaxPriceModel.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/data/model/variantsModel.dart';

class SliderModel {
  String? id;
  String? type;
  String? typeId;
  String? image;
  String? dateAdded;
  List<Data>? data;

  SliderModel(
      {this.id, this.type, this.typeId, this.image, this.dateAdded, this.data});

  SliderModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    type = json['type'];
    typeId = json['type_id'];
    image = json['image'];
    dateAdded = json['date_added'];

    data = json['data'] == null ? [] : (json['data'] as List).map((e) => Data.fromJson(e ?? {})).toList();
    // if (json['data'] != null) {
    //   data = List<Data>.from([]);
    //   json['data'].forEach((v) {
    //     data!.add( Data.fromJson(v));
    //   });
    // }
  }
}

class Data {
  String? id;
  String? name;
  String? parentId;
  String? slug;
  String? image;
  String? banner;
  String? rowOrder;
  String? status;
  String? clicks;
 // List<Null>? children;
  String? text;
  State? state; //State
  String? icon;
  String? level;
  String? total;
  String? sales;
  String? stockType;
  String? isPricesInclusiveTax;
  String? type;
  String? attrValueIds;
  String? partnerRating;
  String? partnerSlug;
  String? partnerNoOfRatings;
  String? partnerProfile;
  String? partnerName;
  String? partnerDescription;
  String? partnerId;
  String? ownerName;
  String? stock;
  String? categoryId;
  String? shortDescription;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? codAllowed;
  String? isSpicy;
  String? rating;
  String? noOfRatings;
  String? isCancelable;
  String? cancelableTill;
  String? indicator;
  List<String>? highlights;
  String? availability;
  String? categoryName;
  String? taxPercentage;
  String? bestSeller;
 // List<Null>? reviewImages;
 // List<Null>? attributes;
  List<VariantsModel>? variants;
  MinMaxPriceModel? minMaxPrice;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
 // List<Null>? variantAttributes;
  List<RestaurantModel>? partnerDetails;


  Data(
      {this.id,
        this.name,
        this.parentId,
        this.slug,
        this.image,
        this.banner,
        this.rowOrder,
        this.status,
        this.clicks,
      //  this.children,
        this.text,
        this.state,
        this.icon,
        this.level,
        this.total,
        this.sales,
        this.stockType,
        this.isPricesInclusiveTax,
        this.type,
        this.attrValueIds,
        this.partnerRating,
        this.partnerSlug,
        this.partnerNoOfRatings,
        this.partnerProfile,
        this.partnerName,
        this.partnerDescription,
        this.partnerId,
        this.ownerName,
        this.stock,
        this.categoryId,
        this.shortDescription,
        this.totalAllowedQuantity,
        this.minimumOrderQuantity,
        this.quantityStepSize,
        this.codAllowed,
        this.isSpicy,
        this.rating,
        this.noOfRatings,
        this.isCancelable,
        this.cancelableTill,
        this.indicator,
        this.highlights,
        this.availability,
        this.categoryName,
        this.taxPercentage,
        this.bestSeller,
      //  this.reviewImages,
      //  this.attributes,
        this.variants,
        this.minMaxPrice,
        this.isPurchased,
        this.isFavorite,
        this.imageMd,
        this.imageSm,
      //  this.variantAttributes
        this.partnerDetails});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    parentId = json['parent_id'] ?? "";
    slug = json['slug'] ?? "";
    image = json['image'] ?? "";
    banner = json['banner'] ?? "";
    rowOrder = json['row_order'] ?? "";
    status = json['status'] ?? "";
    clicks = json['clicks'] ?? "";
 /*   if (json['children'] != null) {
      children = <Null>[];
      json['children'].forEach((v) {
        children!.add(new Null.fromJson(v));
      });
    }*/
    text = json['text'] ?? "";
    state = State.fromJson(json['state'] ?? {});
    icon = json['icon'] ?? "";
    level = json['level'] == null ? "" : json['level'].toString()  ;
    total = json['total'] == null ? "" : json['total'].toString() ;
    sales = json['sales'] ?? "";
    stockType = json['stock_type'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    type = json['type'] ?? "";
    attrValueIds = json['attr_value_ids'] ?? "";
    partnerRating = json['partner_rating'] ?? "";
    partnerSlug = json['partner_slug'] ?? "";
    partnerNoOfRatings = json['partner_no_of_ratings'] ?? "";
    partnerProfile = json['partner_profile'] ?? "";
    partnerName = json['partner_name'] ?? "";
    partnerDescription = json['partner_description'] ?? "";
    partnerId = json['partner_id'] ?? "";
    ownerName = json['owner_name'] ?? "";
    stock = json['stock'] ?? "";
    categoryId = json['category_id'] ?? "";
    shortDescription = json['short_description'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
    quantityStepSize = json['quantity_step_size'] ?? "";
    isSpicy = json['is_spicy'] ?? "";
    codAllowed = json['cod_allowed'] ?? "";
    rating = json['rating'] ?? "";
    noOfRatings = json['no_of_ratings'] ?? "";
    isCancelable = json['is_cancelable'] ?? "";
    cancelableTill = json['cancelable_till']?? "";
    indicator = json['indicator'] ?? "";
    highlights = json['highlights'] == null ? List<String>.from([]) : (json['highlights'] as List).map((e) => e.toString()).toList() ;
    availability = json['availability'].toString();
    categoryName = json['category_name'] ?? "";
    taxPercentage = json['tax_percentage'] ?? "";
    bestSeller = json['best_seller'] ?? "";
  /*  if (json['review_images'] != null) {
      reviewImages = <Null>[];
      json['review_images'].forEach((v) {
        reviewImages!.add(new Null.fromJson(v));
      });
    }*/
  /*  if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }*/
    if (json['variants'] != null) {
      variants = <VariantsModel>[];
      json['variants'].forEach((v) {
        variants!.add( VariantsModel.fromJson(v));
      });
    }
    else {
      variants = [];
    }
    minMaxPrice = json['min_max_price'] != null
        ? MinMaxPriceModel.fromJson(json['min_max_price'])
        : null;
    isPurchased = json['is_purchased'] ?? false;
    isFavorite = json['is_favorite'] ?? "";
    imageMd = json['image_md'] ?? "";
    imageSm = json['image_sm'] ?? "";
  /*  if (json['variant_attributes'] != null) {
      variantAttributes = <Null>[];
      json['variant_attributes'].forEach((v) {
        variantAttributes!.add(new Null.fromJson(v));
      });
    }*/
    if (json['partner_details'] != null) {
      partnerDetails = <RestaurantModel>[];
      json['partner_details'].forEach((v) {
        partnerDetails!.add(RestaurantModel.fromJson(v));
      });
    }
  }

}

class State {
  bool? opened;

  State({this.opened});

  State.fromJson(Map<String, dynamic> json) {
    opened = json['opened'] ?? false;
  }

}




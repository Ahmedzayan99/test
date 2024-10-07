import 'package:project1/data/model/attributesModel.dart';
import 'package:project1/data/model/minMaxPriceModel.dart';
import 'package:project1/data/model/productAddOnsModel.dart';
import 'package:project1/data/model/variantAttributesModel.dart';
import 'package:project1/data/model/variantsModel.dart';

class ProductDetailsModel {
  String? sales;
  String? stockType;
  String? isPricesInclusiveTax;
  String? type;
  String? attrValueIds;
  String? partnerIndicator;
  String? partnerRating;
  String? partnerSlug;
  String? partnerNoOfRatings;
  String? partnerProfile;
  String? partnerName;
  String? partnerDescription;
  String? partnerId;
  String? ownerName;
  String? id;
  String? stock;
  String? name;
  String? categoryId;
  String? shortDescription;
  String? slug;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? codAllowed;
  String? isSpicy;
  String? rowOrder;
  String? rating;
  String? noOfRatings;
  String? image;
  String? isCancelable;
  String? cancelableTill;
  String? indicator;
  List<String>? highlights;
  String? availability;
  String? categoryName;
  String? taxPercentage;
  String? bestSeller;
  // List<String>? reviewImages;
  List<AttributesModel>? attributes;
  List<ProductAddOnsModel>? productAddOns;
  List<VariantsModel>? variants;
  MinMaxPriceModel? minMaxPrice;
  String? isRestroOpen;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<VariantAttributesModel>? variantAttributes;
  String? total;

  ProductDetailsModel(
      {this.sales,
        this.stockType,
        this.isPricesInclusiveTax,
        this.type,
        this.attrValueIds,
        this.partnerIndicator,
        this.partnerRating,
        this.partnerSlug,
        this.partnerNoOfRatings,
        this.partnerProfile,
        this.partnerName,
        this.partnerDescription,
        this.partnerId,
        this.ownerName,
        this.id,
        this.stock,
        this.name,
        this.categoryId,
        this.shortDescription,
        this.slug,
        this.totalAllowedQuantity,
        this.minimumOrderQuantity,
        this.quantityStepSize,
        this.codAllowed,
        this.isSpicy,
        this.rowOrder,
        this.rating,
        this.noOfRatings,
        this.image,
        this.isCancelable,
        this.cancelableTill,
        this.indicator,
        this.highlights,
        this.availability,
        this.categoryName,
        this.taxPercentage,
        this.bestSeller,
        // this.reviewImages,
        this.attributes,
        this.productAddOns,
        this.variants,
        this.minMaxPrice,
        this.isRestroOpen,
        this.isPurchased,
        this.isFavorite,
        this.imageMd,
        this.imageSm,
        this.variantAttributes,
        this.total});

  ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    sales = json['sales'] ?? "";
    stockType = json['stock_type'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    type = json['type'] ?? "";
    attrValueIds = json['attr_value_ids'] ?? "";
    partnerIndicator = json['partner_indicator'] ?? "";
    partnerRating = json['partner_rating'] ?? "";
    partnerSlug = json['partner_slug'] ?? "";
    partnerNoOfRatings = json['partner_no_of_ratings'] ?? "";
    partnerProfile = json['partner_profile'] ?? "";
    partnerName = json['partner_name'] ?? "";
    partnerDescription = json['partner_description'] ?? "";
    partnerId = json['partner_id'] ?? "";
    ownerName = json['owner_name'] ?? "";
    id = json['id'] ?? "";
    stock = json['stock'] ?? "";
    name = json['name'] ?? "";
    categoryId = json['category_id'] ?? "";
    shortDescription = json['short_description'] ?? "";
    slug = json['slug'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
    quantityStepSize = json['quantity_step_size'] ?? "";
    codAllowed = json['cod_allowed'] ?? "";
    isSpicy = json['is_spicy'] ?? "";
    rowOrder = json['row_order'] ?? "";
    rating = json['rating'] ?? "";
    noOfRatings = json['no_of_ratings'] ?? "";
    image = json['image'] ?? "";
    isCancelable = json['is_cancelable'] ?? "";
    cancelableTill = json['cancelable_till'] ?? "";
    indicator = json['indicator'] ?? "";
    highlights = json['highlights'] == null ? List<String>.from([]) : (json['highlights'] as List).map((e) => e.toString()).toList() ;
    availability = json['availability'].toString();
    categoryName = json['category_name'];
    taxPercentage = json['tax_percentage'];
    bestSeller = json['best_seller'] ?? "";
    /*  if (json['review_images'] != null) {
      reviewImages = <String>[];
      json['review_images'].forEach((v) {
        reviewImages!.add(new String.fromJson(v));
      });
    }*/
    if (json['attributes'] != null) {
      attributes = <AttributesModel>[];
      json['attributes'].forEach((v) {
        attributes!.add(AttributesModel.fromJson(v));
      });
    }
    if (json['product_add_ons'] != null) {
      productAddOns = <ProductAddOnsModel>[];
      json['product_add_ons'].forEach((v) {
        productAddOns!.add(ProductAddOnsModel.fromJson(v));
      });
    }
    if (json['variants'] != null) {
      variants = <VariantsModel>[];
      json['variants'].forEach((v) {
        variants!.add(VariantsModel.fromJson(v));
      });
    }
    minMaxPrice = json['min_max_price'] != null
        ? MinMaxPriceModel.fromJson(json['min_max_price'])
        : null;
    isRestroOpen = json['is_restro_open'];
    isPurchased = json['is_purchased'];
    isFavorite = json['is_favorite'];
    imageMd = json['image_md'];
    imageSm = json['image_sm'];
    if (json['variant_attributes'] != null) {
      variantAttributes = <VariantAttributesModel>[];
      json['variant_attributes'].forEach((v) {
        variantAttributes!.add(VariantAttributesModel.fromJson(v));
      });
    }
    total = json['total'];
  }

}
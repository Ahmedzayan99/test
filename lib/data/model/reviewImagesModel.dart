import 'package:project1/data/model/productRatingModel.dart';

class ReviewImagesModel {
  String? totalImages;
  String? totalReviewsWithImages;
  String? noOfRating;
  String? totalReviews;
  String? star1;
  String? star2;
  String? star3;
  String? star4;
  String? star5;
  List<ProductRatingModel>? productRating;

  ReviewImagesModel(
      {this.totalImages,
      this.totalReviewsWithImages,
      this.noOfRating,
      this.totalReviews,
      this.star1,
      this.star2,
      this.star3,
      this.star4,
      this.star5,
      this.productRating});

  ReviewImagesModel.fromJson(Map<String, dynamic> json) {
    totalImages = json['total_images'].toString() ;
    totalReviewsWithImages = json['total_reviews_with_images'];
    noOfRating = json['no_of_rating'];
    totalReviews = json['total_reviews'];
    star1 = json['star_1'];
    star2 = json['star_2'];
    star3 = json['star_3'];
    star4 = json['star_4'];
    star5 = json['star_5'];
    if (json['product_rating'] != null) {
      productRating = <ProductRatingModel>[];
      json['product_rating'].forEach((v) {
        productRating!.add(ProductRatingModel.fromJson(v));
      });
    }
  }

}

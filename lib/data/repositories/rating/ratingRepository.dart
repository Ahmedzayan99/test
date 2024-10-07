import 'dart:io';

import 'package:project1/data/repositories/rating/ratingRemoteDataSource.dart';
import 'package:project1/utils/api.dart';

class RatingRepository {
  static final RatingRepository _ratingRepository = RatingRepository._internal();
  late RatingRemoteDataSource _ratingRemoteDataSource;

  factory RatingRepository() {
    _ratingRepository._ratingRemoteDataSource = RatingRemoteDataSource();
    return _ratingRepository;
  }

  RatingRepository._internal();

  Future setProductRating(String? userId, List? productRatingDataString, String? orderId) async {
    try {
      final result = await _ratingRemoteDataSource.setProductRating(userId, productRatingDataString, orderId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future setOrderRating(String? userId, String? orderId, String? rating, String? comment , List<File> images) async {
    try {
      final result = await _ratingRemoteDataSource.setOrderRating(userId, orderId, rating, comment , images);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future setRiderRating(String? userId, String? riderId, String? rating, String? comment, String? orderId) async {
    try {
      final result = await _ratingRemoteDataSource.setRiderRating(userId, riderId, rating, comment, orderId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteProductRating(String? ratingId) async {
    try {
      final result = await _ratingRemoteDataSource.deleteProductRating(ratingId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteOrderRating(String? orderId) async {
    try {
      final result = await _ratingRemoteDataSource.deleteOrderRating(orderId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteRiderRating(String? ratingId) async {
    try {
      final result = await _ratingRemoteDataSource.deleteRiderRating(ratingId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    }  catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}

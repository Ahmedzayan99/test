import 'dart:io';

import 'package:project1/utils/api.dart';
import 'package:project1/data/model/deliveryBoyRatingModel.dart';
import 'package:project1/data/repositories/rating/ratingRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SetOrderRatingState {}

class SetOrderRatingInitial extends SetOrderRatingState {}

class SetOrderRatingProgress extends SetOrderRatingState {}

class SetOrderRatingSuccess extends SetOrderRatingState {
  final RiderRatingModel riderRatingModel;

  SetOrderRatingSuccess(this.riderRatingModel);
}

class SetOrderRatingFailure extends SetOrderRatingState {
  final String errorCode, errorStatusCode;
  SetOrderRatingFailure(this.errorCode, this.errorStatusCode);
}

class SetOrderRatingCubit extends Cubit<SetOrderRatingState> {
  final RatingRepository _ratingRepository;

  SetOrderRatingCubit(this._ratingRepository) : super(SetOrderRatingInitial());

  void setOrderRating(String? userId, String? orderId, String? rating, String? comment, List<File> images) {
    emit(SetOrderRatingProgress());
    _ratingRepository.setOrderRating(userId,  orderId,  rating,  comment, images).then((value) => emit(SetOrderRatingSuccess(RiderRatingModel()))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("setOrderRatingError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(SetOrderRatingFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
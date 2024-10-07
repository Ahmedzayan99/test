import 'package:project1/data/model/orderModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/data/repositories/rating/ratingRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SetProductRatingState {}

class SetProductRatingInitial extends SetProductRatingState {}

class SetProductRatingProgress extends SetProductRatingState {}

class SetProductRatingSuccess extends SetProductRatingState {
  final OrderModel orderModel;

  SetProductRatingSuccess(this.orderModel);
}

class SetProductRatingFailure extends SetProductRatingState {
  final String errorCode, errorStatusCode;
  SetProductRatingFailure(this.errorCode, this.errorStatusCode);
}

class SetProductRatingCubit extends Cubit<SetProductRatingState> {
  final RatingRepository _ratingRepository;

  SetProductRatingCubit(this._ratingRepository) : super(SetProductRatingInitial());

  void setProductRating(String? userId, List? productRatingDataString, String? orderId) {
    emit(SetProductRatingProgress());
    _ratingRepository
        .setProductRating(userId, productRatingDataString, orderId)
        .then((value) =>
            emit(SetProductRatingSuccess(OrderModel.fromJson(value[0]))))
        .catchError((e) {
      print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("setProductRatingError:${apiMessageAndCodeException.errorMessage.toString()}");
      emit(SetProductRatingFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

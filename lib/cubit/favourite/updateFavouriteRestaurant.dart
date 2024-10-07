import 'package:project1/data/repositories/favourite/favouriteRepository.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateRestaurantFavoriteStatusState {}

class UpdateRestaurantFavoriteStatusInitial extends UpdateRestaurantFavoriteStatusState {}

class UpdateRestaurantFavoriteStatusInProgress extends UpdateRestaurantFavoriteStatusState {}

class UpdateRestaurantFavoriteStatusSuccess extends UpdateRestaurantFavoriteStatusState {
  final RestaurantModel restaurant;
  final bool wasFavoriteRestaurantProcess; //to check that process is to favorite the restaurant or not
  UpdateRestaurantFavoriteStatusSuccess(this.restaurant, this.wasFavoriteRestaurantProcess);
}

class UpdateRestaurantFavoriteStatusFailure extends UpdateRestaurantFavoriteStatusState {
  final String errorMessage, errorStatusCode;
  UpdateRestaurantFavoriteStatusFailure(this.errorMessage, this.errorStatusCode);
}

class UpdateRestaurantFavoriteStatusCubit extends Cubit<UpdateRestaurantFavoriteStatusState> {
  late FavouriteRepository favoriteRepository;
  UpdateRestaurantFavoriteStatusCubit() : super(UpdateRestaurantFavoriteStatusInitial()) {
    favoriteRepository = FavouriteRepository();
  }

  void favoriteRestaurant({required String userId, required String type, required RestaurantModel restaurant}) {
    //
    emit(UpdateRestaurantFavoriteStatusInProgress());
    favoriteRepository.favoriteRestaurant(userId: userId, type: type, restaurantId: restaurant.partnerId!).then((value) {
      emit(UpdateRestaurantFavoriteStatusSuccess(restaurant, true));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException  = e;
      //print("FavoriteRestaurantError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(UpdateRestaurantFavoriteStatusFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  //can pass only restaurant id here
  void unFavoriteRestaurant({required String userId, required String type, required RestaurantModel restaurant}) {
    emit(UpdateRestaurantFavoriteStatusInProgress());
    favoriteRepository.unFavoriteRestaurant(userId: userId, type: type, restaurantId: restaurant.partnerId!).then((value) {
      emit(UpdateRestaurantFavoriteStatusSuccess(restaurant, false));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException  = e;
      //print("unFavoriteRestaurantError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(UpdateRestaurantFavoriteStatusFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

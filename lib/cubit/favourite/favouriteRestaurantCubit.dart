import 'package:project1/data/repositories/favourite/favouriteRepository.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FavoriteRestaurantsState {}

class FavoriteRestaurantsInitial extends FavoriteRestaurantsState {}

class FavoriteRestaurantsFetchInProgress extends FavoriteRestaurantsState {}

class FavoriteRestaurantsFetchSuccess extends FavoriteRestaurantsState {
  final List<RestaurantModel> favoriteRestaurants;

  FavoriteRestaurantsFetchSuccess(this.favoriteRestaurants);
}

class FavoriteRestaurantsFetchFailure extends FavoriteRestaurantsState {
  final String errorMessage, errorStatusCode;
  FavoriteRestaurantsFetchFailure(this.errorMessage, this.errorStatusCode);
}

class FavoriteRestaurantsCubit extends Cubit<FavoriteRestaurantsState> {
  late FavouriteRepository favoriteRepository;
  FavoriteRestaurantsCubit() : super(FavoriteRestaurantsInitial()) {
    favoriteRepository = FavouriteRepository();
  }

  getFavoriteRestaurants(String? userId, String? type) {
    emit(FavoriteRestaurantsFetchInProgress());

    favoriteRepository.getFavoriteRestaurants(userId, type).then((value) {
      emit(FavoriteRestaurantsFetchSuccess(value));
    }).catchError((e) {
      //print("getFavoriteRestaurantsError:${e.toString()}");
      if (e.toString() == "No Favourite(s) Product or partner Were Added.") {
        emit(FavoriteRestaurantsFetchSuccess([]));
      } else {
        ApiMessageAndCodeException favouriteException  = e;
        emit(FavoriteRestaurantsFetchFailure(favouriteException.errorMessage.toString(), favouriteException.errorStatusCode.toString()));
      }
    });
  }

  void addFavoriteRestaurant(RestaurantModel restaurant) {
    if (state is FavoriteRestaurantsFetchSuccess) {
      final favoriteRestaurants = (state as FavoriteRestaurantsFetchSuccess).favoriteRestaurants;
      favoriteRestaurants.insert(0, restaurant);
      emit(FavoriteRestaurantsFetchSuccess(List.from(favoriteRestaurants)));
    }
  }

  //Can pass only restaurant id here
  void removeFavoriteRestaurant(RestaurantModel restaurant) {
    if (state is FavoriteRestaurantsFetchSuccess) {
      final favoriteRestaurants = (state as FavoriteRestaurantsFetchSuccess).favoriteRestaurants;
      favoriteRestaurants.removeWhere(((element) => element.partnerId == restaurant.partnerId));
      emit(FavoriteRestaurantsFetchSuccess(List.from(favoriteRestaurants)));
    }
  }

  bool isRestaurantFavorite(String restaurantId) {
    if (state is FavoriteRestaurantsFetchSuccess) {
      final favoriteRestaurants = (state as FavoriteRestaurantsFetchSuccess).favoriteRestaurants;
      return favoriteRestaurants.indexWhere((element) => element.partnerId == restaurantId) != -1;
    }
    return false;
  }
}

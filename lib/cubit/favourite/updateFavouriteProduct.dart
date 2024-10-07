import 'package:project1/data/repositories/favourite/favouriteRepository.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateProductFavoriteStatusState {}

class UpdateProductFavoriteStatusInitial extends UpdateProductFavoriteStatusState {}

class UpdateProductFavoriteStatusInProgress extends UpdateProductFavoriteStatusState {}

class UpdateProductFavoriteStatusSuccess extends UpdateProductFavoriteStatusState {
  final ProductDetails product;
  final bool wasFavoriteProductProcess; //to check that process is to favorite the product or not
  UpdateProductFavoriteStatusSuccess(this.product, this.wasFavoriteProductProcess);
}

class UpdateProductFavoriteStatusFailure extends UpdateProductFavoriteStatusState {
  final String errorMessage, errorStatusCode;
  UpdateProductFavoriteStatusFailure(this.errorMessage, this.errorStatusCode);
}

class UpdateProductFavoriteStatusCubit extends Cubit<UpdateProductFavoriteStatusState> {
  late FavouriteRepository favoriteRepository;
  UpdateProductFavoriteStatusCubit() : super(UpdateProductFavoriteStatusInitial()) {
    favoriteRepository = FavouriteRepository();
  }

  void favoriteProduct({required String userId, required String type, required ProductDetails product}) {
    //
    emit(UpdateProductFavoriteStatusInProgress());
    favoriteRepository.favoriteProduct(userId: userId, type: type, productId: product.id!).then((value) {
      emit(UpdateProductFavoriteStatusSuccess(product, true));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException  = e;
      //print("favoriteProductError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(UpdateProductFavoriteStatusFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  //can pass only Product id here
  void unFavoriteProduct({required String userId, required String type, required ProductDetails product}) {
    emit(UpdateProductFavoriteStatusInProgress());
    favoriteRepository.unFavoriteProduct(userId: userId, type: type, productId: product.id!).then((value) {
      emit(UpdateProductFavoriteStatusSuccess(product, false));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException  = e;
      //print("unFavoriteProductError:${apiMessageAndCodeException.apiMessageAndCodeException.errorMessage.toString()}");
      emit(UpdateProductFavoriteStatusFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}

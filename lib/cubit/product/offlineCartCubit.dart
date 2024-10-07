import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/data/repositories/product/productRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//State
@immutable
abstract class OfflineCartState {}

class OfflineCartInitial extends OfflineCartState {}

class OfflineCart extends OfflineCartState {
  //final List<ProductModel> offlineCartList;
  final List<ProductDetails> offlineCartList;

  OfflineCart({required this.offlineCartList});
}

class OfflineCartProgress extends OfflineCartState {}

class OfflineCartSuccess extends OfflineCartState {
  //final ProductModel productModel;
  final List<ProductDetails> productModel;
  OfflineCartSuccess(this.productModel);
}

class OfflineCartFailure extends OfflineCartState {
  final String errorMessage;
  OfflineCartFailure(this.errorMessage);
}

class OfflineCartCubit extends Cubit<OfflineCartState> {
  final ProductRepository _productRepository;
  OfflineCartCubit(this._productRepository) : super(OfflineCartInitial());

  //to getOfflineCartProduct
  getOfflineCart({
    String? latitude,
    String? longitude,
    String? cityId,
    String? productVariantIds,
  }) {
    //emitting OfflineCartProgress state
    emit(OfflineCartProgress());
    //GetOfflineCart Product
    _productRepository
        .getOfflineCartData(latitude, longitude, cityId, productVariantIds)
        .then((value) => emit(OfflineCartSuccess(/* ProductModel(
            error: value.error,
            message: value.message,
            minPrice: value.minPrice,
            maxPrice: value.maxPrice,
            search: value.search,
            filters: value.filters,
            categories: value.categories,
            productTags: value.productTags,
            restaurantTags: value.restaurantTags,
            total: value.total,
            offset: value.offset,
            data: value.data) */value)))
        .catchError((e) {
          //print("offlineCartError:${e.toString()}");
      emit(OfflineCartFailure(e.toString()));
    });
  }

  List<ProductDetails>/* <ProductModel> */ getOfflineCartModel() {
    if (state is OfflineCartSuccess) {
      return (state as OfflineCartSuccess).productModel;
    }
    return []/* ProductModel() */;
  }

  void updateOfflineCartList(List<ProductDetails>/* <ProductModel> */ productModel) {
    emit(OfflineCartSuccess(productModel));
  }

  void updateQuntity(ProductDetails productDetails, String? qty, String? varianceId) {
    print("stateUpdate:$state");
    if (state is OfflineCartSuccess) {
      //
      print("stateUpdate:$state");
      List<ProductDetails> currentProduct = (state as OfflineCartSuccess).productModel;
      // int curntSelectedIndex = currentMyTable.indexWhere((element) => element.cancelShow! == 1);

      int i = currentProduct.indexWhere((element) => (element.id == productDetails.id));
      print("i:$i");
      int j;
      if(i==-1){
        print("lengthbefore:${currentProduct.length}");
        currentProduct.insert(0, productDetails);
        print("lengthafter:${currentProduct.length}");
        int k = currentProduct.indexWhere((element) => (element.id == productDetails.id));
        j = currentProduct[k].variants!.indexWhere((element) => (element.id == varianceId));
        currentProduct[k].variants![j].cartCount=qty;
      }else
      {
        j = currentProduct[i].variants!.indexWhere((element) => (element.id == varianceId));
        currentProduct[i].variants![j].cartCount=qty;
      }
      emit(OfflineCartSuccess(currentProduct));
    }
  }

  void clearOfflineCartModel() {
    if (state is OfflineCartSuccess) {
      emit(OfflineCartInitial());
    }
  }

}

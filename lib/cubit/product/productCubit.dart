import 'package:project1/data/model/productModel.dart';
import 'package:project1/data/repositories/product/productRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//State
@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class Product extends ProductState {
  final List<ProductModel> productList;

  Product({required this.productList});
}

class ProductProgress extends ProductState {
  ProductProgress();
}

class ProductSuccess extends ProductState {
  final ProductModel productModel;
  ProductSuccess(this.productModel);
}

class ProductFailure extends ProductState {
  final String errorMessage;
  ProductFailure(this.errorMessage);
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _productRepository;
  ProductCubit(this._productRepository) : super(ProductInitial());

  //to getProduct
  void getProduct({
    String? partnerId,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
    String? vegetarian,
  }) {
    //emitting ProductProgress state
    emit(ProductProgress());
    //GetProduct also add product details in api
    _productRepository
        .getProductData(partnerId, latitude, longitude, userId, cityId, vegetarian)
        .then((value) => emit(ProductSuccess(value)))
        .catchError((e) {
      //print("productError:${e.toString()}");
      emit(ProductFailure(e.toString()));
    });
  }
}

import 'package:project1/data/model/sectionsModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/repositories/product/productRepository.dart';

@immutable
abstract class ManageOfflineCartState {}

class ManageOfflineCartInitial extends ManageOfflineCartState {}

class ManageOfflineCart extends ManageOfflineCartState {}

class ManageOfflineCartProgress extends ManageOfflineCartState {}

class ManageOfflineCartSuccess extends ManageOfflineCartState {
  final List<ProductDetails> data;
  final String? total;
  ManageOfflineCartSuccess(this.data, this.total);
}

class ManageOfflineCartFailure extends ManageOfflineCartState {
  final String errorMessage;
  ManageOfflineCartFailure(this.errorMessage);
}

class ManageOfflineCartCubit extends Cubit<ManageOfflineCartState> {
  final ProductRepository _productRepository;
  ManageOfflineCartCubit(this._productRepository) : super(ManageOfflineCartInitial());

  //to ManageOfflineCart user
  manageOfflineCartUser({
    String? latitude,
    String? longitude,
    String? cityId,
    String? productVariantIds,
  }) {
    //emitting ManageOfflineCartProgress state
    emit(ManageOfflineCartProgress());
    //ManageOfflineCart
    _productRepository.manageOfflineCartData(latitude, longitude, cityId, productVariantIds).then((result) {
      //success
      print("ManageOfflineCartStateSuccess:${result.data.toString()}=${result.total}");
      emit(ManageOfflineCartSuccess(result.data!, result.total));
    }).catchError((e) {
      //failure
      //print("manageOfflineCartError:${e.toString()}");
      emit(ManageOfflineCartFailure(e.toString()));
    });
  }
}

//ProductLoadCubit

import 'dart:convert';
import 'dart:io';

import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../data/model/sectionsModel.dart';
import '../../utils/api.dart';

@immutable
abstract class ProductLoadCubitState {}

class ProductLoadCubitInitial extends ProductLoadCubitState {}

class ProductLoadCubitProgress extends ProductLoadCubitState {}

class ProductLoadCubitSuccess extends ProductLoadCubitState {
  final List<ProductDetails> productList;
  final int totalData;
  ProductLoadCubitSuccess(this.productList, this.totalData);
}

class ProductLoadCubitFailure extends ProductLoadCubitState {
  final String errorMessage;
  ProductLoadCubitFailure(this.errorMessage);
}

class ProductLoadCubit extends Cubit<ProductLoadCubitState> {
  ProductLoadCubit() : super(ProductLoadCubitInitial());

  void productData(Map bodyparam) {
    emit(ProductLoadCubitProgress());
    pageFetchData(bodyparam).then((value) {
      //
      emit(ProductLoadCubitSuccess(value['list'], value['total']));
    }).catchError((e) {
      emit(ProductLoadCubitFailure(e.toString()));
    });
  }

  void paginateProductData(Map bodyparam) {
    //emit(ProductLoadCubitProgress());
    pageFetchData(bodyparam).then((value) {
      //
      emit(ProductLoadCubitSuccess(value['list'], value['total']));
    }).catchError((e) {
      emit(ProductLoadCubitFailure(e.toString()));
    });
  }

  Future<Map> pageFetchData(Map bodyparam) async {
    Map resresult = {};
    try {
      List<ProductDetails> listmain = [];
      final resultdata = await http.post(Uri.parse(Api.getProductsUrl),
          body: bodyparam, headers: Api.getHeaders());
      print("product-api->${Api.getProductsUrl}");
      print("product-body->$bodyparam");
      final result = jsonDecode(resultdata.body);
      print("product-data->$result");

      if (!result['error']) {
        resresult['total'] = int.parse(result['total'].toString());

        List data = result['data'];
        listmain.addAll(data.map((e) => ProductDetails.fromJson(e)).toList());

        resresult['list'] = listmain;
      }else if(bodyparam[offsetKey]=="0"){
        //print(result['message'].toString());
        throw ApiMessageException(errorMessage: result['message'].toString());
      }
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      print("product-err->${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
    return resresult;
  }

  void updateQuntity(ProductDetails productDetails, String? qty, String? varianceId) {
    print("stateUpdate:$state");
    if (state is ProductLoadCubitSuccess) {
      print("stateUpdate:$state");
      List<ProductDetails> currentProduct = (state as ProductLoadCubitSuccess).productList;
      int totalData = (state as ProductLoadCubitSuccess).totalData;

      int i = currentProduct.indexWhere((element) => (element.id == productDetails.id));
      print("i:$i");
      int j;
      j = currentProduct[i].variants!.indexWhere((element) => (element.id == varianceId));
        currentProduct[i].variants![j].cartCount=qty;
      emit(ProductLoadCubitSuccess(currentProduct, totalData));
    }
  }

  void clearQty(List<ProductDetails>? productDetails) async {
    if (state is ProductLoadCubitSuccess) {
      print("stateUpdate:$state");
      List<ProductDetails> currentProduct = (state as ProductLoadCubitSuccess).productList;
      int totalData = (state as ProductLoadCubitSuccess).totalData;
      for (int i = 0; i < currentProduct.length; i++) {
        for (int j = 0; j < currentProduct[i].variants!.length; j++) {
          //List<ProductDetails>? prList = [];
          currentProduct[i].variants![j].cartCount = "0";
          //prList.add(productDetails[i]);
        }
      }
      emit(ProductLoadCubitSuccess(currentProduct, totalData));
    }
  }
}

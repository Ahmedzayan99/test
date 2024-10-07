//RestaurantCategoryCubit

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../data/model/cuisineModel.dart';
import '../../utils/api.dart';
import '../../utils/string.dart';

abstract class RestaurantCategoryState {}

class CategoryInitial extends RestaurantCategoryState {}

class CategoryFetchProgress extends RestaurantCategoryState {}

class CategoryFetchSuccess extends RestaurantCategoryState {
  List<CuisineModel> categorylist = [];

  CategoryFetchSuccess(this.categorylist);
}

class ChangeSelectedCategory extends RestaurantCategoryState {
  CuisineModel selectedCategory;

  ChangeSelectedCategory(this.selectedCategory);
}

class CategoryFetchFailure extends RestaurantCategoryState {
  final String errmsg;
  CategoryFetchFailure(this.errmsg);
}

class RestaurantCategoryCubit extends Cubit<RestaurantCategoryState> {
  RestaurantCategoryCubit() : super(CategoryInitial());

  fetchCategory(BuildContext context, String restSlug) {
    emit(CategoryFetchProgress());
    fetchCategoryFromDb(context, restSlug)
        .then((value) => emit(CategoryFetchSuccess(value)))
        .catchError((e) => emit(CategoryFetchFailure(e.toString())));
  }

  changeSelectedCategory(CuisineModel category) {
    emit(ChangeSelectedCategory(category));
  }

  Future<List<CuisineModel>> fetchCategoryFromDb(
      BuildContext context, String restSlug) async {
    List<CuisineModel> categorylist = [];
    Map<String, String> body = {"partner_slug": restSlug};

    //print("url->${Api.getCategoriesUrl}");
    final response = await http.post(Uri.parse(Api.getCategoriesUrl),
        body: body, headers: Api.getHeaders());

    var getdata = json.decode(response.body);
    //print("rslug->${getdata['error']}==${getdata["total"]}==${getdata['error'] == false}");
    if (getdata != null && getdata['error'] == false) {
      List list = getdata['data'];
      categorylist.addAll(list.map((e) => CuisineModel.fromJson(e)).toList());
      /* for (var e in list) {
        CuisineModel cuisineModel = CuisineModel.fromJson(e);
        print("url=res->${cuisineModel.id}==${cuisineModel.total}");
        categorylist.add(cuisineModel);
      } */
    } else {
      throw ApiMessageException(errorMessage: StringsRes.noDataFound);
    }

    return categorylist;
  }
}

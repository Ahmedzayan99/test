import 'dart:ui';

import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteProduct.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductContainer extends StatelessWidget {
  final ProductDetails productDetails;
  final List<ProductDetails>? productDetailsList;
  final double? width, height, price, off;
  final String? from, axis;
  const ProductContainer(
      {Key? key,
      required this.productDetails,
      this.width,
      this.height,
      this.price,
      this.off,
      this.productDetailsList,
      this.from,
      this.axis})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateProductFavoriteStatusCubit>(
      create: (context) => UpdateProductFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsetsDirectional.only(
              start: width! / 20.0, top: height! / 99.0),
          child: Stack(
            textDirection: Directionality.of(context),
            children: [
              Container(
                alignment: Alignment.center,
                width: productDetailsList!.length != 1 && axis == "horizontal"
                    ? width! / 2.5
                    : width! / 1.1,
                height: height! / 4,
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      child: ColorFiltered(
                        colorFilter:
                            productDetails.partnerDetails![0].isRestroOpen ==
                                    "1"
                                ? const ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.multiply,
                                  )
                                : const ColorFilter.mode(
                                    Colors.grey,
                                    BlendMode.saturation,
                                  ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [shaderColor, black],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.darken,
                          child: DesignConfig.imageWidgets(
                              productDetails.image!,
                              height! / 4,
                              productDetailsList!.length != 1 &&
                                      axis == "horizontal"
                                  ? width! / 2.5
                                  : width! / 1.1,
                              "2"),
                        ),
                      ),
                    ),
                    double.parse(productDetails.rating!)
                                .toStringAsFixed(1)
                                .toString() ==
                            "0.0"
                        ? const SizedBox()
                        : Positioned.directional(
                            textDirection: Directionality.of(context),
                            start: 5.0,
                            top: 5.0,
                            //right: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  padding: const EdgeInsets.all(2.5),
                                  width: 42,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      color: const Color(0xff000000)
                                          .withOpacity(0.50)),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          DesignConfig.setSvgPath("rating"),
                                          fit: BoxFit.scaleDown,
                                          width: 7.0,
                                          height: 12.3),
                                      const SizedBox(width: 3.4),
                                      Text(
                                        double.parse(productDetails.rating!)
                                            .toStringAsFixed(1),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      start: 8.0,
                      bottom: 8.0,
                      end: 5,
                      //right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          off!.toStringAsFixed(2) == "0.00"
                              ? const SizedBox()
                              : Text(
                                  "${off!.toStringAsFixed(2).replaceAll(regex, '')}${StringsRes.percentSymbol}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                          Text(
                            productDetails.name!,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: white,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 7.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(DesignConfig.setSvgPath("time"),
                                  fit: BoxFit.scaleDown,
                                  width: 7.0,
                                  height: 12.3),
                              const SizedBox(width: 5.0),
                              Text(
                                productDetails
                                    .partnerDetails![0].partnerCookTime!
                                    .toString()
                                    .replaceAll(regex, ''),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.72),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    from == "home"
                        ? const SizedBox()
                        : Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 5,
                            top: 5,
                            child: BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                              return BlocBuilder<FavoriteProductsCubit,
                                      FavoriteProductsState>(
                                  bloc: context.read<FavoriteProductsCubit>(),
                                  builder: (context, favoriteProductState) {
                                    if (favoriteProductState
                                        is FavoriteProductsFetchSuccess) {
                                      //check if restaurant is favorite or not
                                      bool isProductFavorite = context
                                          .read<FavoriteProductsCubit>()
                                          .isProductFavorite(
                                              productDetails.id!);
                                      return BlocConsumer<
                                          UpdateProductFavoriteStatusCubit,
                                          UpdateProductFavoriteStatusState>(
                                        bloc: context.read<
                                            UpdateProductFavoriteStatusCubit>(),
                                        listener: ((context, state) {
                                          //
                                          if (state
                                              is UpdateProductFavoriteStatusFailure) {
                                            if (state.errorStatusCode
                                                    .toString() ==
                                                "102") {
                                              reLogin(context);
                                            }
                                          }
                                          if (state
                                              is UpdateProductFavoriteStatusSuccess) {
                                            //
                                            if (state
                                                .wasFavoriteProductProcess) {
                                              context
                                                  .read<FavoriteProductsCubit>()
                                                  .addFavoriteProduct(
                                                      state.product);
                                            } else {
                                              //
                                              context
                                                  .read<FavoriteProductsCubit>()
                                                  .removeFavoriteProduct(
                                                      state.product);
                                            }
                                          }
                                        }),
                                        builder: (context, state) {
                                          if (state
                                              is UpdateProductFavoriteStatusInProgress) {
                                            return SizedBox(
                                              width: 30.0,
                                              height: 30,
                                              child: ClipOval(
                                                //borderRadius: BorderRadius.circular(10.0),
                                                child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 15, sigmaY: 15),
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.5),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          color: Theme.of(context).colorScheme.onSurface
                                                              .withOpacity(
                                                                  0.60),
                                                        ),
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Theme.of(context).colorScheme.primary))),
                                              ),
                                            );
                                          }
                                          return InkWell(
                                              onTap: () {
                                                //
                                                if (state is UpdateProductFavoriteStatusFailure) {
                                                    if(state.errorMessage.toString() == "102"){
                                                      reLogin(context);
                                                    }
                                                }
                                                if (state
                                                    is UpdateProductFavoriteStatusInProgress) {
                                                  return;
                                                }
                                                if (isProductFavorite) {
                                                  context
                                                      .read<
                                                          UpdateProductFavoriteStatusCubit>()
                                                      .unFavoriteProduct(
                                                          userId: context
                                                              .read<AuthCubit>()
                                                              .getId(),
                                                          type: productsKey,
                                                          product:
                                                              productDetails);
                                                } else {
                                                  //
                                                  context
                                                      .read<
                                                          UpdateProductFavoriteStatusCubit>()
                                                      .favoriteProduct(
                                                          userId: context
                                                              .read<AuthCubit>()
                                                              .getId(),
                                                          type: productsKey,
                                                          product:
                                                              productDetails);
                                                }
                                              },
                                              child: isProductFavorite
                                                  ? ClipOval(
                                                      //borderRadius: BorderRadius.circular(10.0),
                                                      child: BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                                  sigmaX: 15,
                                                                  sigmaY: 15),
                                                          child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Theme.of(context).colorScheme.onSurface
                                                                    .withOpacity(
                                                                        0.60),
                                                              ),
                                                              child: SvgPicture.asset(
                                                                  DesignConfig
                                                                      .setSvgPath(
                                                                          "wishlist-filled"),
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  width: 18.0,
                                                                  height:
                                                                      18.3))))
                                                  : ClipOval(
                                                      //borderRadius: BorderRadius.circular(10.0),
                                                      child: BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                                  sigmaX: 15,
                                                                  sigmaY: 15),
                                                          child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Theme.of(context).colorScheme.onSurface
                                                                    .withOpacity(
                                                                        0.60),
                                                              ),
                                                              child: SvgPicture.asset(
                                                                  DesignConfig
                                                                      .setSvgPath(
                                                                          "wishlist1"),
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  width: 18.0,
                                                                  height:
                                                                      18.3))),
                                                    ));
                                        },
                                      );
                                    }
                                    //if some how failed to fetch favorite products or still fetching the products
                                    return InkWell(
                                        onTap: () {
                                          //
                                          if (favoriteProductState
                                              is FavoriteProductsFetchFailure) {
                                            if (favoriteProductState
                                                    .errorStatusCode
                                                    .toString() ==
                                                "102") {
                                              reLogin(context);
                                            }
                                          }
                                          if (context.read<AuthCubit>().state
                                                  is AuthInitial ||
                                              context.read<AuthCubit>().state
                                                  is Unauthenticated) {
                                            Navigator.of(context).pushNamed(
                                                Routes.login,
                                                arguments: {
                                                  'from': 'product'
                                                }).then((value) {
                                              appDataRefresh(context);
                                            });
                                            return;
                                          }
                                        },
                                        child: ClipOval(
                                          //borderRadius: BorderRadius.circular(10.0),
                                          child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 15, sigmaY: 15),
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.all(3.5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Theme.of(context).colorScheme.onSurface
                                                        .withOpacity(0.60),
                                                  ),
                                                  child: SvgPicture.asset(
                                                      DesignConfig.setSvgPath(
                                                          "wishlist1"),
                                                      fit: BoxFit.scaleDown,
                                                      width: 18.0,
                                                      height: 18.3))),
                                        ));
                                  });
                            }),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

import 'dart:ui';

import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteRestaurant.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/apiBodyParameterLabels.dart';

class RestaurantContainer extends StatelessWidget {
  final RestaurantModel restaurant;
  final double? width, height;

  const RestaurantContainer(
      {Key? key, required this.restaurant, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
      create: (context) => UpdateRestaurantFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return InkWell(
          onTap: () {
            /*  Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => RestaurantDetailScreen(
                  restaurant: restaurant,
                ),
              ),
            );*/
            Navigator.of(context).pushNamed(Routes.restaurantDetail,
                arguments: {'restaurant': restaurant});
          },
          child: Container(
              padding: EdgeInsetsDirectional.only(
                  top: height! / 99.0, end: width! / 40.0),
              //height: height!/4.7,
              width: width!,
              margin: EdgeInsetsDirectional.only(
                  top: height! / 52.0,
                  start: width! / 24.0,
                  end: width! / 24.0),
              //decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: ColorFiltered(
                              colorFilter: restaurant.isRestroOpen == "1"
                                  ? const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.multiply,
                                    )
                                  : const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    ),
                              child: DesignConfig.imageWidgets(
                                  restaurant.partnerProfile!,
                                  height! / 8.0,
                                  width!,
                                  "2"),
                            )),
                        Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 0.0,
                            top: 0.0,
                            //right: 0,
                            child: BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                              return BlocBuilder<FavoriteRestaurantsCubit,
                                      FavoriteRestaurantsState>(
                                  bloc:
                                      context.read<FavoriteRestaurantsCubit>(),
                                  builder: (context, favoriteRestaurantState) {
                                    if (favoriteRestaurantState
                                        is FavoriteRestaurantsFetchSuccess) {
                                      //check if restaurant is favorite or not
                                      bool isRestaurantFavorite = context
                                          .read<FavoriteRestaurantsCubit>()
                                          .isRestaurantFavorite(
                                              restaurant.partnerId!);
                                      return BlocConsumer<
                                          UpdateRestaurantFavoriteStatusCubit,
                                          UpdateRestaurantFavoriteStatusState>(
                                        bloc: context.read<
                                            UpdateRestaurantFavoriteStatusCubit>(),
                                        listener: ((context, state) {
                                          //
                                          if (state
                                              is UpdateRestaurantFavoriteStatusFailure) {
                                            if (state.errorStatusCode
                                                    .toString() ==
                                                "102") {
                                              reLogin(context);
                                            }
                                          }
                                          if (state
                                              is UpdateRestaurantFavoriteStatusSuccess) {
                                            //
                                            if (state
                                                .wasFavoriteRestaurantProcess) {
                                              context
                                                  .read<
                                                      FavoriteRestaurantsCubit>()
                                                  .addFavoriteRestaurant(
                                                      state.restaurant);
                                            } else {
                                              //
                                              context
                                                  .read<
                                                      FavoriteRestaurantsCubit>()
                                                  .removeFavoriteRestaurant(
                                                      state.restaurant);
                                            }
                                          }
                                        }),
                                        builder: (context, state) {
                                          if (state
                                              is UpdateRestaurantFavoriteStatusInProgress) {
                                            return Container(
                                              width: 30.0,
                                              height: 30,
                                              margin:
                                                  const EdgeInsetsDirectional
                                                      .only(end: 5.0, top: 5),
                                              child: ClipOval(
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
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(
                                                                      0.60),
                                                        ),
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary))),
                                              ),
                                            );
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                                onTap: () {
                                                  //
                                                  if (state
                                                      is UpdateRestaurantFavoriteStatusFailure) {
                                                    if (state.errorMessage
                                                            .toString() ==
                                                        "102") {
                                                      reLogin(context);
                                                    }
                                                  }
                                                  print(favoriteRestaurantState
                                                      .toString());
                                                  if (state
                                                      is UpdateRestaurantFavoriteStatusInProgress) {
                                                    return;
                                                  }
                                                  if (isRestaurantFavorite) {
                                                    context
                                                        .read<
                                                            UpdateRestaurantFavoriteStatusCubit>()
                                                        .unFavoriteRestaurant(
                                                            userId: context
                                                                .read<
                                                                    AuthCubit>()
                                                                .getId(),
                                                            type: partnersKey,
                                                            restaurant:
                                                                restaurant);
                                                  } else {
                                                    //
                                                    context
                                                        .read<
                                                            UpdateRestaurantFavoriteStatusCubit>()
                                                        .favoriteRestaurant(
                                                            userId: context
                                                                .read<
                                                                    AuthCubit>()
                                                                .getId(),
                                                            type: partnersKey,
                                                            restaurant:
                                                                restaurant);
                                                  }
                                                },
                                                child: isRestaurantFavorite
                                                    ? ClipOval(
                                                        //borderRadius: BorderRadius.circular(10.0),
                                                        child: BackdropFilter(
                                                            filter:
                                                                ImageFilter
                                                                    .blur(
                                                                        sigmaX:
                                                                            15,
                                                                        sigmaY:
                                                                            15),
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        3.5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface
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
                                                                        18.3))),
                                                      ) //const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                    : ClipOval(
                                                        //borderRadius: BorderRadius.circular(10.0),
                                                        child: BackdropFilter(
                                                            filter:
                                                                ImageFilter
                                                                    .blur(
                                                                        sigmaX:
                                                                            15,
                                                                        sigmaY:
                                                                            15),
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        3.5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface
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
                                                      ) //const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)
                                                /*? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                      : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)*/
                                                ),
                                          );
                                        },
                                      );
                                    }
                                    //if some how failed to fetch favorite restaurants or still fetching the restaurants
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                          onTap: () {
                                            if (favoriteRestaurantState
                                                is FavoriteRestaurantsFetchFailure) {
                                              if (favoriteRestaurantState
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
                                                    'from':
                                                        'restaurantFavourite'
                                                  }).then((value) {
                                                appDataRefresh(context);
                                              });
                                              return;
                                            }
                                          },
                                          child: ClipOval(
                                            child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 15, sigmaY: 15),
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.5),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.60),
                                                    ),
                                                    child: SvgPicture.asset(
                                                        DesignConfig.setSvgPath(
                                                            "wishlist1"),
                                                        fit: BoxFit.scaleDown,
                                                        width: 18.0,
                                                        height: 18.3))),
                                          ) //const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)
                                          /*? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                      : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)*/
                                          ),
                                    );
                                  });
                            })),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: width! / 30.0,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(restaurant.partnerName!,
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      SizedBox(width: width! / 50.0),
                                      /* restaurant.partnerIndicator == "1"
                                      ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                      : restaurant.partnerIndicator == "2"
                                          ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                          : Row(
                                              children: [
                                                SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15),
                                                const SizedBox(width: 2.0),
                                                SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15),
                                              ],
                                            ), */
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            restaurant.tags!.isNotEmpty
                                ? Text(restaurant.tags!.join(', '),
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: greayLightColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        overflow: TextOverflow.ellipsis),
                                    maxLines: 1)
                                : const SizedBox(),
                            const SizedBox(height: 2.0),
                            Text(
                              "${context.read<SystemConfigCubit>().getCurrency()}${restaurant.priceForOne!} ${UiUtils.getTranslatedLabel(context, forOneLabel)}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  overflow: TextOverflow.ellipsis),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 2.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                double.parse(restaurant.partnerRating!)
                                            .toStringAsFixed(1) ==
                                        "0.0"
                                    ? const SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                              DesignConfig.setSvgPath("rating"),
                                              fit: BoxFit.scaleDown,
                                              width: 7.0,
                                              height: 12.3),
                                          const SizedBox(width: 5.0),
                                          Text(
                                              double.parse(
                                                      restaurant.partnerRating!)
                                                  .toStringAsFixed(1),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        ],
                                      ),
                                double.parse(restaurant.partnerRating!)
                                            .toStringAsFixed(1) ==
                                        "0.0"
                                    ? const SizedBox()
                                    : SizedBox(width: width! / 60.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                        DesignConfig.setSvgPath("time_filled"),
                                        fit: BoxFit.scaleDown,
                                        width: 7.0,
                                        height: 12.3),
                                    const SizedBox(width: 5.0),
                                    Text(
                                      restaurant.partnerCookTime!
                                          .toString()
                                          .replaceAll(regex, ''),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ],
              )),
        );
      }),
    );
  }
}

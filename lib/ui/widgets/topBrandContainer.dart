import 'dart:ui';

import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteRestaurant.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBrandContainer extends StatelessWidget {
  final List<RestaurantModel> topRestaurantList;
  final double? width, height;
  final int index;
  final String? from;
  const TopBrandContainer(
      {Key? key,
      required this.topRestaurantList,
      this.width,
      this.height,
      required this.index,
      required this.from})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
      create: (context) => UpdateRestaurantFavoriteStatusCubit(),
      child: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsetsDirectional.only(start: width!/30, top: 8.0, bottom: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        child: ColorFiltered(
                          colorFilter: topRestaurantList[index].isRestroOpen == "1"
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
                      child: DesignConfig.imageWidgets(topRestaurantList[index].partnerProfile!, height! / 4.2, from == "home" ? width! / 1.1 : width,"2"),
                    ),
                  ),
                ),
                Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: 0.0,
                    top: 0.0,
                    //right: 0,
                    child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                      return BlocBuilder<FavoriteRestaurantsCubit,
                              FavoriteRestaurantsState>(
                          bloc: context.read<FavoriteRestaurantsCubit>(),
                          builder: (context, favoriteRestaurantState) {
                            if (favoriteRestaurantState
                                is FavoriteRestaurantsFetchSuccess) {
                              //check if restaurant is favorite or not
                              bool isRestaurantFavorite = context
                                  .read<FavoriteRestaurantsCubit>()
                                  .isRestaurantFavorite(
                                      topRestaurantList[index].partnerId!);
                              return BlocConsumer<
                                  UpdateRestaurantFavoriteStatusCubit,
                                  UpdateRestaurantFavoriteStatusState>(
                                bloc: context
                                    .read<UpdateRestaurantFavoriteStatusCubit>(),
                                listener: ((context, state) {
                                  //
                                  if (state
                                      is UpdateRestaurantFavoriteStatusFailure) {
                                    if (state.errorStatusCode.toString() == "102") {
                                      reLogin(context);
                                    }
                                  }
                                  if (state
                                      is UpdateRestaurantFavoriteStatusSuccess) {
                                    //
                                    if (state.wasFavoriteRestaurantProcess) {
                                      context
                                          .read<FavoriteRestaurantsCubit>()
                                          .addFavoriteRestaurant(state.restaurant);
                                    } else {
                                      //
                                      context
                                          .read<FavoriteRestaurantsCubit>()
                                          .removeFavoriteRestaurant(
                                              state.restaurant);
                                    }
                                  }
                                }),
                                builder: (context, state) {
                                  if (state
                                      is UpdateRestaurantFavoriteStatusInProgress) {
                                    return Container(width: 30.0, height: 30, margin: const EdgeInsetsDirectional.only(end: 10.0, top: 10),
                                      child: ClipOval(
                                          //borderRadius: BorderRadius.circular(10.0),
                                          child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 15, sigmaY: 15),
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.all(3.5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(10.0),
                                                    color: Theme.of(context).colorScheme.onSurface
                                                        .withOpacity(0.60),
                                                  ),
                                                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)))),
                                    ); /* Container(
                                                        margin: const EdgeInsetsDirectional.only(end: 10.0),
                                                        height: 15,
                                                        width: 15,
                                                        child: const CircularProgressIndicator(color: ColorsRes.red)) */
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                        onTap: () {
                                          //
                                          if (state is UpdateRestaurantFavoriteStatusFailure) {
                                            if(state.errorMessage.toString() == "102"){
                                              reLogin(context);
                                            }
                                          }
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
                                                        .read<AuthCubit>()
                                                        .getId(),
                                                    type: partnersKey,
                                                    restaurant:
                                                        topRestaurantList[index]);
                                          } else {
                                            //
                                            context
                                                .read<
                                                    UpdateRestaurantFavoriteStatusCubit>()
                                                .favoriteRestaurant(
                                                    userId: context
                                                        .read<AuthCubit>()
                                                        .getId(),
                                                    type: partnersKey,
                                                    restaurant:
                                                        topRestaurantList[index]);
                                          }
                                        },
                                        child: isRestaurantFavorite
                                            ? ClipOval(
                                                //borderRadius: BorderRadius.circular(10.0),
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
                                                          color: Theme.of(context).colorScheme.onSurface
                                                              .withOpacity(0.60),
                                                        ),
                                                        child: SvgPicture.asset(
                                                            DesignConfig.setSvgPath(
                                                                "wishlist-filled"),
                                                            fit: BoxFit.scaleDown,
                                                            width: 18.0,
                                                            height: 18.3))),
                                              ) //const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                            : ClipOval(
                                                //borderRadius: BorderRadius.circular(10.0),
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
                                                          color: Theme.of(context).colorScheme.onSurface
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
                                },
                              );
                            }
                            //if some how failed to fetch favorite restaurants or still fetching the restaurants
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    if(favoriteRestaurantState is FavoriteRestaurantsFetchFailure){
                                              if(favoriteRestaurantState.errorStatusCode.toString() == "102"){
                                                reLogin(context);
                                              }
                                            }
                                    if (context.read<AuthCubit>().state
                                            is AuthInitial ||
                                        context.read<AuthCubit>().state
                                            is Unauthenticated) {
                                      Navigator.of(context).pushNamed(Routes.login,
                                          arguments: {
                                            'from': 'restaurantFavourite'
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
                                              padding: const EdgeInsets.all(3.5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color: Theme.of(context).colorScheme.onSurface
                                                    .withOpacity(0.60),
                                              ),
                                              child: SvgPicture.asset(
                                                  DesignConfig.setSvgPath(
                                                      "wishlist1"),
                                                  fit: BoxFit.scaleDown,
                                                  width: 18.0,
                                                  height: 18.3)))
                                      //const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)
                                      /*? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                              : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)*/
                                      ),
                                ));
                          });
                    })),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 5.0,
                  top: 5.0,
                  //right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        width: 42,
                        height: 20,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            color: const Color(0xff000000).withOpacity(0.50)),
                        child: Row(
                          children: [
                            SvgPicture.asset(DesignConfig.setSvgPath("rating"),
                                fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                            const SizedBox(width: 3.4),
                            Text(
                              double.parse(topRestaurantList[index].partnerRating!)
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
                  //right: 0,
                  child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        child: ColorFiltered(
                          colorFilter: topRestaurantList[index].isRestroOpen == "1"
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                )
                              : const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                          child: DesignConfig.imageWidgets(topRestaurantList[index].partnerProfile!, 50.0, 50.0,"2"),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Column(mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${topRestaurantList[index].partnerName}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.72),
                          ),
                          const SizedBox(height: 2.0),
                          topRestaurantList[index].tags!.isNotEmpty
                              ? SizedBox(width: width!/1.5,
                                child: Text(
                                    topRestaurantList[index].tags!.join(', '),
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: white/* .withOpacity(0.30) */,
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        overflow: TextOverflow.ellipsis),
                                    maxLines: 1,
                                  ),
                              )
                              : const SizedBox(),
                          const SizedBox(height: 3.0),
                          Row(mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              
                              Text("${context.read<SystemConfigCubit>().getCurrency()}${
                                topRestaurantList[index]
                                    .priceForOne!} ${UiUtils.getTranslatedLabel(context, forOneLabel)} | ",
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.72),
                              ),
                              SvgPicture.asset(DesignConfig.setSvgPath("time"),
                                  fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                              const SizedBox(width: 5.0),
                              Text(
                                topRestaurantList[index]
                                    .partnerCookTime!
                                    .toString()
                                    .replaceAll(regex, ''),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.72),
                              ),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }
}

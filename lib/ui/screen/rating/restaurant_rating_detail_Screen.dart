import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/rating/deleteRatingCubit.dart';
import 'package:project1/cubit/rating/getRestaurantRatingCubit.dart';
import 'package:project1/data/repositories/rating/ratingRepository.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project1/ui/widgets/smallButtomContainer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'package:project1/utils/internetConnectivity.dart';

class RestaurantRatingDetailScreen extends StatefulWidget {
  final String? partnerId;
  const RestaurantRatingDetailScreen({Key? key, this.partnerId}) : super(key: key);

  @override
  RestaurantRatingDetailScreenState createState() => RestaurantRatingDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => /* BlocProvider<GetRestaurantRatingCubit>(
              create: (_) => GetRestaurantRatingCubit(),
              child: RestaurantRatingDetailScreen(partnerId: arguments['partnerId']),
            ) */MultiBlocProvider(providers: [
        BlocProvider<GetRestaurantRatingCubit>(
              create: (_) => GetRestaurantRatingCubit(),
              child: RestaurantRatingDetailScreen(partnerId: arguments['partnerId']),
            ),
        BlocProvider<DeleteRatingCubit>(
              create: (_) => DeleteRatingCubit(RatingRepository()),
              child: RestaurantRatingDetailScreen(partnerId: arguments['partnerId']),
            )
      ], child: RestaurantRatingDetailScreen(partnerId: arguments['partnerId'])));
  }
}

class RestaurantRatingDetailScreenState extends State<RestaurantRatingDetailScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? cuisineLength = "";
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  @override
  void initState() {
    //print(widget.categoryId);
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<GetRestaurantRatingCubit>().fetchGetRestaurantRating(perPage, widget.partnerId!);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<GetRestaurantRatingCubit>().hasMoreData()) {
        context.read<GetRestaurantRatingCubit>().fetchMoreGetRestaurantRatingData(perPage, widget.partnerId!);
      }
    }
  }

  Widget getRestaurantRating() {
    return BlocConsumer<GetRestaurantRatingCubit, GetRestaurantRatingState>(
        bloc: context.read<GetRestaurantRatingCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetRestaurantRatingProgress || state is GetRestaurantRatingInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is GetRestaurantRatingFailure) {
            return Container(alignment: Alignment.center,height: height!,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                //SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noReviewFoundLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noReviewSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            );
          }
          final restaurantRatingList = (state as GetRestaurantRatingSuccess).restaurantRatingList;
          //print("restaurantRatingList:$restaurantRatingList");
          final hasMore = state.hasMore;
          return restaurantRatingList.isEmpty?Container(alignment: Alignment.center,height: height!,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                //SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noReviewFoundLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noReviewSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            ):ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: restaurantRatingList.length,padding: EdgeInsetsDirectional.zero,
                  itemBuilder: (BuildContext context, index) {
                    print(restaurantRatingList[index].images!.length);
                    var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                    
                    var inputDate = inputFormat.parse(restaurantRatingList[index].dataAdded!.toString());

                    // outputFormat - convert into format you want to show.
                    var outputFormat = DateFormat('dd/MM/yyyy');
                    var outputDate = outputFormat.format(inputDate);
                    return hasMore && restaurantRatingList.isEmpty && index == (restaurantRatingList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Container(
                            padding:
                                EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
                            //height: height!/4.7,
                            width: width!,
                            margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
                            decoration:
                                DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                            child: DesignConfig.imageWidgets(restaurantRatingList[index].userProfile!, 35.0, 35.0,"2")),
                                            const SizedBox(width: 10.0),
                                            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children:[
                                              Text(restaurantRatingList[index].userName!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                                  Text(outputDate,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                overflow: TextOverflow.ellipsis),
                                            maxLines: 1),]),
                                            const Spacer(),
                                            //SizedBox(width: width! / 99.0),
                                                Container(
                                                    padding: const EdgeInsetsDirectional.only(top: 2, bottom: 2, start: 4.5, end: 4.5),
                                                    decoration: DesignConfig.boxDecorationContainerBorder(yellowColor, yellowColor.withOpacity(0.10), 5),
                                                    margin: EdgeInsetsDirectional.only(start: width! / 20.0),
                                                    child: Row(
                                                      children: [
                                                        RatingBar.builder(itemSize: 10.9,
                                                        glowColor: Theme.of(context).colorScheme.onSurface,
                                                        initialRating: double.parse(restaurantRatingList[index].rating!),
                                                        minRating: 1,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        itemPadding: const EdgeInsetsDirectional.only(end: 2.0),
                                                        itemBuilder: (context, _) => const Icon(
                                                          Icons.star,
                                                          color: yellowColor,
                                                        ),
                                                        onRatingUpdate: (ratings) {
                                                          print(ratings);
                                                        },
                                                      ),
                                                      Text(" | ${restaurantRatingList[index].rating!}",
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(
                                                                color: greayLightColor, fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal)),
                                                      ],
                                                    ))
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            top: 4.5,
                                            bottom: 4.5,
                                          ),
                                          child: Divider(
                                            color: lightFont.withOpacity(0.50),
                                            height: 1.0,
                                          ),
                                        ),
                                        SizedBox(height: height!/80.0),
                                        restaurantRatingList[index].comment!.isNotEmpty?Text(restaurantRatingList[index].comment!,
                                            textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal,
                                                    fontStyle: FontStyle.normal,
                                                overflow: TextOverflow.ellipsis),
                                            maxLines: 1) : const SizedBox(),
                                        const SizedBox(height: 2.0),
                                            restaurantRatingList[index].images!.isEmpty?const SizedBox():Container(height: 80.0, alignment: Alignment.topLeft,
                                              margin: EdgeInsetsDirectional.only(top: height!/80.0),
                                              child: ListView.builder(
                                                shrinkWrap: true,physics: const AlwaysScrollableScrollPhysics(),
                                                itemCount: restaurantRatingList[index].images!.length,
                                                scrollDirection: Axis.horizontal,
                                                itemBuilder: (context, i) {
                                                  return Padding(
                                                    padding: const EdgeInsetsDirectional.only(end: 10.0),
                                                    child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: DesignConfig.imageWidgets(restaurantRatingList[index].images![i], 80, 80,"2")),
                                                  );
                                                })
                                              ),
                                              
                                              context.read<AuthCubit>().getId()==restaurantRatingList[index].userId!?Row(mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  /* SmallButtonContainer(color: white, height: height, width: width, text: StringsRes.edit, start: 0, end: 0, bottom: height!/80.0, top: height!/99.0, radius: 5.0, status: false,borderColor: white, textColor: Theme.of(context).colorScheme.onSecondary, onTap: (){
                                                            
                                                  },), */
                                                  BlocConsumer<DeleteRatingCubit, DeleteRatingState>(
                                                  bloc: context.read<DeleteRatingCubit>(),
                                                  listener: (context, state) {
                                                    if (state is DeleteRatingSuccess) {
                                                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, ratingLabel), StringsRes.deleteSuccessFully, context, false, type: "1");
                                                    }
                                                  },
                                                  builder: (context, state) {
                                                    return SmallButtonContainer(color: Theme.of(context).colorScheme.error, height: height, width: width, text: UiUtils.getTranslatedLabel(context, deleteLabel), start: 0, end: width! / 99.0, bottom: height!/80.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.error, textColor: white, onTap: (){
                                                              context.read<DeleteRatingCubit>().deleteOrderRating(restaurantRatingList[index].id!);  
                                                              restaurantRatingList.removeWhere((element) => element.id==restaurantRatingList[index].id);
                                                      },);
                                                    }
                                                  )
                                                ]): const SizedBox(),
                                      ]),
                                ),
                              ],
                            ));
                  });
        });
  }

  Future<void> refreshList() async {
    context.read<GetRestaurantRatingCubit>().fetchGetRestaurantRating(
          perPage,
          widget.partnerId!,
        );
  }

  @override
  void dispose() {
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
              appBar: DesignConfig.appBar(context, width, UiUtils.getTranslatedLabel(context, reviewsLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: Container(height: height!,  
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                width: width,
                child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(),child: getRestaurantRating())),
              ),
            ),
    );
  }
}

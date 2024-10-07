import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/rating/deleteRatingCubit.dart';
import 'package:project1/cubit/rating/getProductRatingCubit.dart';
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

class ProductRatingDetailScreen extends StatefulWidget {
  final String? productId;
  const ProductRatingDetailScreen({Key? key, this.productId}) : super(key: key);

  @override
  ProductRatingDetailScreenState createState() => ProductRatingDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
        BlocProvider<GetProductRatingCubit>(
              create: (_) => GetProductRatingCubit(),
              child: ProductRatingDetailScreen(productId: arguments['productId']),
            ),
        BlocProvider<DeleteRatingCubit>(
              create: (_) => DeleteRatingCubit(RatingRepository()),
              child: ProductRatingDetailScreen(productId: arguments['productId']),
            )
      ], child: ProductRatingDetailScreen(productId: arguments['productId'])));
  }
}

class ProductRatingDetailScreenState extends State<ProductRatingDetailScreen> {
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
      context.read<GetProductRatingCubit>().fetchGetProductRating(perPage, widget.productId!);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<GetProductRatingCubit>().hasMoreData()) {
        context.read<GetProductRatingCubit>().fetchMoreGetProductRatingData(perPage, widget.productId!);
      }
    }
  }

  Widget getProductRating() {
    return BlocConsumer<GetProductRatingCubit, GetProductRatingState>(
        bloc: context.read<GetProductRatingCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetProductRatingProgress || state is GetProductRatingInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is GetProductRatingFailure) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
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
          final productRatingList = (state as GetProductRatingSuccess).productRatingList;
          final hasMore = state.hasMore;
          return productRatingList.isEmpty?Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noReviewFoundLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noReviewSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            ):SizedBox(
              height: height! / 1.2,
              /* color: white,*/
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: productRatingList.length,padding: EdgeInsetsDirectional.zero,
                  itemBuilder: (BuildContext context, index) {
                    print(productRatingList[index].images!.length);
                    var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                    var inputDate = inputFormat.parse(productRatingList[index].dataAdded!.toString());

                    // outputFormat - convert into format you want to show.
                    var outputFormat = DateFormat('dd/MM/yyyy');
                    var outputDate = outputFormat.format(inputDate);
                    return hasMore && productRatingList.isEmpty && index == (productRatingList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Container(
                            padding:
                                EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
                            //height: height!/4.7,
                            width: width!,
                            margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
                            decoration:
                                DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                              child: Column(mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        child: DesignConfig.imageWidgets(productRatingList[index].userProfile!, 35.0, 35.0,"2")),
                                        const SizedBox(width: 10.0),
                                        Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children:[
                                          Text(productRatingList[index].userName!,
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
                                                    initialRating: double.parse(productRatingList[index].rating!),
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,ignoreGestures: true,
                                                    itemPadding: const EdgeInsetsDirectional.only(end: 2.0),
                                                    itemBuilder: (context, _) => const Icon(
                                                      Icons.star,
                                                      color: yellowColor,
                                                    ),
                                                    onRatingUpdate: (ratings) {
                                                      print(ratings);
                                                    },
                                                  ),
                                                  Text(" | ${productRatingList[index].rating!}",
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
                                    productRatingList[index].comment!.isNotEmpty?Text(productRatingList[index].comment!,
                                        textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FontStyle.normal,
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: 1) : const SizedBox(),
                                    const SizedBox(height: 2.0),
                                        productRatingList[index].images!.isEmpty?const SizedBox():Container(height: 80.0, alignment: Alignment.topLeft,
                                          margin: EdgeInsetsDirectional.only(top: height!/80.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,physics: const AlwaysScrollableScrollPhysics(),
                                            itemCount: productRatingList[index].images!.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, i) {
                                              return Padding(
                                                padding: const EdgeInsetsDirectional.only(end: 10.0),
                                                child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: DesignConfig.imageWidgets(productRatingList[index].images![i], 80, 80,"2")),
                                              );
                                            })
                                          ),
                                          
                                          context.read<AuthCubit>().getId()==productRatingList[index].userId!?Row(mainAxisAlignment: MainAxisAlignment.end,
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
                                                return SmallButtonContainer(color: Theme.of(context).colorScheme.primary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, deleteLabel), start: 0, end: width! / 99.0, bottom: height!/80.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.primary, textColor: white, onTap: (){
                                                          context.read<DeleteRatingCubit>().deleteProductRating(productRatingList[index].id!);
                                                          productRatingList.removeWhere((element) => element.id==productRatingList[index].id!);  
                                                  },);
                                                }
                                              )
                                            ]): const SizedBox(),
                                  ]),
                            ));
                  }));
        });
  }

  Future<void> refreshList() async {
    context.read<GetProductRatingCubit>().fetchGetProductRating(
          perPage,
          widget.productId!,
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
              body: SizedBox(height: height!,
                //margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                width: width,
                child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(),child: getProductRating())),
              ),
            ),
    );
  }
}

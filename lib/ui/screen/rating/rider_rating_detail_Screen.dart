import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/rating/getRiderRatingCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:project1/utils/internetConnectivity.dart';

class RiderRatingDetailScreen extends StatefulWidget {
  final String? riderId;
  const RiderRatingDetailScreen({Key? key, this.riderId}) : super(key: key);

  @override
  RiderRatingDetailScreenState createState() => RiderRatingDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<GetRiderRatingCubit>(
              create: (_) => GetRiderRatingCubit(),
              child: RiderRatingDetailScreen(riderId: arguments['riderId']),
            ));
  }
}

class RiderRatingDetailScreenState extends State<RiderRatingDetailScreen> {
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
      context.read<GetRiderRatingCubit>().fetchGetRiderRating(perPage, widget.riderId!);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<GetRiderRatingCubit>().hasMoreData()) {
        context.read<GetRiderRatingCubit>().fetchMoreGetRiderRatingData(perPage, widget.riderId!);
      }
    }
  }

  Widget getRiderRating() {
    return BlocConsumer<GetRiderRatingCubit, GetRiderRatingState>(
        bloc: context.read<GetRiderRatingCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetRiderRatingProgress || state is GetRiderRatingInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is GetRiderRatingFailure) {
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
          final riderRatingList = (state as GetRiderRatingSuccess).riderRatingList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              /* color: white,*/
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: riderRatingList.length,
                  itemBuilder: (BuildContext context, index) {
                    var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                    var inputDate = inputFormat.parse(riderRatingList[index].dataAdded!.toString());

                    // outputFormat - convert into format you want to show.
                    var outputFormat = DateFormat('dd/MM/yyyy');
                    var outputDate = outputFormat.format(inputDate);
                    return hasMore && riderRatingList.isEmpty && index == (riderRatingList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Container(
                            padding:
                                EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
                            //height: height!/4.7,
                            width: width!,
                            margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
                            decoration:
                                DesignConfig.boxDecorationContainerCardShadow(Theme.of(context).colorScheme.onSurface, shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      //flex: 2,
                                      child: ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                          child: DesignConfig.imageWidgets(riderRatingList[index].userProfile!, height! / 14.0, width! / 6.0,"2")),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(riderRatingList[index].userName!,
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSecondary,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        )),
                                                  ),
                                                  const Spacer(),
                                                  //SizedBox(width: width! / 99.0),
                                                  Container(
                                                      alignment: Alignment.center,
                                                      padding: const EdgeInsetsDirectional.only(top: 2, bottom: 2, start: 8.9, end: 8.9),
                                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 5),
                                                      //margin: EdgeInsetsDirectional.only(start: width! / 20.0),
                                                      child: Row(
                                                        children: [
                                                          Text(riderRatingList[index].rating!,
                                                              textAlign: TextAlign.left,
                                                              style:
                                                                  const TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w700)),
                                                          Icon(Icons.star, color: Theme.of(context).colorScheme.onSurface, size: 15.0),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                              Text(riderRatingList[index].comment!,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color: lightFont,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal,
                                                      overflow: TextOverflow.ellipsis),
                                                  maxLines: 1),
                                              const SizedBox(height: 2.0),
                                              Text(outputDate,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color: lightFont,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal,
                                                      overflow: TextOverflow.ellipsis),
                                                  maxLines: 1),
                                              //SizedBox(height: height! / 99.0),
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ));
                  }));
        });
  }

  Future<void> refreshList() async {
    context.read<GetRiderRatingCubit>().fetchGetRiderRating(
          perPage,
          widget.riderId!,
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
              appBar: AppBar(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                        padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                        child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32,fit: BoxFit.scaleDown,))),
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                shadowColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                centerTitle: true,
                title: Text(UiUtils.getTranslatedLabel(context, reviewsLabel),
                    textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: getRiderRating()),
              ),
            ),
    );
  }
}

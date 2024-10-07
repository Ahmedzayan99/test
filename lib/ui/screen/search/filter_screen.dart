import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/home/cuisine/cuisineCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/simmer/categoryVerticallySimmer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project1/utils/internetConnectivity.dart';

class FilterScreen extends StatefulWidget {
  final String? filterBy;
  const FilterScreen({Key? key, this.filterBy}) : super(key: key);

  @override
  FilterScreenState createState() => FilterScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => FilterScreen(
            filterBy: arguments['filterBy'] as String));
  }
}

class FilterScreenState extends State<FilterScreen> {
  double? width, height;
  ScrollController cuisineController = ScrollController();
  bool enableList = false;
  int? _selectedIndex;
  String? statusFoodType = "3";
  String? statusRating = "1";
  String? costStatus = "ASC";
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController subjectController = TextEditingController(text: "");
  TextEditingController messageController = TextEditingController(text: "");
  List<String> ratingList = ["1", "2", "3", "4", "5"];
  List<String> costList = [];
  int deliveryTimeIndex = 0;
  late int selectedIndex = 0;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? categoryId;

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    print(widget.filterBy);
    cuisineController.addListener(cuisineScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<CuisineCubit>().fetchCuisine(perPage, categoryKey, "");
    });
    Future.delayed(const Duration(microseconds: 1000),(){
      costData();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  costData(){
    costList = [UiUtils.getTranslatedLabel(context, lowToHighLabel), UiUtils.getTranslatedLabel(context, highToLowLabel)];
  }

  cuisineScrollListener() {
    if (cuisineController.position.maxScrollExtent == cuisineController.offset) {
      if (context.read<CuisineCubit>().hasMoreData()) {
        context.read<CuisineCubit>().fetchMoreCuisineData(perPage, categoryKey, "");
      }
    }
  }

  onChanged(int position) {
    setState(() {
      _selectedIndex = position;
      enableList = !enableList;
    });
  }

  onTap() {
    setState(() {
      enableList = !enableList;
    });
  }

  Widget selectType() {
    return BlocConsumer<CuisineCubit, CuisineState>(
        bloc: context.read<CuisineCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineProgress || state is CuisineInitial) {
            return Center(child: CuisineVerticallySimmer(length: 9, width: width!, height: height!));
          }
          if (state is CuisineFailure) {}
          final cuisineList = (state as CuisineSuccess).cuisineList;
          final hasMore = state.hasMore;
          return Container(
            decoration: DesignConfig.boxDecorationContainerCardShadow(Theme.of(context).colorScheme.onSurface, shadow, 10.0, 0.0, 0.0, 10.0, 0.0),
            margin: EdgeInsetsDirectional.only(top: height! / 99.0),
            child: ListView.builder(
                controller: cuisineController,
                padding: EdgeInsetsDirectional.only(top: height! / 99.9, bottom: height! / 99.0),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: cuisineList.length,
                itemBuilder: (context, position) {
                  return hasMore && position == (cuisineList.length - 1)
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                      : InkWell(
                          onTap: () {
                            onChanged(position);
                            categoryId = cuisineList[position].id!;
                          },
                          child: Container(
                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cuisineList[position].name!,
                                    style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(top: height! / 99.0),
                                    child: Divider(
                                      color: lightFont.withOpacity(0.50),
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              )),
                        );
                }),
          );
        });
  }

  Widget selectTypeDropdown() {
    return BlocConsumer<CuisineCubit, CuisineState>(
        bloc: context.read<CuisineCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineProgress || state is CuisineInitial) {
            return Center(child: CuisineVerticallySimmer(length: 9, width: width!, height: height!));
          }
          if (state is CuisineFailure) {}
          final cuisineList = (state as CuisineSuccess).cuisineList;
          //final hasMore = state.hasMore;
          return InkWell(
            onTap: onTap,
            child: Container(
              margin: EdgeInsetsDirectional.only(bottom: height! / 50.0),
              decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
              padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    _selectedIndex != null ? cuisineList[_selectedIndex!].text! : UiUtils.getTranslatedLabel(context, selectCuisineLabel),
                    style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                  )),
                  Icon(enableList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: Theme.of(context).colorScheme.onSecondary),
                ],
              ),
            ),
          );
        });
  }

  Widget foodType() {
    return Container(
        margin: EdgeInsetsDirectional.only(bottom: height! / 50.0),
        decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
        child: Row(children: [
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "3";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0, start: width! / 70.0, end: width! / 70.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 99.0, end: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "3" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, 15.0),
                      child: Text(UiUtils.getTranslatedLabel(context, bothLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "3" ? white : Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "1";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(
                        start: width! / 70.0,
                        end: width! / 99.0,
                        bottom: height! / 99.0,
                        top: height! / 99.0,
                      ),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 99.0, end: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "1" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, 15.0),
                      child: Text(UiUtils.getTranslatedLabel(context, vegLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "1" ? white : Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "2";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0, start: width! / 70.0, end: width! / 70.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 99.0, end: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "2" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, 15.0),
                      child: Text(UiUtils.getTranslatedLabel(context, nonVegLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "2" ? white : Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
        ]));
  }

  Widget rating() {
    return Container(
        margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0),
        child: Row(children: [
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "1";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        end: width! / 40.0,
                        start: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "1" ? Theme.of(context).colorScheme.primary : textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, colorFilter: ColorFilter.mode(statusRating == "1" ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
                          SizedBox(width: width! / 99.0),
                          Text("1",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "1" ? white : Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "2";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        end: width! / 40.0,
                        start: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "2" ? Theme.of(context).colorScheme.primary : textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, colorFilter: ColorFilter.mode(statusRating == "2" ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
                          SizedBox(width: width! / 99.0),
                          Text("2",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "2" ? white : Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "3";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        end: width! / 40.0,
                        start: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "3" ? Theme.of(context).colorScheme.primary : textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, colorFilter: ColorFilter.mode(statusRating == "3" ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
                          SizedBox(width: width! / 99.0),
                          Text("3",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "3" ? white : Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "4";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, end: width! / 40.0, start: width! / 40.0),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "4" ? Theme.of(context).colorScheme.primary : textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, colorFilter: ColorFilter.mode(statusRating == "4" ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
                          SizedBox(width: width! / 99.0),
                          Text("4",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "4" ? white : Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "5";
                    });
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        end: width! / 40.0,
                        start: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "5" ? Theme.of(context).colorScheme.primary : textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, colorFilter: ColorFilter.mode(statusRating == "5" ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
                          SizedBox(width: width! / 99.0),
                          Text("5",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "5" ? white : Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
        ]));
  }

  Widget cost() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.5),
      itemCount: costList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        return RadioListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: Theme.of(context).colorScheme.primary,
          controlAffinity: ListTileControlAffinity.leading,
          value: index,
          groupValue: deliveryTimeIndex,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(
            costList[index],
            style: const TextStyle(
              color: black,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          onChanged: (int? val) {
            setState(() {
              if (val == 0) {
                deliveryTimeIndex = val!; /*gender="Male";*/
                costStatus = "ASC";
              } else if (val == 1) {
                deliveryTimeIndex = val!; /*gender="Female";*/
                costStatus = "DESC";
              }
              deliveryTimeIndex = val!;
            });
          },
        );
      },
    );
  }

  /*Widget deliveryTime() {
    return Container(height: height!/15.0, margin: EdgeInsetsDirectional.only(top: height!/60.0, bottom: height!/40.0,),
        child: ListView.builder(shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: deliveryTimeList.length,scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return InkWell(onTap:(){
                  setState(() {
                    selectedIndex = index;
                    if(deliveryTimeList[index].like == "1") {
                      deliveryTimeList[index].like = "2";
                    } else{
                      deliveryTimeList[index].like = "1";
                    }
                  });
                  },child: Container(alignment: Alignment.center, margin: EdgeInsetsDirectional.only(end: width!/30.0), width: width!/4.0, padding: EdgeInsetsDirectional.only(top: height!/55.0, bottom: height!/55.0,end: width!/40.0,start: width!/40.0,), decoration: DesignConfig.boxDecorationContainer(selectedIndex == index ? red : textFieldBackground, 10.0), child: Text(deliveryTimeList[index].time!, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: selectedIndex == index ? white : Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    ));
            }
        ));
  }*/

  @override
  void dispose() {
    cuisineController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, filterLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              bottomNavigationBar: Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: ButtonContainer(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: height,
                    width: width,
                    text: UiUtils.getTranslatedLabel(context, clearLabel),
                    top: 0,
                    start: width! / 40.0,
                    end: width! / 40.0,
                    bottom: height! / 55.0,
                    status: false,
                    borderColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    onPressed: () {
                      //Navigator.pop(context);
                      setState((){
                      _selectedIndex = null;
                      statusFoodType = "3";
                      statusRating = "1";
                      costStatus = "ASC";
                      deliveryTimeIndex = 0;
                      });
                    },
                  )),
                  Expanded(
                      child: ButtonContainer(
                    color: Theme.of(context).colorScheme.secondary,
                    height: height,
                    width: width,
                    text: UiUtils.getTranslatedLabel(context, letsSearchLabel),
                    top: 0,
                    start: width! / 40.0,
                    end: width! / 40.0,
                    bottom: height! / 55.0,
                    status: false,
                    borderColor: Theme.of(context).colorScheme.secondary,
                    textColor: white,
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(Routes.filterDetail, arguments: {
                        'categoryId': categoryId ?? "",
                        'statusFoodType': statusFoodType ?? "",
                        'costStatus': costStatus ?? "",
                        'filterBy': widget.filterBy ?? "",
                      });
                    },
                  )),
                ],
              ),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0), padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 60.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),height: height!,
                width: width,
                child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(UiUtils.getTranslatedLabel(context, selectRestaurantWithLabel),
                        style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height! / 50.0, bottom: height! / 50.0),
                      child: const Divider(
                        color: lightFont,
                        height: 1.0,
                      ),
                    ),
                    foodType(),
                    Text(UiUtils.getTranslatedLabel(context, selectCuisineLabel),
                        style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height! / 50.0, bottom: height! / 50.0),
                      child: const Divider(
                        color: lightFont,
                        height: 1.0,
                      ),
                    ),
                    selectTypeDropdown(),
                    enableList ? selectType() : Container(),
                    /*Text(StringsRes.rating,
                        style: const TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height!/50.0, bottom: height!/99.0),
                      child: const Divider(color: lightFont, height: 1.0,),
                    ),
                    rating(),*/
                    Text(UiUtils.getTranslatedLabel(context, costLabel), style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height! / 50.0, bottom: height! / 99.0),
                      child: const Divider(
                        color: lightFont,
                        height: 1.0,
                      ),
                    ),
                    cost(),
                    /*Text(StringsRes.deliveryTime,
                        style: const TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height!/50.0),
                      child: const Divider(color: lightFont, height: 1.0,),
                    ),
                    deliveryTime(),*/
                  ]),
                ),
              )),
    );
  }
}

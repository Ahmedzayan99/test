import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/home/restaurants/restaurantCubit.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/data/model/search_model.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/restaurantContainer.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
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
import 'package:flutter_svg/flutter_svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class RestaurantsNearbyScreen extends StatefulWidget {
  const RestaurantsNearbyScreen({Key? key}) : super(key: key);

  @override
  RestaurantsNearbyScreenState createState() => RestaurantsNearbyScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<RestaurantCubit>(
              create: (_) => RestaurantCubit(),
              child: const RestaurantsNearbyScreen(),
            ));
  }
}

class RestaurantsNearbyScreenState extends State<RestaurantsNearbyScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? restaurantListLength = "";
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  List<RestaurantModel> restaurantList = [];
  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
 /*   _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<RestaurantCubit>().fetchRestaurant(
          perPage,
          "0",
          context.read<CityDeliverableCubit>().getCityId(),
          context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
          context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
          context.read<AuthCubit>().getId(),
          "");
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<RestaurantCubit>().hasMoreData()) {
        //if (restaurantList.length > int.parse(perPage)) {
          context.read<RestaurantCubit>().fetchMoreRestaurantData(
              perPage,
              "0",
              context.read<CityDeliverableCubit>().getCityId(),
              context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
              context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
              context.read<AuthCubit>().getId(),
              "");
        //}
      }
    }
  }

  Widget restaurantsNearby() {
    return BlocConsumer<RestaurantCubit, RestaurantState>(
        bloc: context.read<RestaurantCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is RestaurantProgress || state is RestaurantInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is RestaurantFailure) {
            return Center(child: Text(state.errorMessage));
          }
          restaurantList = (state as RestaurantSuccess).restaurantList;
          restaurantListLength = restaurantList.length.toString();
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              /* color: ColorsRes.white,*/
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: restaurantList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && restaurantList.isEmpty && index == (restaurantList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : RestaurantContainer(restaurant: restaurantList[index], height: height!, width: width!);
                  }));
        });
  }

  Widget searchData() {
    return Container(
        height: height! / 25.2,
        margin: EdgeInsetsDirectional.only(top: height! / 40.0, bottom: height! / 40.0, start: width! / 20.0),
        child: ListView.builder(
            shrinkWrap: true, //padding: EdgeInsetsDirectional.only(top: height!/40.0),
            physics: const BouncingScrollPhysics(),
            itemCount: searchList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Container(
                  padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0, end: width! / 20.0, bottom: height! / 99.0),
                  margin: EdgeInsetsDirectional.only(end: width! / 20.0),
                  decoration: DesignConfig.boxDecorationContainerBorder(lightFont, Theme.of(context).colorScheme.onSurface, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(searchList[index].title!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8.0),
                      SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 10, height: 10),
                    ],
                  ));
            }));
  }

  Widget searchBar() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.search);
      },
      child: Container(
        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.surface, 10.0),
        padding: EdgeInsetsDirectional.only(start: width! / 99.0, end: width! / 99.0),
        margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.search);
                  },
                  child: const Icon(Icons.search, color: lightFont)),
            ),
            Text(
              UiUtils.getTranslatedLabel(context, searchTitleLabel),
              style: const TextStyle(
                color: lightFont,
                fontSize: 14.0,
              ),
            ),
            const Spacer(),
            InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.filter, arguments: {
                    'filterBy': filterByResturentKey,
                  });
                },
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsetsDirectional.only(end: 4.0, top: 4.0, bottom: 4.0),
                    decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 12.0),
                    child: SvgPicture.asset(DesignConfig.setSvgPath("filter_button"), fit: BoxFit.scaleDown))),
          ],
        ),
      ),
    );
  }

  Future<void> refreshList() async {
    context.read<RestaurantCubit>().fetchRestaurant(
        perPage,
        "0",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<AuthCubit>().getId(),
        "");
  }

  @override
  void dispose() {
    searchController.dispose();
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
              appBar: DesignConfig.appBar(
                  context,
                  width!,
                  UiUtils.getTranslatedLabel(context, restaurantsNearbyLabel),
                  PreferredSize(
                    preferredSize: Size(width!, height! / 12.0),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          searchBar(),
                          //searchData(),
                          /*Padding(
                        padding: EdgeInsetsDirectional.only(start: width!/20.0, end: width!/20.0, top: height!/50.0),
                        child: Text(StringsRes.restaurantsNearby, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                      )*/
                        ],
                      ),
                    ),
                  )),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: restaurantsNearby()),
              ),
            ),
    );
  }
}

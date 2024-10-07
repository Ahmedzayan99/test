import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/home/search/filterCubit.dart';
import 'package:project1/data/model/search_model.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/productContainer.dart';
import 'package:project1/ui/widgets/restaurantCloseDialog.dart';
import 'package:project1/ui/widgets/restaurantContainer.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project1/ui/widgets/simmer/sectionSimmer.dart';
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

class FilterDetailScreen extends StatefulWidget {
  final String? categoryId, statusFoodType, costStatus, filterBy;
  const FilterDetailScreen({Key? key, this.categoryId, this.statusFoodType, this.costStatus, this.filterBy}) : super(key: key);

  @override
  FilterDetailScreenState createState() => FilterDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FilterCubit>(
              create: (_) => FilterCubit(),
              child: FilterDetailScreen(
                  categoryId: arguments['categoryId'] as String,
                  statusFoodType: arguments['statusFoodType'] as String,
                  costStatus: arguments['costStatus'] as String,
                  filterBy: arguments['filterBy'] as String),
            ));
  }
}

class FilterDetailScreenState extends State<FilterDetailScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  List<ProductDetails> filterList = [];
  @override
  void initState() {
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
      context.read<FilterCubit>().fetchFilter(
          perPage,
          widget.categoryId ?? "",
          widget.statusFoodType ?? "",
          widget.costStatus ?? "",
          context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
          context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
          context.read<AuthCubit>().getId(),
          context.read<CityDeliverableCubit>().getCityId(),
          widget.filterBy);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<FilterCubit>().hasMoreData()) {
        if (filterList.length > int.parse(perPage)) {
          context.read<FilterCubit>().fetchMoreFilterData(
              perPage,
              widget.categoryId ?? "",
              widget.statusFoodType ?? "",
              widget.costStatus ?? "",
              context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
              context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
              context.read<AuthCubit>().getId(),
              context.read<CityDeliverableCubit>().getCityId(),
              widget.filterBy);
        }
      }
    }
  }

    bottomModelSheetShow(ProductDetails productList) {
    ProductDetails productDetailsModel = productList;
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![0].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    for (int i = 0; i < productDetailsModel.variants![currentIndex].addOnsData!.length; i++) {
      productAddOnIds.add(productDetailsModel.variants![currentIndex].addOnsData![i].id!);
    }
    if (productDetailsModel.variants![currentIndex].cartCount != "0") {
      qty = int.parse(productDetailsModel.variants![currentIndex].cartCount!);
    } else {
      qty = int.parse(productDetailsModel.minimumOrderQuantity!);
    }
    qtyData[productVariantId!] = qty;
    bool descTextShowFlag = false;

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return BottomSheetContainer(
              productDetailsModel: productDetailsModel,
              isChecked: isChecked,
              height: height!,
              width: width!,
              productVariantId: productVariantId,
              addOnIds: addOnIds,
              addOnPrice: addOnPrice,
              addOnQty: addOnQty,
              productAddOnIds: productAddOnIds,
              qtyData: qtyData,
              currentIndex: currentIndex,
              descTextShowFlag: descTextShowFlag,
              qty: qty,
              from: "favourite");
        });
  }

    Widget filterProduct() {
    return BlocBuilder<FilterCubit, FilterState>(
        bloc: context.read<FilterCubit>(),
        builder: (context, state) {
          if (state is FilterProgress || state is FilterInitial) {
            return SectionSimmer(length: 4, width: width!, height: height!);
          }
          if (state is FilterFailure) {
            //print("favouriteScreenProduct:${state.errorStatusCode}");
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundTitleLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            );
          }
          filterList = (state as FilterSuccess).filterList;
          final hasMore = state.hasMore;
          if (filterList.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundTitleLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            );
          }

          return GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              childAspectRatio: 0.99,
              physics: const AlwaysScrollableScrollPhysics(),
              children: List.generate(filterList.length, (index) {
                double price = double.parse(filterList[index].variants![0].specialPrice!);
                if (price == 0) {
                  price = double.parse(filterList[index].variants![0].price!);
                }

                double off = 0;
                if (filterList[index].variants![0].specialPrice! != "0") {
                  off = (double.parse(filterList[index].variants![0].price!) -
                          double.parse(filterList[index].variants![0].specialPrice!))
                      .toDouble();
                  off = off * 100 / double.parse(filterList[index].variants![0].price!).toDouble();
                }
                return hasMore && filterList.isEmpty && index == (filterList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : GestureDetector(
                  onTap: () {
                    if (filterList[index].partnerDetails![0].isRestroOpen == "1") {
                      bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                filterList[index].id!, filterList[index])[0] /* filterList, index */);
                    } else {
                      showDialog(context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                    }
                  },
                  child: ProductContainer(
                      productDetails: filterList[index],
                      height: height!,
                      width: width,
                      productDetailsList: filterList,
                      price: price,
                      off: off,
                      from: "favourite",
                      axis: "horizontal"),
                );
              }));
        });
  }

  Widget filterDetail() {
    return BlocConsumer<FilterCubit, FilterState>(
        bloc: context.read<FilterCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FilterProgress || state is FilterInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is FilterFailure) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundTitleLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            );
          }
          filterList = (state as FilterSuccess).filterList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              /* color: ColorsRes.white,*/
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filterList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && filterList.isEmpty && index == (filterList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : RestaurantContainer(restaurant: filterList[index].partnerDetails![0], height: height!, width: width!);
                  }));
        });
  }

  Widget searchData() {
    return Container(
        height: height! / 25.2,
        margin: EdgeInsetsDirectional.only(top: height! / 40.0, bottom: height! / 40.0, start: width! / 20.0),
        child: ListView.builder(
            shrinkWrap: true, //padding: EdgeInsetsDirectional.only(top: height!/40.0),
            physics: const AlwaysScrollableScrollPhysics(),
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
              appBar: DesignConfig.appBar(context, width, UiUtils.getTranslatedLabel(context, filterLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: Container(height: height!,
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: Container(
                  //margin: EdgeInsetsDirectional.only(end: width!/40.0, start: width!/40.0),
                  child: widget.filterBy==filterByResturentKey?filterDetail():filterProduct(),
                ),
              ),
            ),
    );
  }
}

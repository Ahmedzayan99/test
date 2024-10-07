import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/home/sections/sectionsDetailCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/productContainer.dart';
import 'package:project1/ui/widgets/productUnavailableDialog.dart';
import 'package:project1/ui/widgets/restaurantCloseDialog.dart';
import 'package:project1/ui/widgets/simmer/sectionSimmer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/internetConnectivity.dart';

class SectionScreen extends StatefulWidget {
  final String? title, sectionId;
  const SectionScreen({Key? key, this.title, this.sectionId}) : super(key: key);

  @override
  SectionScreenState createState() => SectionScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) =>  SectionScreen(title: arguments['title'] as String, sectionId: arguments['sectionId'] as String),
        );
  }
}

class SectionScreenState extends State<SectionScreen>  with SingleTickerProviderStateMixin{
  double? width, height;
  ScrollController sectionController = ScrollController();

  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late var _connectivitySubscription;

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
/*
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
*/

    sectionController.addListener(sectionScrollListener);
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await sectionApiCall();
      }
    });

    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  sectionScrollListener() {
    print("data");
    if (sectionController.position.maxScrollExtent == sectionController.offset) {
      if (context.read<SectionsDetailCubit>().hasMoreData()) {
        context.read<SectionsDetailCubit>().fetchMoreSectionsDetailData(
        perPage,
        context.read<AuthCubit>().getId(),
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<CityDeliverableCubit>().getCityId(),
        widget.sectionId);
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

  Widget noDataSection() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noSectionYetLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noSectionYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget topDeal() {
    return BlocBuilder<SectionsDetailCubit, SectionsDetailState>(
        bloc: context.read<SectionsDetailCubit>(),
        builder: (context, state) {
          if (state is SectionsDetailProgress || state is SectionsDetailInitial) {
            return SectionSimmer(length: 4, width: width!, height: height!);
          }
          if (state is SectionsDetailFailure) {
            //print("sectionsDetailcreenProduct:${state.errorStatusCode}");
            return noDataSection();
          }
          if (state is SectionsDetailFailure) {
            if(state.errorMessage.toString() == "102"){
                reLogin(context);
            }
          }
          final sectionsList = (state as SectionsDetailSuccess).sectionsDetailList;
          final hasMore = state.hasMore;
          if (sectionsList.isEmpty) {
            return noDataSection();
          }

          return GridView.count(controller: sectionController,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              childAspectRatio: 0.99,
              physics: const BouncingScrollPhysics(),
              children: List.generate(hasMore?sectionsList.length+1:sectionsList.length, (index) {
                 double? price;
                 double off = 0;
                if(hasMore && index == (sectionsList.length)){}else{
                price = double.parse(sectionsList[index].variants![0].specialPrice!);
                if (price == 0) {
                  price = double.parse(sectionsList[index].variants![0].price!);
                }


                if (sectionsList[index].variants![0].specialPrice! != "0") {
                  off = (double.parse(sectionsList[index].variants![0].price!) -
                          double.parse(sectionsList[index].variants![0].specialPrice!))
                      .toDouble();
                  off = off * 100 / double.parse(sectionsList[index].variants![0].price!).toDouble();
                }
                }
                return hasMore && index == (sectionsList.length)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : GestureDetector(
                  onTap: () {
                    if (sectionsList[index].partnerDetails![0].isRestroOpen == "1") {
                      bool check = getStoreOpenStatus(sectionsList[index].startTime!, sectionsList[index].endTime!);
                      if(sectionsList[index].availableTime=="1"){
                        if(check==true){
                          bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                    sectionsList[index].id!, sectionsList[index])[0] /* sectionsList, index */);
                        }else{
                          showDialog(
                            context: context,
                            builder: (_) => ProductUnavailableDialog(startTime: sectionsList[index].startTime, endTime: sectionsList[index].endTime));
                        }
                      }else{
                        bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                  sectionsList[index].id!, sectionsList[index])[0] /* sectionsList, index */);
                      }
                    } else {
                      showDialog(context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                    }
                  },
                  child: ProductContainer(
                      productDetails: sectionsList[index],
                      height: height!,
                      width: width,
                      productDetailsList: sectionsList,
                      price: price,
                      off: off,
                      from: "home",
                      axis: "vertical"),
                );
              }));
        });
  }

  sectionApiCall(){
    context.read<SectionsDetailCubit>().fetchSectionsDetail(
        perPage,
        context.read<AuthCubit>().getId(),
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<CityDeliverableCubit>().getCityId(),
        widget.sectionId);
  }

  Future<void> refreshSectionList() async {
    await sectionApiCall();
  }

  @override
  void dispose() {
    sectionController.dispose();
    //_scrollBottomBarController.dispose();
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
              appBar: DesignConfig.appBar(context, width!, widget.title, const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: refreshSectionList,
                  color: Theme.of(context).colorScheme.primary,
                  child: Container(
                      margin: EdgeInsetsDirectional.only(top: height! / 80.0/* , bottom: height!/80.0 */),
                      padding: EdgeInsetsDirectional.only(end: width!/ 20.0),
                      decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                      width: width,height: height,
                      child: topDeal(),
                    ),
                ),
              ),
            ),
    );
  }
}

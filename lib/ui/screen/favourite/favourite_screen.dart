import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/productContainer.dart';
import 'package:project1/ui/widgets/productUnavailableDialog.dart';
import 'package:project1/ui/widgets/restaurantCloseDialog.dart';
import 'package:project1/ui/widgets/restaurantContainer.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project1/ui/widgets/simmer/sectionSimmer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/internetConnectivity.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen>  with SingleTickerProviderStateMixin{
  double? width, height;
  ScrollController controllerFavouriteRestaurant = ScrollController();
  ScrollController controllerFavouriteProduct = ScrollController();
  //final ScrollController _scrollBottomBarController = ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  TabController? _controller;

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
    _controller = TabController(vsync: this, length: 2);
    //getUserLocation();
    //myScroll(_scrollBottomBarController, context);
    //controllerFavouriteRestaurant.addListener(scrollListenerFavouriteRestaurant);
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {}else{
      Future.delayed(Duration.zero, () async {
      if (mounted) {
        await context.read<FavoriteRestaurantsCubit>().getFavoriteRestaurants(context.read<AuthCubit>().getId(), partnersKey);
      }
    });

    //controllerFavouriteProduct.addListener(scrollListenerFavouriteProduct);
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await context.read<FavoriteProductsCubit>().getFavoriteProducts(context.read<AuthCubit>().getId(), productsKey);
      }
    });
    }
    

    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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
      /* qty = int.parse(productDetailsModel.minimumOrderQuantity!); */qty = int.parse(productDetailsModel.variants![currentIndex].cartCount!);
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

  Widget noDataFavourite() {
    return NoDataContainer(
        image: "favourite_empty_icon",
        title: UiUtils.getTranslatedLabel(context, noFavouriteYetLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noFavouriteYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget topDeal() {
    return BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
        bloc: context.read<FavoriteProductsCubit>(),
        builder: (context, state) {
          if (state is FavoriteProductsFetchInProgress || state is FavoriteProductsInitial) {
            return SectionSimmer(length: 4, width: width!, height: height!);
          }
          if (state is FavoriteProductsFetchFailure) {
            //print("favouriteScreenProduct:${state.errorStatusCode}");
            return noDataFavourite();
          }
          if (state is FavoriteProductsFetchFailure) {
            if(state.errorStatusCode.toString() == "102"){
                reLogin(context);
            }
          }
          final favouriteProductList = (state as FavoriteProductsFetchSuccess).favoriteProducts;
          if (favouriteProductList.isEmpty) {
            return noDataFavourite();
          }

          return GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              childAspectRatio: 0.99,
              physics: const AlwaysScrollableScrollPhysics(),
              children: List.generate(favouriteProductList.length, (index) {
                double price = double.parse(favouriteProductList[index].variants![0].specialPrice!);
                if (price == 0) {
                  price = double.parse(favouriteProductList[index].variants![0].price!);
                }

                double off = 0;
                if (favouriteProductList[index].variants![0].specialPrice! != "0") {
                  off = (double.parse(favouriteProductList[index].variants![0].price!) -
                          double.parse(favouriteProductList[index].variants![0].specialPrice!))
                      .toDouble();
                  off = off * 100 / double.parse(favouriteProductList[index].variants![0].price!).toDouble();
                }
                return GestureDetector(
                  onTap: () {
                    if (favouriteProductList[index].partnerDetails![0].isRestroOpen == "1") {
                      bool check = getStoreOpenStatus(favouriteProductList[index].startTime!, favouriteProductList[index].endTime!);
                      if(favouriteProductList[index].availableTime=="1"){
                        if(check==true){
                          bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                                                  favouriteProductList[index].id!,
                                                                  favouriteProductList[index])[0]/* favouriteProductList, index */);
                        }else{
                          showDialog(
                            context: context,
                            builder: (_) => ProductUnavailableDialog(startTime: favouriteProductList[index].startTime, endTime: favouriteProductList[index].endTime));
                        }
                      }else{
                        bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                                                  favouriteProductList[index].id!,
                                                                  favouriteProductList[index])[0]/* favouriteProductList, index */);
                      }
                    } else {
                      showDialog(context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                    }
                  },
                  child: ProductContainer(
                      productDetails: favouriteProductList[index],
                      height: height!,
                      width: width,
                      productDetailsList: favouriteProductList,
                      price: price,
                      off: off,
                      from: "favourite",
                      axis: "horizontal"),
                );
              }));
        });
  }

  Widget favouriteRestaurants() {
    return BlocBuilder<FavoriteRestaurantsCubit, FavoriteRestaurantsState>(
        bloc: context.read<FavoriteRestaurantsCubit>(),
        builder: (context, state) {
          if (state is FavoriteRestaurantsFetchInProgress || state is FavoriteRestaurantsInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is FavoriteRestaurantsFetchFailure) {
            //return Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center,));
            //print("favouriteScreen:${state.errorStatusCode}");
            return noDataFavourite();
          }
          if (state is FavoriteRestaurantsFetchFailure) {
            //print("favouriteScreen:${state.errorMessage}");
            if(state.errorStatusCode.toString() == "102"){
                reLogin(context);
            }
          }
          final favouriteRestaurantList = (state as FavoriteRestaurantsFetchSuccess).favoriteRestaurants;
          if (favouriteRestaurantList.isEmpty) {
            return noDataFavourite();
          }
          //final hasMore = state.hasMore;
          return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: favouriteRestaurantList.length,
              itemBuilder: (BuildContext context, index) {
                return RestaurantContainer(restaurant: favouriteRestaurantList[index], height: height!, width: width!);
              });
        });
  }

  Future<void> refreshTopDealList() async {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {}else{
      await context.read<FavoriteProductsCubit>().getFavoriteProducts(context.read<AuthCubit>().getId(), productsKey);
    }
    //await context.read<FavoriteProductsCubit>().getFavoriteProducts(context.read<AuthCubit>().getId(), productsKey);
  }

  Future<void> refreshRestaurantsNearByList() async {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {}else{
      await context.read<FavoriteRestaurantsCubit>().getFavoriteRestaurants(context.read<AuthCubit>().getId(), partnersKey);
    }
    //await context.read<FavoriteRestaurantsCubit>().getFavoriteRestaurants(context.read<AuthCubit>().getId(), partnersKey);
  }

  @override
  void dispose() {
    controllerFavouriteRestaurant.dispose();
    controllerFavouriteProduct.dispose();
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
          :*/ DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, favouriteLabel), PreferredSize(
                                preferredSize: const Size.fromHeight(kToolbarHeight - 5),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                  decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
                                  height: kToolbarHeight - 5,
                                  child: TabBar(controller: _controller,
                                    labelColor: white,
                                    unselectedLabelColor: Theme.of(context).colorScheme.onSecondary,
                                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    indicator: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 15.0),
                                    tabs: [
                                      Tab(
                                        child: Text(UiUtils.getTranslatedLabel(context, productsLabel), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                      Tab(
                                        child: Text(UiUtils.getTranslatedLabel(context, restaurantsLabel), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                body: /*Container(margin: EdgeInsetsDirectional.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(white), width: width,
              child: favouriteList(),
                  )*/
                    SafeArea(
                  bottom: false,
                  child: RefreshIndicator(
                    onRefresh: refreshTopDealList,
                    color: Theme.of(context).colorScheme.primary,
                    child: Container(
                        margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                        decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                        width: width,
                        child: TabBarView(controller: _controller,
                          children: [
                            RefreshIndicator(
                                onRefresh: refreshTopDealList,
                                color: Theme.of(context).colorScheme.primary,
                                child: (context.read<AuthCubit>().state is AuthInitial ||
                                  context.read<AuthCubit>().state is Unauthenticated)?noDataFavourite():topDeal()),
                            RefreshIndicator(
                                onRefresh: refreshRestaurantsNearByList,
                                color: Theme.of(context).colorScheme.primary,
                                child: (context.read<AuthCubit>().state is AuthInitial ||
                                  context.read<AuthCubit>().state is Unauthenticated)?noDataFavourite():favouriteRestaurants()),
                          ],
                        ),
                      ),
                  ),
                ),
              ),
          ),
    );
  }
}

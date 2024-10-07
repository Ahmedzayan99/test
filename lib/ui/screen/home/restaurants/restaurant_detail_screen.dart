import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteRestaurant.dart';
import 'package:project1/cubit/home/cuisine/restaurantCuisineCubit.dart';
import 'package:project1/cubit/home/restaurants/restaurantCubit.dart';
import 'package:project1/cubit/product/productLoadCubit.dart';
import 'package:project1/cubit/product/restaurantCategoryCubit.dart';
import 'package:project1/data/model/restaurantModel.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/cubit/product/productCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project1/utils/SqliteData.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/simmer/bottomCartSimmer.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/productItemContainer.dart';
import 'package:project1/ui/widgets/simmer/restaurantDetailSimmer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project1/utils/internetConnectivity.dart';
import 'package:lottie/lottie.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel? restaurant;
  const RestaurantDetailScreen({Key? key, this.restaurant}) : super(key: key);

  @override
  RestaurantDetailScreenState createState() => RestaurantDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<RestaurantCubit>(
              create: (_) => RestaurantCubit(),
              child: RestaurantDetailScreen(
                restaurant: arguments['restaurant'] as RestaurantModel,
              ),
            ));
  }
}

class RestaurantDetailScreenState extends State<RestaurantDetailScreen> with TickerProviderStateMixin {
  //TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  late var isVisible = false;
  double? expandHeight;
  TabController? tabController;
  int selectedIndex = 0;
  Map<String, List<ProductDetails>> datalist = {};
  ScrollController controllerProduct = ScrollController();
  ScrollController controllerProductViewAll = ScrollController();
  String currcateid = "";
  late ProductDetails currproductlist;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  var db = DatabaseHelper();
  List<String> menuList = [];
  static const List<String> icons = ["abc", "def", "ghi"];
  String? categoryId = "";

  //

  int offset = 0, total = 0, plimit = 10;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  late ScrollController scontroller;
  //List<Property> propertylist = [];
  Map<String, dynamic> propbody = {};
  List<ProductDetails> myPropertylist = [];

  //

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
    controllerProductViewAll.addListener(scrollListener);
    //productApi();
    cuisineApi();
    getCategory();
    cartApi();
    restaurantApi();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

//
    propbody = {};
    scontroller = ScrollController();
    //scontroller = ScrollController()..addListener(_loadMore);

//called @Listener of SliderCubit
    /* Future.delayed(Duration.zero, () {
      _firstLoad();
    });*/
//
  }

  getCategory() {
    print("rslug->${widget.restaurant!.slug!}--${widget.restaurant!.partnerId!}");
    context.read<RestaurantCategoryCubit>().fetchCategory(context, widget.restaurant!.slug!);
  }

  setDefault() {
    myPropertylist = [];
    offset = 0;
    total = 0;

    propbody[limitKey] = plimit.toString();
    propbody[offsetKey] = offset.toString();
    propbody[partnerIdKey] = widget.restaurant!.partnerId;
    propbody[filterByKey] = "p.id";
    propbody[latitudeKey] = context.read<SettingsCubit>().state.settingsModel!.latitude.toString();
    propbody[longitudeKey] = context.read<SettingsCubit>().state.settingsModel!.longitude.toString();
    propbody[userIdKey] = context.read<AuthCubit>().getId();
    propbody[cityIdKey] = context.read<CityDeliverableCubit>().getCityId();
    propbody[categoryIdKey] = categoryId;

    _isFirstLoadRunning = true;
  }

  void _firstLoad() async {
    setDefault();
    // setState(() {

    // });

    await loadData();

    // setState(() {
    _isFirstLoadRunning = false;
    //});
  }

  loadData() async {
    context.read<ProductLoadCubit>().productData(propbody);
    //.fetchMyProperty(context, true, bodyparam: propbody);
  }

  loadMoreData() async {
    context.read<ProductLoadCubit>().paginateProductData(propbody);
    //.fetchMyProperty(context, true, bodyparam: propbody);
  }

  @override
  void dispose() {
    //searchController.dispose();
    //tabController!.dispose();
    //_connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    scontroller.removeListener(_loadMore);
    //animationController!.dispose();
    super.dispose();
  }

  void _loadMore() async {
    if (_hasNextPage == true && _isFirstLoadRunning == false && _isLoadMoreRunning == false && scontroller.position.extentAfter < 300) {
      // setState(() {
      _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      // });

      //await loadData();
      await loadMoreData();

      // setState(() {

      // });
    }
  }

  scrollListener() {
//ProductViewAllProgress
/*
    if (controllerProductViewAll.position.maxScrollExtent ==
        controllerProductViewAll.offset) {
      if (context.read<ProductViewAllCubit>().hasMoreData()) {
        print("hashMore");
        context.read<ProductViewAllCubit>().fetchMoreProductData(
            perPage,
            widget.restaurant!.partnerId,
            context
                .read<SettingsCubit>()
                .state
                .settingsModel!
                .latitude
                .toString(),
            context
                .read<SettingsCubit>()
                .state
                .settingsModel!
                .longitude
                .toString(),
            context.read<AuthCubit>().getId(),
            context.read<CityDeliverableCubit>().getCityId(),
            categoryId);
      }
    }*/
  }

  restaurantClosedWidget() {
    return widget.restaurant!.isRestroOpen == "1"
        ? const SizedBox.shrink()
        : Positioned.directional(
            textDirection: Directionality.of(context),
            top: height! / 20.0,
            start: width! / 20.0,
            end: width! / 20.0,
            child: Lottie.asset(DesignConfig.setLottiePath("closed_restaurents"), height: height!/9.0, width: width!/4.0));
  }

  bottomModelSheetShow(List<ProductDetails> productList, int index) async {
    ProductDetails productDetailsModel = productList[index];
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![0].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    List<String> productAddOnId = [];
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productAddOnId = (await db.getVariantItemData(productDetailsModel.id!, productVariantId!))!;
      productAddOnIds = productAddOnId;
    } else {
      for (int i = 0; i < productDetailsModel.variants![currentIndex].addOnsData!.length; i++) {
        productAddOnIds.add(productDetailsModel.variants![currentIndex].addOnsData![i].id!);
      }
    }
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      qty = int.parse((await db.checkCartItemExists(productDetailsModel.id!, productVariantId!))!);
      if (qty == 0) {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);
      } else {
        print(qty);
        //int data = int.parse(productDetailsModel.variants![currentIndex].cartCount!);
        //data = qty;
        qtyData[productVariantId] = qty;
      }
    } else {
      if (productDetailsModel.variants![currentIndex].cartCount != "0") {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);//qty = int.parse(productDetailsModel.variants![currentIndex].cartCount!);
      } else {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);
      }
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
              from: "restaurantDetails");
        });
  }

  productApi() {
    context.read<ProductCubit>().getProduct(
        partnerId: widget.restaurant!.partnerId!,
        latitude: context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        longitude: context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        userId: context.read<AuthCubit>().getId(),
        cityId: context.read<CityDeliverableCubit>().getCityId(),
        vegetarian: "");
  }
  cuisineApi(){
    context.read<RestaurantCuisineCubit>().fetchRestaurantCuisine(perPage, "", widget.restaurant!.slug!);
  }

  cartApi() {
    if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    }
    /* context
        .read<GetCartCubit>()
        .getCartUser(userId: context.read<AuthCubit>().getId()); */
  }

  restaurantApi() {
    context.read<RestaurantCubit>().fetchRestaurant(
        perPage,
        "",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<AuthCubit>().getId(),
        "");
  }

  Future<void> refreshList() async {
    // productApi();
    cartApi();
    restaurantApi();
    /*context.read<ProductViewAllCubit>().fetchProduct(
        perPage,
        widget.restaurant!.partnerId,
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<AuthCubit>().getId(),
        context.read<CityDeliverableCubit>().getCityId(),
        categoryId);*/
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    expandHeight = height! / 2.8;//2.1;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(backgroundColor: Theme.of(context).colorScheme.onSurface,
              bottomNavigationBar: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                    ? BlocConsumer<SettingsCubit, SettingsState>(
                        bloc: context.read<SettingsCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) &&
                                  (state.settingsModel!.cartCount == "0" ||
                                      state.settingsModel!.cartCount == "" ||
                                      state.settingsModel!.cartCount == "0.0") &&
                                  (state.settingsModel!.cartTotal == "0" ||
                                      state.settingsModel!.cartTotal == "" ||
                                      state.settingsModel!.cartTotal == "0.0" ||
                                      state.settingsModel!.cartTotal == "0.00")
                              ? const SizedBox.shrink()
                              : Container(
                                  margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 40.0),
                                  width: width,
                                  padding: EdgeInsetsDirectional.only(
                                      top: height! / 55.0, bottom: height! / 55.0, start: width! / 20.0, end: width! / 20.0),
                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 100.0),
                                  child: Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("${state.settingsModel!.cartCount} ${UiUtils.getTranslatedLabel(context, itemTagLabel)} | ",
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500)),
                                          Text(
                                              context.read<SystemConfigCubit>().getCurrency() + state.settingsModel!.cartTotal.toString() == ""
                                                  ? "0"
                                                  : double.parse(state.settingsModel!.cartTotal.toString()).toStringAsFixed(2),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 13, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      const Spacer(),
                                      InkWell(
                                          onTap: () {
                                            clearAll();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (BuildContext context) => const CartScreen(from: "restaurantDetail"),
                                              ),
                                            );
                                          },
                                          child: Text(UiUtils.getTranslatedLabel(context, viewCartLabel),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500))),
                                    ],
                                  ),
                                );
                        })
                    : BlocConsumer<GetCartCubit, GetCartState>(
                        bloc: context.read<GetCartCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is GetCartProgress || state is GetCartInitial) {
                            return BottomCartSimmer(width: width!, height: height!);
                          }
                          if (state is GetCartFailure) {
                            return /* const Text(
                              /*state.errorMessage.toString()*/ "",
                              textAlign: TextAlign.center,
                            ) */const SizedBox.shrink();
                          }
                          final cartList = (state as GetCartSuccess).cartModel;
                          var sum = 0;
                          final currentCartModel = context.read<GetCartCubit>().getCartModel();
                          for (int i = 0; i < currentCartModel.data!.length; i++) {
                            sum += int.parse(currentCartModel.data![i].qty!);
                          }
                          return cartList.data!.isEmpty
                              ? const SizedBox.shrink()
                              : Container(
                                  margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 40.0),
                                  width: width,
                                  padding: EdgeInsetsDirectional.only(
                                      top: height! / 55.0, bottom: height! / 55.0, start: width! / 20.0, end: width! / 20.0),
                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 100.0),
                                  child: Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("$sum ${UiUtils.getTranslatedLabel(context, itemTagLabel)} | ",
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500)),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + (double.parse(cartList.subTotal.toString())/* -double.parse(cartList.taxAmount.toString()) */).toStringAsFixed(2),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 13, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      const Spacer(),
                                      InkWell(
                                          onTap: () {
                                            clearAll();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (BuildContext context) => const CartScreen(from: "restaurantDetail"),
                                              ),
                                            );
                                          },
                                          child: Text(UiUtils.getTranslatedLabel(context, viewCartLabel),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500))),
                                    ],
                                  ),
                                );
                        });
              }),
              body: RefreshIndicator(
                onRefresh: refreshList,
                color: Theme.of(context).colorScheme.primary,
                child: BlocConsumer<RestaurantCuisineCubit, RestaurantCuisineState>(
                    bloc: context.read<RestaurantCuisineCubit>(),
                    listener: (context, state) {
                      if (state is RestaurantCuisineSuccess && state.restaurantCuisineList.isNotEmpty) {
                        print("categorylen->${state.restaurantCuisineList.length}");
                        tabController = TabController(length: state.restaurantCuisineList.length, vsync: this);
                        /* tabController!.addListener(() {
                          setState(() {
                            selectedIndex = tabController!.index;
                            categoryId = state
                                .productModel.categories![selectedIndex].id;
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              _firstLoad();
                            });
                          });
                        }); */
                        categoryId = state.restaurantCuisineList[selectedIndex].id;
                        if (selectedIndex == 0) {
                          _firstLoad();
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is RestaurantCuisineProgress || state is RestaurantCuisineInitial) {
                        return RestaurantDetailSimmer(width: width!, height: height!);
                      }
                      if (state is RestaurantCuisineFailure) {
                        return NestedScrollView(
                            // controller: controllerProductViewAll,
                            controller: scontroller,
                            headerSliverBuilder: (context, innerBoxIsScrolled) {
                              return [
                                SliverLayoutBuilder(builder: (context, constraints) {
                                  return SliverAppBar(
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                                    systemOverlayStyle: constraints.scrollOffset >= 200 ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
                                    iconTheme: IconThemeData(
                                      color: constraints.scrollOffset >= 200
                                          ? Theme.of(context).colorScheme.onSecondary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                    floating: false,
                                    pinned: true,
                                    //automaticallyImplyLeading: _isVisible,
                                    leading: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsetsDirectional.all(3.5),
                                        margin: EdgeInsetsDirectional.only(top: 12, bottom: 12, start: width! / 20.0),
                                        decoration: DesignConfig.boxDecorationContainer(
                                            constraints.scrollOffset >= 350
                                                ? Theme.of(context).colorScheme.onSurface
                                                : greayLightColor.withOpacity(0.70),
                                            5.0),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: constraints.scrollOffset >= 350
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(Routes.productSearch, arguments: {
                                            "partnerId": widget.restaurant!.partnerId!,
                                            "partnerName": widget.restaurant!.partnerName!
                                          });
                                        },
                                        child: Container(
                                            padding: const EdgeInsetsDirectional.all(3.5),
                                            margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12),
                                            decoration: DesignConfig.boxDecorationContainer(
                                                constraints.scrollOffset >= 350
                                                    ? Theme.of(context).colorScheme.onSurface
                                                    : greayLightColor.withOpacity(0.70),
                                                5.0),
                                            child: SvgPicture.asset(DesignConfig.setSvgPath("search_icon"),
                                                colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                                                fit: BoxFit.scaleDown,
                                                width: 18.0,
                                                height: 18.3)),
                                      ),
                                      BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                        return BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
                                          create: (context) => UpdateRestaurantFavoriteStatusCubit(),
                                          child: Builder(builder: (context) {
                                            return BlocBuilder<FavoriteRestaurantsCubit, FavoriteRestaurantsState>(
                                                bloc: context.read<FavoriteRestaurantsCubit>(),
                                                builder: (context, favoriteRestaurantState) {
                                                  if (favoriteRestaurantState is FavoriteRestaurantsFetchSuccess) {
                                                    //check if restaurant is favorite or not
                                                    bool isRestaurantFavorite =
                                                        context.read<FavoriteRestaurantsCubit>().isRestaurantFavorite(widget.restaurant!.partnerId!);
                                                    return BlocConsumer<UpdateRestaurantFavoriteStatusCubit, UpdateRestaurantFavoriteStatusState>(
                                                      bloc: context.read<UpdateRestaurantFavoriteStatusCubit>(),
                                                      listener: ((context, state) {
                                                        //
                                                        if (state is UpdateRestaurantFavoriteStatusFailure) {
                                                          if (state.errorStatusCode.toString() == "102") {
                                                            reLogin(context);
                                                          }
                                                        }
                                                        if (state is UpdateRestaurantFavoriteStatusSuccess) {
                                                          //
                                                          if (state.wasFavoriteRestaurantProcess) {
                                                            context.read<FavoriteRestaurantsCubit>().addFavoriteRestaurant(state.restaurant);
                                                          } else {
                                                            //
                                                            context.read<FavoriteRestaurantsCubit>().removeFavoriteRestaurant(state.restaurant);
                                                          }
                                                        }
                                                      }),
                                                      builder: (context, state) {
                                                        if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                          return Container(
                                                              padding: const EdgeInsetsDirectional.all(3.5),
                                                              margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12, start: 10.0, end: 10.0),
                                                              decoration: DesignConfig.boxDecorationContainer(
                                                                  constraints.scrollOffset >= 350
                                                                      ? Theme.of(context).colorScheme.onSurface
                                                                      : greayLightColor.withOpacity(0.70),
                                                                  5.0),
                                                              child: CircularProgressIndicator(
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ));
                                                        }
                                                        return Container(
                                                          alignment: Alignment.center,
                                                          padding: const EdgeInsetsDirectional.all(3.5),
                                                          margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12, start: 10.0, end: 12.0),
                                                          decoration: DesignConfig.boxDecorationContainer(
                                                              constraints.scrollOffset >= 350
                                                                  ? Theme.of(context).colorScheme.onSurface
                                                                  : greayLightColor.withOpacity(0.70),
                                                              5.0),
                                                          child: InkWell(
                                                              onTap: () {
                                                                //
                                                                if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                                  return;
                                                                }
                                                                if (isRestaurantFavorite) {
                                                                  context.read<UpdateRestaurantFavoriteStatusCubit>().unFavoriteRestaurant(
                                                                      userId: context.read<AuthCubit>().getId(),
                                                                      type: partnersKey,
                                                                      restaurant: widget.restaurant!);
                                                                } else {
                                                                  //
                                                                  context.read<UpdateRestaurantFavoriteStatusCubit>().favoriteRestaurant(
                                                                      userId: context.read<AuthCubit>().getId(),
                                                                      type: partnersKey,
                                                                      restaurant: widget.restaurant!);
                                                                }
                                                              },
                                                              child: isRestaurantFavorite
                                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("wishlist-filled"),
                                                                      fit: BoxFit.scaleDown,
                                                                      width: 18.0,
                                                                      height: 18.3,
                                                                      colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                                          ? Theme.of(context).colorScheme.primary
                                                                          : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))
                                                                  : SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                                      fit: BoxFit.scaleDown,
                                                                      width: 18.0,
                                                                      height: 18.3,
                                                                      colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                                          ? Theme.of(context).colorScheme.primary
                                                                          : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
                                                        );
                                                      },
                                                    );
                                                  }
                                                  //if some how failed to fetch favorite restaurants or still fetching the restaurants
                                                  return Container(
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsetsDirectional.all(3.5),
                                                    margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12, start: 10.0, end: 10.0),
                                                    decoration: DesignConfig.boxDecorationContainer(
                                                        constraints.scrollOffset >= 350
                                                            ? Theme.of(context).colorScheme.onSurface
                                                            : greayLightColor.withOpacity(0.70),
                                                        5.0),
                                                    child: InkWell(
                                                        onTap: () {
                                                          if (favoriteRestaurantState is FavoriteRestaurantsFetchFailure) {
                                                            if (favoriteRestaurantState.errorStatusCode.toString() == "102") {
                                                              reLogin(context);
                                                            }
                                                          }
                                                          if (context.read<AuthCubit>().state is AuthInitial ||
                                                              context.read<AuthCubit>().state is Unauthenticated) {
                                                            Navigator.of(context)
                                                                .pushNamed(Routes.login, arguments: {'from': 'restaurantFavourite'}).then((value) {
                                                              Future.delayed(Duration.zero, () async {
                                                                await context
                                                                    .read<FavoriteRestaurantsCubit>()
                                                                    .getFavoriteRestaurants(context.read<AuthCubit>().getId(), partnersKey);
                                                              });
                                                              Future.delayed(Duration.zero, () async {
                                                                await context
                                                                    .read<FavoriteProductsCubit>()
                                                                    .getFavoriteProducts(context.read<AuthCubit>().getId(), productsKey);
                                                              });
                                                              Future.delayed(Duration.zero, () async {
                                                                context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
                                                              });
                                                            });
                                                            return;
                                                          }
                                                        },
                                                        child: SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                            fit: BoxFit.scaleDown,
                                                            width: 18.0,
                                                            height: 18.3,
                                                            colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                                ? Theme.of(context).colorScheme.primary
                                                                : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))
                                                        /*? const Icon(Icons.favorite, size: 18, color: red)
                                                                      : const Icon(Icons.favorite_border, size: 18, color: red)*/
                                                        ),
                                                  );
                                                });
                                          }),
                                        );
                                      }),
                                    ],
                                    flexibleSpace: FlexibleSpaceBar(
                                      centerTitle: false,
                                      //titlePadding: const EdgeInsetsDirectional.only(bottom: 50),
                                      title: constraints.scrollOffset >= 200
                                          ? Text(widget.restaurant!.partnerName!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal))
                                          : const SizedBox(),
                                      collapseMode: CollapseMode.pin,
                                      background: Padding(
                                        padding: const EdgeInsetsDirectional.only(top: 0),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(10.0),
                                                bottomRight: Radius.circular(10.0),
                                              ),
                                              child: ShaderMask(
                                                  shaderCallback: (Rect bounds) {
                                                    return LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Theme.of(context).colorScheme.onSecondary.withOpacity(0.25),
                                                        Theme.of(context).colorScheme.onSecondary.withOpacity(0.25)
                                                      ],
                                                    ).createShader(bounds);
                                                  },
                                                  blendMode: BlendMode.darken,
                                                  child: ColorFiltered(
                                                    //colorFilter: maindata[0].partnerDetails![0].isRestroOpen == "1"
                                                    colorFilter: widget.restaurant!.isRestroOpen == "1"
                                                        ? ColorFilter.mode(
                                                            Theme.of(context).colorScheme.onSecondary.withOpacity(0.70),
                                                            BlendMode.multiply,
                                                          )
                                                        : const ColorFilter.mode(
                                                            Colors.grey,
                                                            BlendMode.saturation,
                                                          ),
                                                    child: DesignConfig.imageWidgets(widget.restaurant!.partnerProfile!, height! / 2.5, width!, "2"),
                                                  )),
                                            ),
                                            Positioned.directional(
                                              textDirection: Directionality.of(context),
                                              bottom: height! / 40.0,
                                              start: width! / 20.0,
                                              end: width! / 20.0,
                                              child: Container(
                                                width: width,
                                                padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, bottom: 10.0, top: 10.0),
                                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(widget.restaurant!.partnerName!,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w700,
                                                                    fontStyle: FontStyle.normal,
                                                                  )),
                                                              SizedBox(width: width! / 50.0),
                                                              widget.restaurant!.partnerIndicator == "1"
                                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                                  : widget.restaurant!.partnerIndicator == "2"
                                                                      ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                          width: 15, height: 15)
                                                                      : Row(
                                                                          children: [
                                                                            SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"),
                                                                                width: 15, height: 15),
                                                                            const SizedBox(width: 2.0),
                                                                            SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                                width: 15, height: 15),
                                                                          ],
                                                                        ),
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                        ],
                                                      ),
                                                      widget.restaurant!.tags!.isNotEmpty
                                                          ? Padding(
                                                              padding: const EdgeInsetsDirectional.only(top: 3.0),
                                                              child: Text(
                                                                widget.restaurant!.tags!.join(', ').toString(),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontStyle: FontStyle.normal),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.only(top: 5.0),
                                                        child: Text(
                                                          widget.restaurant!.partnerAddress!,
                                                          style: const TextStyle(
                                                              color: greayLightColor,
                                                              fontSize: 10.0,
                                                              fontWeight: FontWeight.w400,
                                                              fontStyle: FontStyle.normal),
                                                          textAlign: TextAlign.start,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                                                        child: DesignConfig.divider(),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          double.parse(widget.restaurant!.partnerRating!).toStringAsFixed(1)=="0.0"?const SizedBox.shrink():InkWell(
                                                            onTap: () {
                                                              Navigator.of(context).pushNamed(Routes.partnerRating,
                                                                  arguments: {'partnerId': widget.restaurant!.partnerId!});
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SvgPicture.asset(DesignConfig.setSvgPath("rating"),
                                                                    fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                                const SizedBox(width: 5.0),
                                                                Text(
                                                                    "${double.parse(widget.restaurant!.partnerRating!).toStringAsFixed(1)} (${widget.restaurant!.noOfRatings!})",
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.w500,
                                                                        fontStyle: FontStyle.normal,
                                                                        overflow: TextOverflow.ellipsis)),
                                                              ],
                                                            ),
                                                          ),
                                                          double.parse(widget.restaurant!.partnerRating!).toStringAsFixed(1)=="0.0"?const SizedBox.shrink():SizedBox(width: width! / 20.0),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SvgPicture.asset(DesignConfig.setSvgPath("time_filled"),
                                                                  fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                widget.restaurant!.partnerCookTime!.replaceAll(regex, ''),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontStyle: FontStyle.normal,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: width! / 20.0),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SvgPicture.asset(DesignConfig.setSvgPath("km"),
                                                                  fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                widget.restaurant!.partnerCookTime!.replaceAll(regex, ''),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontStyle: FontStyle.normal,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 2,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                            restaurantClosedWidget(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    expandedHeight: expandHeight,
                                  );
                                }),
                              ];
                            },
                            body: Padding(
                                  padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 80.0),
                                  child: /* Text(
                          state.errorMessage,
                          textAlign: TextAlign.center,
                        ) */const SizedBox.shrink(),
                          ));
                      }
                      if (state is RestaurantCuisineSuccess) {
                      final categoryList = state.restaurantCuisineList;

                      /*final productList =
                          (state as ProductSuccess).productModel;
                      datalist = {};
                      List<ProductDetails> maindata = productList.data!;
                      for (ProductDetails data in maindata) {
                        List<ProductDetails> list = [];
                        if (datalist.containsKey(data.categoryId)) {
                          list = datalist[data.categoryId]!;
                        }

                        list.add(data);
                        datalist[data.categoryId!] = list;
                      }*/

                      // final hasMore = state.hasMore;
                      return DefaultTabController(
                        length: categoryList.length,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: _onScrollNotification,
                          child: NestedScrollView(
                            // controller: controllerProductViewAll,
                            controller: scontroller,
                            headerSliverBuilder: (context, innerBoxIsScrolled) {
                              return [
                                SliverLayoutBuilder(builder: (context, constraints) {
                                  return SliverAppBar(
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Theme.of(context).colorScheme.surface,
                                    systemOverlayStyle: constraints.scrollOffset >= 200 ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
                                    iconTheme: IconThemeData(
                                      color: constraints.scrollOffset >= 200
                                          ? Theme.of(context).colorScheme.onSecondary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                    floating: false,
                                    pinned: true,
                                    //automaticallyImplyLeading: _isVisible,
                                    leading: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsetsDirectional.all(3.5),
                                        margin: EdgeInsetsDirectional.only(top: 12, bottom: 12, start: width! / 20.0),
                                        decoration: DesignConfig.boxDecorationContainer(
                                            constraints.scrollOffset >= 350
                                                ? Theme.of(context).colorScheme.onSurface
                                                : greayLightColor.withOpacity(0.70),
                                            5.0),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: constraints.scrollOffset >= 350
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(Routes.productSearch, arguments: {
                                            "partnerId": widget.restaurant!.partnerId!,
                                            "partnerName": widget.restaurant!.partnerName!
                                          });
                                        },
                                        child: Container(
                                            padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top:3.5, bottom: 3.5),
                                        margin: EdgeInsetsDirectional.only(top: 12, bottom: 12, start: width! / 20.0),
                                            decoration: DesignConfig.boxDecorationContainer(
                                                constraints.scrollOffset >= 350
                                                    ? Theme.of(context).colorScheme.onSurface
                                                    : greayLightColor.withOpacity(0.70),
                                                5.0),
                                            child: SvgPicture.asset(DesignConfig.setSvgPath("search_icon"),
                                                colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                                                fit: BoxFit.scaleDown,
                                                width: 18.0,
                                                height: 18.3)),
                                      ),
                                      BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                        return BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
                                          create: (context) => UpdateRestaurantFavoriteStatusCubit(),
                                          child: Builder(builder: (context) {
                                            return BlocBuilder<FavoriteRestaurantsCubit, FavoriteRestaurantsState>(
                                                bloc: context.read<FavoriteRestaurantsCubit>(),
                                                builder: (context, favoriteRestaurantState) {
                                                  if (favoriteRestaurantState is FavoriteRestaurantsFetchSuccess) {
                                                    //check if restaurant is favorite or not
                                                    bool isRestaurantFavorite =
                                                        context.read<FavoriteRestaurantsCubit>().isRestaurantFavorite(widget.restaurant!.partnerId!);
                                                    return BlocConsumer<UpdateRestaurantFavoriteStatusCubit, UpdateRestaurantFavoriteStatusState>(
                                                      bloc: context.read<UpdateRestaurantFavoriteStatusCubit>(),
                                                      listener: ((context, state) {
                                                        //
                                                        if (state is UpdateRestaurantFavoriteStatusFailure) {
                                                          if (state.errorStatusCode.toString() == "102") {
                                                            reLogin(context);
                                                          }
                                                        }
                                                        if (state is UpdateRestaurantFavoriteStatusSuccess) {
                                                          //
                                                          if (state.wasFavoriteRestaurantProcess) {
                                                            context.read<FavoriteRestaurantsCubit>().addFavoriteRestaurant(state.restaurant);
                                                          } else {
                                                            //
                                                            context.read<FavoriteRestaurantsCubit>().removeFavoriteRestaurant(state.restaurant);
                                                          }
                                                        }
                                                      }),
                                                      builder: (context, state) {
                                                        if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                          return Container(
                                                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top:3.5, bottom: 3.5),
                                                              margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12, start: 10.0, end: 10.0),
                                                              decoration: DesignConfig.boxDecorationContainer(
                                                                  constraints.scrollOffset >= 350
                                                                      ? Theme.of(context).colorScheme.onSurface
                                                                      : greayLightColor.withOpacity(0.70),
                                                                  5.0),
                                                              child: CircularProgressIndicator(
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ));
                                                        }
                                                        return Container(
                                                          alignment: Alignment.center,
                                                          padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top:3.5, bottom: 3.5),
                                                          margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12, start: 10.0, end: 12.0),
                                                          decoration: DesignConfig.boxDecorationContainer(
                                                              constraints.scrollOffset >= 350
                                                                  ? Theme.of(context).colorScheme.onSurface
                                                                  : greayLightColor.withOpacity(0.70),
                                                              5.0),
                                                          child: InkWell(
                                                              onTap: () {
                                                                //
                                                                if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                                  return;
                                                                }
                                                                if (isRestaurantFavorite) {
                                                                  context.read<UpdateRestaurantFavoriteStatusCubit>().unFavoriteRestaurant(
                                                                      userId: context.read<AuthCubit>().getId(),
                                                                      type: partnersKey,
                                                                      restaurant: widget.restaurant!);
                                                                } else {
                                                                  //
                                                                  context.read<UpdateRestaurantFavoriteStatusCubit>().favoriteRestaurant(
                                                                      userId: context.read<AuthCubit>().getId(),
                                                                      type: partnersKey,
                                                                      restaurant: widget.restaurant!);
                                                                }
                                                              },
                                                              child: isRestaurantFavorite
                                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("wishlist-filled"),
                                                                      fit: BoxFit.scaleDown,
                                                                      width: 18.0,
                                                                      height: 18.3,
                                                                      colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                                          ? Theme.of(context).colorScheme.primary
                                                                          : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))
                                                                  : SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                                      fit: BoxFit.scaleDown,
                                                                      width: 18.0,
                                                                      height: 18.3,
                                                                      colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                                          ? Theme.of(context).colorScheme.primary
                                                                          : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
                                                        );
                                                      },
                                                    );
                                                  }
                                                  //if some how failed to fetch favorite restaurants or still fetching the restaurants
                                                  return Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top:3.5, bottom: 3.5),
                                                    margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12, start: 10.0, end: 10.0),
                                                    decoration: DesignConfig.boxDecorationContainer(
                                                        constraints.scrollOffset >= 350
                                                            ? Theme.of(context).colorScheme.onSurface
                                                            : greayLightColor.withOpacity(0.70),
                                                        5.0),
                                                    child: InkWell(
                                                        onTap: () {
                                                          if (favoriteRestaurantState is FavoriteRestaurantsFetchFailure) {
                                                            if (favoriteRestaurantState.errorStatusCode.toString() == "102") {
                                                              reLogin(context);
                                                            }
                                                          }
                                                          if (context.read<AuthCubit>().state is AuthInitial ||
                                                              context.read<AuthCubit>().state is Unauthenticated) {
                                                            Navigator.of(context)
                                                                .pushNamed(Routes.login, arguments: {'from': 'restaurantFavourite'}).then((value) {
                                                              Future.delayed(Duration.zero, () async {
                                                                await context
                                                                    .read<FavoriteRestaurantsCubit>()
                                                                    .getFavoriteRestaurants(context.read<AuthCubit>().getId(), partnersKey);
                                                              });
                                                              Future.delayed(Duration.zero, () async {
                                                                await context
                                                                    .read<FavoriteProductsCubit>()
                                                                    .getFavoriteProducts(context.read<AuthCubit>().getId(), productsKey);
                                                              });
                                                              Future.delayed(Duration.zero, () async {
                                                                context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
                                                              });
                                                            });
                                                            return;
                                                          }
                                                        },
                                                        child: SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                            fit: BoxFit.scaleDown,
                                                            width: 18.0,
                                                            height: 18.3,
                                                            colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350
                                                                ? Theme.of(context).colorScheme.primary
                                                                : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))
                                                        /*? const Icon(Icons.favorite, size: 18, color: red)
                                                                      : const Icon(Icons.favorite_border, size: 18, color: red)*/
                                                        ),
                                                  );
                                                });
                                          }),
                                        );
                                      }),
                                    ],
                                    flexibleSpace: FlexibleSpaceBar(
                                      centerTitle: false,
                                      //titlePadding: const EdgeInsetsDirectional.only(bottom: 50),
                                      title: constraints.scrollOffset >= 200
                                          ? Text(widget.restaurant!.partnerName!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal))
                                          : const SizedBox(),
                                      collapseMode: CollapseMode.pin,
                                      background: Padding(
                                        padding: const EdgeInsetsDirectional.only(top: 0),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(10.0),
                                                bottomRight: Radius.circular(10.0),
                                              ),
                                              child: ShaderMask(
                                                  shaderCallback: (Rect bounds) {
                                                    return LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Theme.of(context).colorScheme.onSecondary.withOpacity(0.25),
                                                        Theme.of(context).colorScheme.onSecondary.withOpacity(0.25)
                                                      ],
                                                    ).createShader(bounds);
                                                  },
                                                  blendMode: BlendMode.darken,
                                                  child: ColorFiltered(
                                                    //colorFilter: maindata[0].partnerDetails![0].isRestroOpen == "1"
                                                    colorFilter: widget.restaurant!.isRestroOpen == "1"
                                                        ? ColorFilter.mode(
                                                            Theme.of(context).colorScheme.onSecondary.withOpacity(0.70),
                                                            BlendMode.multiply,
                                                          )
                                                        : const ColorFilter.mode(
                                                            Colors.grey,
                                                            BlendMode.saturation,
                                                          ),
                                                    child: DesignConfig.imageWidgets(widget.restaurant!.partnerProfile!, height! / 2.5, width!, "2"),
                                                  )),
                                            ),
                                            Positioned.directional(
                                              textDirection: Directionality.of(context),
                                              bottom: height! / 40.0,//height! / 6.9,
                                              start: width! / 20.0,
                                              end: width! / 20.0,
                                              child: Container(
                                                width: width,
                                                padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, bottom: 10.0, top: 10.0),
                                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(widget.restaurant!.partnerName!,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w700,
                                                                    fontStyle: FontStyle.normal,
                                                                  )),
                                                              SizedBox(width: width! / 50.0),
                                                              widget.restaurant!.partnerIndicator == "1"
                                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                                  : widget.restaurant!.partnerIndicator == "2"
                                                                      ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                          width: 15, height: 15)
                                                                      : Row(
                                                                          children: [
                                                                            SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"),
                                                                                width: 15, height: 15),
                                                                            const SizedBox(width: 2.0),
                                                                            SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                                width: 15, height: 15),
                                                                          ],
                                                                        ),
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                        ],
                                                      ),
                                                      widget.restaurant!.tags!.isNotEmpty
                                                          ? Padding(
                                                              padding: const EdgeInsetsDirectional.only(top: 3.0),
                                                              child: Text(
                                                                widget.restaurant!.tags!.join(', ').toString(),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontStyle: FontStyle.normal),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.only(top: 5.0),
                                                        child: Text(
                                                          widget.restaurant!.partnerAddress!,
                                                          style: const TextStyle(
                                                              color: greayLightColor,
                                                              fontSize: 10.0,
                                                              fontWeight: FontWeight.w400,
                                                              fontStyle: FontStyle.normal),
                                                          textAlign: TextAlign.start,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                                                        child: DesignConfig.divider(),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          double.parse(widget.restaurant!.partnerRating!).toStringAsFixed(1)=="0.0"?const SizedBox.shrink():InkWell(
                                                            onTap: () {
                                                              Navigator.of(context).pushNamed(Routes.partnerRating,
                                                                  arguments: {'partnerId': widget.restaurant!.partnerId!});
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SvgPicture.asset(DesignConfig.setSvgPath("rating"),
                                                                    fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                                const SizedBox(width: 5.0),
                                                                Text(
                                                                    "${double.parse(widget.restaurant!.partnerRating!).toStringAsFixed(1)} (${widget.restaurant!.noOfRatings!})",
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.w500,
                                                                        fontStyle: FontStyle.normal,
                                                                        overflow: TextOverflow.ellipsis)),
                                                              ],
                                                            ),
                                                          ),
                                                          double.parse(widget.restaurant!.partnerRating!).toStringAsFixed(1)=="0.0"?const SizedBox.shrink():SizedBox(width: width! / 20.0),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SvgPicture.asset(DesignConfig.setSvgPath("time_filled"),
                                                                  fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                widget.restaurant!.partnerCookTime!.replaceAll(regex, ''),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontStyle: FontStyle.normal,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: width! / 20.0),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SvgPicture.asset(DesignConfig.setSvgPath("km"),
                                                                  fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                widget.restaurant!.distance!.replaceAll(regex, ''),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontStyle: FontStyle.normal,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 2,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                            restaurantClosedWidget(),
                                            /*Positioned.directional(textDirection: Directionality.of(context),
                                            top: height!/2.35,
                                            start: 0,
                                            child: Container(alignment: Alignment.center,decoration: DesignConfig.boxDecorationContainer(white, 10.0), width: width!, height: 80, child: Padding(
                                              padding: EdgeInsetsDirectional.only(start: width!/2.5),
                                              child: Text("Currently not available for delivery", maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold)),
                                            )),),
                                            Positioned.directional(textDirection: Directionality.of(context),
                                            top: height!/2.61,
                                            start: width!/6.8,
                                            child: Container(height: 20, width: 20, decoration: DesignConfig.boxDecorationContainer(white, 10))),
                                            Positioned.directional(textDirection: Directionality.of(context),
                                            top: height!/2.62,
                                            start: width!/22.0,
                                            child: Lottie.asset(DesignConfig.setLottiePath("closed_restaurents"), height: height!/9.0, width: width!/4.0)),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                    expandedHeight: expandHeight,
                                  );
                                }),
                                SliverPersistentHeader(
                                  floating: false,
                                  delegate: SliverAppBarDelegate(
                                    TabBar(
                                      indicatorWeight: 2.0,
                                      onTap: (int val) {
                                        //VerticalScrollableTabBarStatus.setIndex(val);
                                        print("test===$val");
                                        setState(() {
                                          selectedIndex = val;
                                          categoryId = state.restaurantCuisineList[val].id;
                                          Future.delayed(const Duration(milliseconds: 500), () {
                                            _firstLoad();
                                          });
                                        });
                                      },
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      isScrollable: true,
                                      labelColor: white,
                                      unselectedLabelColor: Theme.of(context).colorScheme.onSecondary.withOpacity(0.50),
                                      indicatorColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      controller: tabController,labelPadding: EdgeInsetsDirectional.zero,
                                      indicator: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 5.0),
                                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      tabs: categoryList
                                          .map((t) => Container(margin: EdgeInsetsDirectional.only(start: width!/40.0, end: width!/40.0),padding: const EdgeInsetsDirectional.only(start: 20, end: 20),decoration: categoryId==t.id?DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 5.0):DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, commentBoxBorderColor.withOpacity(0.50), 5.0),
                                            child: Tab(
                                                  text: t.name,
                                                ),
                                          ))
                                          .toList(),
                                    ),
                                  ),
                                  pinned: true,
                                ),
                              ];
                            },
                            body: BlocBuilder<ProductLoadCubit, ProductLoadCubitState>(builder: (context, state) {
                              return Padding(
                                  padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 80.0),
                                  child: listWidget(state));
                            }),
                          ),
                        ),
                      );} return const SizedBox();
                    }),
              ),
            ),
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      // ScrollDirection direction = notification.direction;
      ScrollDirection direction = scontroller.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _hasNextPage) {
        _loadMore();
      }
    }
    return true;
  }

  listWidget(ProductLoadCubitState state) {
    _hasNextPage = false;
    if (state is ProductLoadCubitProgress) {
      //return const Center(child: CircularProgressIndicator(color: red));
      return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
    }
    if (state is ProductLoadCubitInitial) {
      //return const Center(child: CircularProgressIndicator(color: red));
      return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
    }
    if (state is ProductLoadCubitFailure) {
      return Center(child: Text(state.errorMessage));
    }
    if (state is ProductLoadCubitSuccess) {
      total = state.totalData;

      _isFirstLoadRunning = false;
      _isLoadMoreRunning = false;

      if (int.parse(propbody[offsetKey] ?? "0") == 0) {
        myPropertylist.clear();
      }
      myPropertylist.addAll(state.productList);
      if (total > myPropertylist.length) {
        offset = int.parse(propbody[offsetKey]) + plimit;
        propbody[offsetKey] = offset.toString();
        _hasNextPage = true;
      }
    }
    if (state is ProductLoadCubitFailure && total == 0) {
      _isFirstLoadRunning = false;
      _isLoadMoreRunning = false;
      return Center(child: Text(state.errorMessage));
    } else if (_isFirstLoadRunning) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }
    bool isShowProgress = offset != 0 && state is ProductProgress;

    return showPropertiesList(isShowProgress);
  }

  Widget showPropertiesList(bool isloading) {
    int totallen = isloading ? myPropertylist.length + 1 : myPropertylist.length;
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: totallen,
        itemBuilder: ((context, index) {
          if (index == myPropertylist.length) {
            return CircularProgressIndicator(color: Theme.of(context).colorScheme.primary);
          }

          ProductDetails dataItem = myPropertylist[index];
          double price = double.parse(dataItem.variants![0].specialPrice!);
          if (price == 0) {
            price = double.parse(dataItem.variants![0].price!);
          }
          double off = 0;
          if (dataItem.variants![0].specialPrice! != "0") {
            off = (double.parse(dataItem.variants![0].price!) - double.parse(dataItem.variants![0].specialPrice!)).toDouble();
            off = off * 100 / double.parse(dataItem.variants![0].price!).toDouble();
          }
          return offset > 0 && _isLoadMoreRunning == true && index == (myPropertylist.length - 1)
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
              : ProductItemContainer(
                  dataItem: dataItem, i: index, width: width!, height: height!, price: price, off: off, dataMainList: myPropertylist);
        }));
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 20.0, end: 0.0, top: 8.0, bottom: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

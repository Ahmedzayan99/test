// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteRestaurant.dart';
import 'package:project1/cubit/home/restaurants/restaurantCubit.dart';
import 'package:project1/cubit/product/ProductViewAllCubit.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project1/utils/internetConnectivity.dart';

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
  ScrollController controllerProduct = ScrollController();
  ScrollController controllerProductViewAll = ScrollController();
  String currcateid = "";
  late ProductDetails currproductlist;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  var db = DatabaseHelper();
  String? categoryId = "";

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
    productApi();
    cartApi();
    restaurantApi();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    tabController!.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  scrollListener() {
    if (context.read<ProductViewAllCubit>().hasMoreData()) {
      context.read<ProductViewAllCubit>().fetchMoreProductData(
          perPage,
          widget.restaurant!.partnerId,
          context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
          context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
          context.read<AuthCubit>().getId(),
          context.read<CityDeliverableCubit>().getCityId(),
          categoryId);
    }
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
        qty = int.parse(productDetailsModel.variants![currentIndex].cartCount!);
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

  cartApi() {
    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
  }

  productListApi() {
    context.read<ProductViewAllCubit>().fetchProduct(
        perPage,
        widget.restaurant!.partnerId,
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<AuthCubit>().getId(),
        context.read<CityDeliverableCubit>().getCityId(),
        categoryId);
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
    productApi();
    cartApi();
    restaurantApi();
    productListApi();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    expandHeight = height! / 2.8;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
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
                              ? Container(
                                  height: 0.0,
                                )
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
                            return const Text(
                              /*state.errorMessage.toString()*/ "",
                              textAlign: TextAlign.center,
                            );
                          }
                          final cartList = (state as GetCartSuccess).cartModel;
                          var sum = 0;
                          final currentCartModel = context.read<GetCartCubit>().getCartModel();
                          for (int i = 0; i < currentCartModel.data!.length; i++) {
                            sum += int.parse(currentCartModel.data![i].qty!);
                          }
                          return cartList.data!.isEmpty
                              ? Container()
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
                                          Text(context.read<SystemConfigCubit>().getCurrency() + cartList.overallAmount.toString(),
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
                child: BlocConsumer<ProductCubit, ProductState>(
                    bloc: context.read<ProductCubit>(),
                    listener: (context, state) {
                      if (state is ProductSuccess) {
                        tabController = TabController(length: state.productModel.categories!.length, vsync: this);
                        tabController!.addListener(() {
                          selectedIndex = tabController!.index;
                          categoryId = state.productModel.categories![selectedIndex].id;
                          productListApi();
                        });
                        categoryId = state.productModel.categories![selectedIndex].id;
                        productListApi();
                      }
                    },
                    builder: (context, state) {
                      if (state is ProductProgress || state is ProductInitial) {
                        return RestaurantDetailSimmer(width: width!, height: height!);
                      }
                      if (state is ProductFailure) {
                        return Center(
                            child: Text(
                          state.errorMessage.toString(),
                          textAlign: TextAlign.center,
                        ));
                      }
                      final productList = (state as ProductSuccess).productModel;

                      return DefaultTabController(
                        length: productList.categories!.length,
                        child: NestedScrollView(
                          headerSliverBuilder: (context, innerBoxIsScrolled) {
                            return [
                              SliverLayoutBuilder(builder: (context, constraints) {
                                return SliverAppBar(
                                  shadowColor: Colors.transparent,
                                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                                  systemOverlayStyle: constraints.scrollOffset >= 200 ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
                                  iconTheme: IconThemeData(
                                    color: constraints.scrollOffset >= 200 ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onSurface,
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
                                          constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.onSurface : greayLightColor.withOpacity(0.70), 5.0),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Routes.productSearch,
                                            arguments: {"partnerId": widget.restaurant!.partnerId!, "partnerName": widget.restaurant!.partnerName!});
                                      },
                                      child: Container(
                                          padding: const EdgeInsetsDirectional.all(3.5),
                                          margin: const EdgeInsetsDirectional.only(top: 12, bottom: 12),
                                          decoration: DesignConfig.boxDecorationContainer(
                                              constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.onSurface : greayLightColor.withOpacity(0.70), 5.0),
                                          child: SvgPicture.asset(DesignConfig.setSvgPath("search_icon"),
                                              colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
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
                                                                    colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))
                                                                : SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                                    fit: BoxFit.scaleDown,
                                                                    width: 18.0,
                                                                    height: 18.3,
                                                                    colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
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
                                                      constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.onSurface : greayLightColor.withOpacity(0.70),
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
                                                          colorFilter: ColorFilter.mode(constraints.scrollOffset >= 350 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
                                                );
                                              });
                                        }),
                                      );
                                    }),
                                  ],
                                  flexibleSpace: FlexibleSpaceBar(
                                    centerTitle: false,
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
                                                    colors: [Theme.of(context).colorScheme.onSecondary.withOpacity(0.25), Theme.of(context).colorScheme.onSecondary.withOpacity(0.25)],
                                                  ).createShader(bounds);
                                                },
                                                blendMode: BlendMode.darken,
                                                child: ColorFiltered(
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
                                                                    ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
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
                                                        InkWell(
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
                                                        SizedBox(width: width! / 20.0),
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
                                    //onTap: (int val) {},
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    isScrollable: true,
                                    labelColor: white,
                                    unselectedLabelColor: Theme.of(context).colorScheme.onSecondary,
                                    indicatorColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    controller: tabController,
                                    indicator: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 10.0),
                                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    tabs: productList.categories!
                                        .map((t) => Tab(
                                              text: t.name,
                                            ))
                                        .toList(),
                                  ),
                                ),
                                pinned: true,
                              ),
                            ];
                          },
                          body: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollEndNotification) {
                                if (/* notification.metrics.maxScrollExtent */notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                                  print('====${notification.metrics.pixels}===${notification.metrics.maxScrollExtent}');
                                  scrollListener();
                                  return true;
                                }
                              }
                              return true;
                            },
                            child: BlocConsumer<ProductViewAllCubit, ProductViewAllState>(
                              bloc: context.read<ProductViewAllCubit>(),
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is ProductViewAllProgress || state is ProductViewAllInitial) {
                                  return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
                                }
                                if (state is ProductViewAllFailure) {
                                  return Center(child: Text(state.errorMessage));
                                }
                                final productViewAllList = (state as ProductViewAllSuccess).productList;
                                final hasMore = state.hasMore;
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      /* bottom: height! / 99.0 */ start: width! / 40.0, end: width! / 40.0, top: height! / 40.0),
                                  child: TabBarView(
                                    controller: tabController,
                                    children: productList.categories!.map<Widget>((dynamicContent) {
                                      return SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                              children: List.generate(productViewAllList.length, (i) {
                                        ProductDetails dataItem = productViewAllList[i];
                                        double price = double.parse(dataItem.variants![0].specialPrice!);
                                        if (price == 0) {
                                          price = double.parse(dataItem.variants![0].price!);
                                        }
                                        double off = 0;
                                        if (dataItem.variants![0].specialPrice! != "0") {
                                          off = (double.parse(dataItem.variants![0].price!) - double.parse(dataItem.variants![0].specialPrice!))
                                              .toDouble();
                                          off = off * 100 / double.parse(dataItem.variants![0].price!).toDouble();
                                        }
                                        return hasMore && i == (productViewAllList.length - 1)
                                            ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                                            : InkWell(
                                                onTap: () {},
                                                child: ProductItemContainer(
                                                    dataItem: productViewAllList[i],
                                                    i: i,
                                                    width: width!,
                                                    height: height!,
                                                    price: price,
                                                    off: off,
                                                    dataMainList: productViewAllList),
                                              );
                                      })));
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
    );
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
      padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 8.0, bottom: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/app.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/address/isOrderDeliverableCubit.dart';
import 'package:project1/cubit/cart/manageCartCubit.dart';
import 'package:project1/cubit/product/productLoadCubit.dart';
import 'package:project1/data/model/addressModel.dart';
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/cubit/address/addressCubit.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/address/deliveryChargeCubit.dart';
import 'package:project1/cubit/address/updateAddressCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/data/model/cartModel.dart';
import 'package:project1/data/repositories/cart/cartRepository.dart';
import 'package:project1/cubit/cart/clearCartCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/cart/removeFromCartCubit.dart';
import 'package:project1/data/model/addOnsDataModel.dart';
import 'package:project1/data/model/delivery_tip_model.dart';
import 'package:project1/data/model/productAddOnsModel.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/data/model/variantsModel.dart';
import 'package:project1/cubit/product/offlineCartCubit.dart';
import 'package:project1/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/styles/dashLine.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/utils/SqliteData.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/screen/offerCoupons/offer_coupons_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/simmer/addressSimmer.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/simmer/buttonSimmer.dart';
import 'package:project1/ui/widgets/simmer/cartSimmer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/restaurantCloseDialog.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project1/utils/internetConnectivity.dart';

class CartScreen extends StatefulWidget {
  final Function? bottomStatus;
  final String? from;
  const CartScreen({Key? key, this.bottomStatus, this.from}) : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

double finalTotal = 0,
    subTotal = 0,
    overAllAmount = 0,
    deliveryCharge = 0,
    taxPercentage = 0,
    taxAmount = 0,
    deliveryTip = 0,
    latitude = 0,
    longitude = 0;
int? selectedAddress = 0, orderTypeIndex = 0;
String? selAddress, paymentMethod = '', selTime, selDate, promoCode = '';
bool? isTimeSlot, isPromoValid = false, isUseWallet = false, isPayLayShow = true;
int? selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal = 0, walletBalanceUsed = 0;
bool isAvailable = true;
Map? productVariant;
Map? productVariantData;
List<String>? productVariantId = [];
List<String>? productAddOnId = [];

String? razorpayId,
    paystackId,
    stripeId,
    stripeSecret,
    stripeMode = "test",
    stripeCurCode,
    stripePayId,
    paytmMerId,
    paytmMerKey,
    midTranshMerchandId,
    midtransPaymentMethod,
    midtransPaymentMode,
    midtransServerKey,
    midtrasClientKey,
    phonePeMode,
    phonePeMerId,
    phonePeSaltIndex,
    phonePeSaltKey,
    phonePeEndPointUrl,
    appId;
bool payTesting = true;

class CartScreenState extends State<CartScreen> {
  double? width, height;
  TextEditingController addNoteController = TextEditingController(text: "");
  TextEditingController deliveryTipController = TextEditingController(text: "");
  int? selectedIndex = -1, addressIndex;
  //final ScrollController _scrollBottomBarController = ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75, oriPrice = 0; // set bottom bar height

  String activeStatus = "pending";
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  CartModel? cartModel;
  String addressId = "";
  String isRestaurantOpen = "", restaurantName = "", restaurantAddress = "", restaurantCookTime = "";
  //String promoCode = '';
  //double promoAmt = 0;
  bool? tipOther = false, cartEmpty = false;
  var db = DatabaseHelper();
  String pickupStatus = "", deliveryStatus = "";
  List<String> availableTime = [];
  List<bool> checkTime = [];
  int status = 0;
/*  Map? productVariant;
  List<String>? productVariantId = [];
  List<String>? productAddOnId = [];*/

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
    //getUserLocation();
    deliveryTipController.addListener(() {
      //String text = deliveryTipController.text;
      //here you have the changes of your textfield
      deliveryTipController;
      //use setState to rebuild the widget
      setState(() {});
    });
    if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
    }
    //context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
    if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      Future.delayed(Duration.zero, () {}).then((value) {
        context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
      });
    }
    /* Future.delayed(Duration.zero, () {}).then((value) {
      context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    }); */

    getOffLineCart();
    //myScroll(_scrollBottomBarController, context);
    Future.delayed(const Duration(microseconds: 1000), () {}).then((value) {
      restaurantName = UiUtils.getTranslatedLabel(context, myCartLabel);
    });
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  bottomStatusUpdate() {
    setState(() {
      widget.bottomStatus!(0);
    });
  }

  Future<void> getOffLineCart() async {
    await context.read<OfflineCartCubit>().getOfflineCart(
        latitude: context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        longitude: context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        cityId: context.read<CityDeliverableCubit>().getCityId(),
        productVariantIds: productVariantId!.join(','));
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productVariant = (await db.getCart());
      productVariantData = (await db.getCartData());
      if (productVariant!.isEmpty) {
      } else {
        productVariantId = productVariant!['VID'];
        //productAddOnId = productVariant!['ADDONID'];
        productAddOnId = productVariant!['ADDONID'].toString().replaceAll("[", "").replaceAll("]", "").split(",");
        if (productVariantId!.isNotEmpty) {
          if (mounted) {
            await context.read<OfflineCartCubit>().getOfflineCart(
                latitude: context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
                longitude: context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
                cityId: context.read<CityDeliverableCubit>().getCityId(),
                productVariantIds: productVariantId!.join(','));
          }
          cartEmpty = false;
        } else {
          cartEmpty = true;
        }
      }
    }
  }

  Widget addNote() {
    return Container(
        alignment: Alignment.center,
        decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
        padding: EdgeInsetsDirectional.only(start: width! / 20.0),
        child: Center(
          child: TextField(
            controller: addNoteController,
            cursorColor: lightFont,
            decoration: InputDecoration(
              contentPadding: EdgeInsetsDirectional.zero,
              border: InputBorder.none,
              hintText: UiUtils.getTranslatedLabel(context, addNotesForFoodPartnerLabel),
              hintStyle: const TextStyle(
                color: lightFont,
                fontSize: 14.0,
              ),
            ),
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: lightFont,
              fontSize: 14.0,
            ),
          ),
        ));
  }

  Widget deliveryTips() {
    return Container(
        height: height! / 15.4,
        width: width!,
        margin: EdgeInsetsDirectional.only(start: width! / 40.0, bottom: height! / 50.0),
        child: Row(
          children: [
            tipOther == false
                ? Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deliveryTipList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, index) {
                          return InkWell(
                              splashFactory: NoSplash.splashFactory,
                              onTap: () {
                                /*setState(() {
                                  selectedIndex = index;
                                });*/
                                if (selectedIndex == index) {
                                  setState(() {
                                    deliveryTipList[index].like = "0";
                                    selectedIndex = -1;
                                    deliveryTip = 0;
                                  });
                                } else {
                                  setState(() {
                                    deliveryTipList[index].like = "1";
                                    selectedIndex = index;
                                    deliveryTip = double.parse(deliveryTipList[index].price!);
                                  });
                                }
                                //print("like:" + deliveryTipList[index].like.toString());
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: width! / 7.0,
                                padding: EdgeInsetsDirectional.only(
                                  top: height! / 55.0,
                                  bottom: height! / 55.0,
                                  end: width! / 99.0,
                                  start: width! / 99.0,
                                ),
                                margin: EdgeInsetsDirectional.only(end: width! / 32.0),
                                decoration: deliveryTip == double.parse(deliveryTipList[index].price!)
                                    ? DesignConfig.boxDecorationContainerBorder(
                                        Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.10), 10.0)
                                    : DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
                                child: Text(context.read<SystemConfigCubit>().getCurrency() + deliveryTipList[index].price!,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: deliveryTip == double.parse(deliveryTipList[index].price!)
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ));
                        }),
                  )
                : const SizedBox(),
            InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  setState(() {
                    if (tipOther == false) {
                      tipOther = true;
                      deliveryTipController.clear();
                    } else {
                      tipOther = false;
                      deliveryTipController.clear();
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: width! / 7.0,
                  padding: EdgeInsetsDirectional.only(
                    top: height! / 55.0,
                    bottom: height! / 55.0,
                    end: width! / 99.0,
                    start: width! / 99.0,
                  ),
                  margin: EdgeInsetsDirectional.only(end: width! / 25.0),
                  decoration: tipOther == true
                      ? DesignConfig.boxDecorationContainerBorder(
                          Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.10), 10.0)
                      : DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
                  child: Text(UiUtils.getTranslatedLabel(context, otherLabel),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                          color: tipOther == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                )),
            tipOther == true
                ? Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsetsDirectional.only(
                              //start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            padding: EdgeInsetsDirectional.only(start: width! / 20.0, bottom: height! / 99.0),
                            child: TextField(
                              controller: deliveryTipController,
                              cursorColor: lightFont,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: StringsRes.addTip,
                                hintStyle: const TextStyle(
                                  color: lightFont,
                                  fontSize: 14.0,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(
                                color: lightFont,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (deliveryTipController.text.trim().isNotEmpty) {
                                deliveryTip = double.parse(deliveryTipController.text.trim());
                                selectedIndex = -1;
                                tipOther = false;
                              } else {
                                UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, deliveryTipLabel), StringsRes.addTip, context, false,
                                    type: "2");
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 4.0),
                            child: Text(
                              deliveryTipController.text.trim().isNotEmpty
                                  ? UiUtils.getTranslatedLabel(context, addLabel)
                                  : UiUtils.getTranslatedLabel(context, cancelLabel),
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox()
          ],
        ));
  }

  bottomModelSheetShowEdit(List<ProductDetails> productList, int index, String variantId, int l) async {
    ProductDetails productDetailsModel = productList[index];
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![currentIndex].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productAddOnId = (await db.getVariantItemData(productDetailsModel.id!, variantId))!;
      productAddOnIds = productAddOnId!;
    } else {
      for (int i = 0; i < productDetailsModel.variants![currentIndex].addOnsData!.length; i++) {
        productAddOnIds.add(productDetailsModel.variants![currentIndex].addOnsData![i].id!);
      }
      for (int j = 0; j < productDetailsModel.variants!.length; j++) {
        if (j == l) {
          currentIndex = j;
          productVariantId = productDetailsModel.variants![currentIndex].id;
        }
      }
    }
    print("productAddOnId:$productAddOnIds-----$productAddOnId");

    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productVariantId = variantId;
      qty = int.parse((await db.checkCartItemExists(productDetailsModel.id!, variantId))!);
      if (qty == 0) {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);
      } else {
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
      qtyData[productVariantId!] = qty;
    }
    //qtyData[productVariantId] = qty;
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
              from: "cart");
        });
  }

  itemEditQtyBottomSheet(List<ProductDetails> productList, int j, String variantId, int i, List<Data> data, int l) async {
    ProductDetails productDetailsModel = productList[j];
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![currentIndex].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productAddOnId = (await db.getVariantItemData(productDetailsModel.id!, variantId))!;
      productAddOnIds = productAddOnId!;
    } else {
      for (int i = 0; i < productDetailsModel.variants![currentIndex].addOnsData!.length; i++) {
        productAddOnIds.add(productDetailsModel.variants![currentIndex].addOnsData![i].id!);
      }
    }

    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productVariantId = variantId;
      qty = int.parse((await db.checkCartItemExists(productDetailsModel.id!, variantId))!);
      if (qty == 0) {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);
      } else {
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
    //bool descTextShowFlag = false;
    //ProductDetails productDetailsModel = productList[i];
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
            double priceCurrent = double.parse(productDetailsModel.variants![currentIndex].specialPrice!);
            if (priceCurrent == 0) {
              priceCurrent = double.parse(productDetailsModel.variants![currentIndex].price!);
            }

            double offCurrent = 0;
            if (productDetailsModel.variants![currentIndex].specialPrice! != "0") {
              offCurrent = (double.parse(productDetailsModel.variants![currentIndex].price!) -
                      double.parse(productDetailsModel.variants![currentIndex].specialPrice!))
                  .toDouble();
              offCurrent = offCurrent * 100 / double.parse(productDetailsModel.variants![currentIndex].price!).toDouble();
            }
            for (int k = 0; k < productDetailsModel.productAddOns!.length; k++) {
              ProductAddOnsModel productAddOnsModel = productDetailsModel.productAddOns![k];
              if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                //print(widget.productAddOnIds.toString() + "-" + data.id!);
                if (productAddOnIds.contains(productAddOnsModel.id)) {
                  isChecked[k] = true;
                  if (addOnIds.contains(productAddOnsModel.id!)) {
                    addOnIds.add(productAddOnsModel.id!);
                    addOnQty.add("1");
                    addOnPrice.add(double.parse(productAddOnsModel.price!));
                  }
                } else {
                  isChecked[k] = false;
                }
              } else {
                if (productAddOnIds.contains(productAddOnsModel.id)) {
                  isChecked[k] = true;
                  if (addOnIds.contains(productAddOnsModel.id!)) {
                    addOnIds.add(productAddOnsModel.id!);
                    addOnQty.add("1");
                    addOnPrice.add(double.parse(productAddOnsModel.price!));
                  }
                } else {
                  isChecked[k] = false;
                }
              }
            }
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      height: (MediaQuery.of(context).size.height) / 2.8,
                      padding: EdgeInsetsDirectional.only(top: height! / 15.0),
                      child: Container(
                        decoration: DesignConfig.boxDecorationContainerRoundHalf(Theme.of(context).colorScheme.onSurface, 25, 0, 25, 0),
                        child: Container(
                          padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      productDetailsModel.indicator == "1"
                                          ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                          : productDetailsModel.indicator == "2"
                                              ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                              : const SizedBox(),
                                      SizedBox(width: width! / 99.0),
                                      Expanded(
                                          child: Text(productDetailsModel.name!,
                                              textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal,
                                              ))),
                                      Text(context.read<SystemConfigCubit>().getCurrency() + priceCurrent.toString(),
                                          textAlign: TextAlign.left,
                                          style:
                                              TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                              Row(children: [
                                Expanded(
                                  child: ButtonContainer(
                                    color: Theme.of(context).colorScheme.secondary,
                                    height: height,
                                    width: width,
                                    text: UiUtils.getTranslatedLabel(context, addNewItemLabel),
                                    start: 0,
                                    end: width! / 40.0,
                                    bottom: height! / 55.0,
                                    top: 0,
                                    status: false,
                                    borderColor: Theme.of(context).colorScheme.secondary,
                                    textColor: white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      bottomModelSheetShowEdit(productList, j, variantId, l);
                                    },
                                  ),
                                ),
                                BlocConsumer<ManageCartCubit, ManageCartState>(
                                    bloc: context.read<ManageCartCubit>(),
                                    listener: (context, state) {
                                      print(state.toString());
                                      if (state is ManageCartFailure) {
                                        if (state.errorStatusCode.toString() == "102") {
                                          reLogin(context);
                                        }
                                      }
                                      if (state is ManageCartSuccess) {
                                        if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
                                          return;
                                        } else {
                                          final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                          context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(
                                              state.data,
                                              (int.parse(currentCartModel.totalQuantity ?? '0') + int.parse(state.totalQuantity!)).toString(),
                                              state.subTotal,
                                              state.taxPercentage,
                                              state.taxAmount,
                                              state.overallAmount,
                                              List.from(state.variantId ?? [])..addAll(currentCartModel.variantId ?? [])));
                                          print(currentCartModel.variantId);
                                          Navigator.pop(context);
                                          context.read<ValidatePromoCodeCubit>().getValidatePromoCode(promoCode, context.read<AuthCubit>().getId(),
                                              state.overallAmount!.toStringAsFixed(2), walletBalanceUsed.toString(), context.read<GetCartCubit>().cartPartnerId());
                                        }
                                      } else if (state is ManageCartFailure) {
                                        if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
                                          return;
                                        } else {
                                          Navigator.pop(context);
                                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addToCartLabel), state.errorMessage, context, false,
                                              type: "2");
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return Expanded(
                                        child: ButtonContainer(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          height: height,
                                          width: width,
                                          text: UiUtils.getTranslatedLabel(context, repeatItemLabel),
                                          start: 0,
                                          end: width! / 99.0,
                                          bottom: height! / 55.0,
                                          top: 0,
                                          status: false,
                                          borderColor: Theme.of(context).colorScheme.secondary,
                                          textColor: Theme.of(context).colorScheme.onSecondary,
                                          onPressed: () {
                                            setState(() {
                                              if (qty < int.parse(productDetailsModel.minimumOrderQuantity!)) {
                                                Navigator.pop(context);
                                                UiUtils.setSnackBar(
                                                    UiUtils.getTranslatedLabel(context, quantityLabel),
                                                    "${StringsRes.minimumQuantityAllowed} ${productDetailsModel.minimumOrderQuantity!}",
                                                    context,
                                                    false,
                                                    type: "2");
                                              } else if (qty > int.parse(productDetailsModel.totalAllowedQuantity!)) {
                                                Navigator.pop(context);
                                                UiUtils.setSnackBar(
                                                    UiUtils.getTranslatedLabel(context, quantityLabel),
                                                    "${StringsRes.maximumQuantityAllowed} ${productDetailsModel.totalAllowedQuantity!}",
                                                    context,
                                                    false,
                                                    type: "2");
                                              } else {
                                                if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                  db
                                                      .insertCart(
                                                          productList[j].id!,
                                                          variantId,
                                                          (qty + 1).toString(),
                                                          addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                          addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "",
                                                          priceCurrent.toString(), //productList[j].variants![l].price!,
                                                          productList[j].partnerDetails![0].partnerId!,
                                                          context)
                                                      .whenComplete(() async {
                                                    await getOffLineCart();
                                                  });
                                                  Navigator.pop(context);
                                                } else {
                                                  context.read<ManageCartCubit>().manageCartUser(
                                                      userId: context.read<AuthCubit>().getId(),
                                                      productVariantId: data[i].productVariantId,
                                                      isSavedForLater: "0",
                                                      qty: (int.parse(data[i].qty!) + 1).toString(),
                                                      addOnId: addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                      addOnQty: addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "");
                                                  Navigator.pop(context);
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    })
                              ])
                            ],
                          ),
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
                ],
              ),
            );
          });
        });
  }

  Stream<int> qtyOfflineCart(ProductDetails productModel, String productVariantId, int l) async* {
    int qty = 0;
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      qty = int.parse((await db.checkCartItemExists(productModel.id!, productVariantId))!);
    }
    yield qty;
  }

  bottomModelSheetShow() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      height: (MediaQuery.of(context).size.height) / 1.14,
                      padding: EdgeInsetsDirectional.only(top: height! / 15.0),
                      child: Container(
                        decoration: DesignConfig.boxDecorationContainerRoundHalf(Theme.of(context).colorScheme.onSurface, 25, 0, 25, 0),
                        child: Container(
                          padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 25.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: BlocProvider<UpdateAddressCubit>(
                                  create: (_) => UpdateAddressCubit(AddressRepository()),
                                  child: Builder(builder: (context) {
                                    return BlocConsumer<AddressCubit, AddressState>(
                                        bloc: context.read<AddressCubit>(),
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          if (state is AddressProgress || state is AddressInitial) {
                                            return AddressSimmer(width: width!, height: height!);
                                          }
                                          if (state is AddressFailure) {
                                            return /*Center(
                                                child: Text(
                                              state.errorCode.toString(),
                                              textAlign: TextAlign.center,
                                            ))*/
                                                NoDataContainer(
                                                    image: "address",
                                                    title: UiUtils.getTranslatedLabel(context, noAddressYetLabel),
                                                    subTitle: UiUtils.getTranslatedLabel(context, noAddressYetSubTitleLabel),
                                                    width: width!,
                                                    height: height!);
                                          }

                                          final addressList = (state as AddressSuccess).addressList;
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: addressList.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (BuildContext context, index) {
                                                return addressList.isNotEmpty
                                                    ? BlocConsumer<UpdateAddressCubit, UpdateAddressState>(
                                                        bloc: context.read<UpdateAddressCubit>(),
                                                        listener: (context, state) {
                                                          if (state is UpdateAddressSuccess) {
                                                            if (state.addressModel.id! == addressList[index].id!) {
                                                              context.read<AddressCubit>().updateAddress(state.addressModel);
                                                              //context.read<GetCartCubit>().setCartAddress(state.addressModel);
                                                              addressId = state.addressModel.id!;
                                                            }
                                                            if (addressId.isNotEmpty) {
                                                              context
                                                                  .read<DeliveryChargeCubit>()
                                                                  .fetchDeliveryCharge(context.read<AuthCubit>().getId(), addressId, context.read<GetCartCubit>().getCartModel().overallAmount.toString());
                                                            }
                                                            //context.read<DeliveryChargeCubit>().fetchDeliveryCharge(context.read<AuthCubit>().getId(), state.addressModel.id!);
                                                            //Navigator.pop(context);
                                                            //print(" User id ${context.read<DeliveryChargeCubit>().getDeliveryCharge()} id is ${state.addressModel.id!}");

                                                            //print("address:${context.read<DeliveryChargeCubit>().fetchDeliveryCharge(context.read<AuthCubit>().getId(), state.addressModel.id!)}");
                                                          } else if (state is UpdateAddressFailure) {
                                                            print(state.errorMessage.toString());
                                                          }
                                                        },
                                                        builder: (context, state) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              //print("${addressList[index].id}${addressList[index].userId}${addressList[index].mobile}${addressList[index].address}${addressList[index].city}${addressList[index].latitude}${addressList[index].longitude}${addressList[index].area}${addressList[index].type}${addressList[index].name}${addressList[index].countryCode}${addressList[index].alternateMobile}${addressList[index].landmark}${addressList[index].pincode}${addressList[index].state}${addressList[index].country}");
                                                              context.read<UpdateAddressCubit>().fetchUpdateAddress(
                                                                  addressList[index].id,
                                                                  addressList[index].userId,
                                                                  addressList[index].mobile,
                                                                  addressList[index].address,
                                                                  addressList[index].city,
                                                                  addressList[index].latitude,
                                                                  addressList[index].longitude,
                                                                  addressList[index].area,
                                                                  addressList[index].type,
                                                                  addressList[index].name,
                                                                  addressList[index].countryCode,
                                                                  addressList[index].alternateCountryCode,
                                                                  addressList[index].alternateMobile,
                                                                  addressList[index].landmark,
                                                                  addressList[index].pincode,
                                                                  addressList[index].state,
                                                                  addressList[index].country,
                                                                  "1");
                                                            },
                                                            child: Container(
                                                              decoration: addressList[index].isDefault == "1"
                                                                  ? DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.primary,
                                                                      Theme.of(context).colorScheme.primary.withOpacity(0.10), 15)
                                                                  : DesignConfig.boxDecorationContainerBorder(
                                                                      Theme.of(context).colorScheme.onSurface,
                                                                      Theme.of(context).colorScheme.onSurface,
                                                                      15),
                                                              margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                                              padding: EdgeInsets.symmetric(vertical: height! / 40.0, horizontal: height! / 40.0),
                                                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                                                Row(
                                                                  children: [
                                                                    addressList[index].type == homeKey
                                                                        ? SvgPicture.asset(
                                                                            DesignConfig.setSvgPath("home_address"),
                                                                          )
                                                                        : addressList[index].type == officeKey
                                                                            ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                                                                            : SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
                                                                    SizedBox(width: height! / 99.0),
                                                                    Text(
                                                                      addressList[index]
                                                                          .type! /*  == homeKey
                                                                          ? StringsRes.home
                                                                          : addressList[index].type == officeKey
                                                                              ? StringsRes.office
                                                                              : StringsRes.other */
                                                                      ,
                                                                      style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: Theme.of(context).colorScheme.onSecondary,
                                                                          fontWeight: FontWeight.w500),
                                                                    )
                                                                  ],
                                                                ),
                                                                SizedBox(width: height! / 99.0),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(width: width! / 11.0),
                                                                    Expanded(
                                                                      child: Text(
                                                                        "${addressList[index].address!},${addressList[index].city},${addressList[index].state!},${addressList[index].pincode!}",
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: Theme.of(context).colorScheme.onSecondary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ]),
                                                            ),
                                                          );
                                                        })
                                                    : NoDataContainer(
                                                        image: "address",
                                                        title: UiUtils.getTranslatedLabel(context, noAddressYetLabel),
                                                        subTitle: UiUtils.getTranslatedLabel(context, noAddressYetSubTitleLabel),
                                                        width: width!,
                                                        height: height!);
                                              });
                                        });
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: width!,
                                child: ButtonContainer(
                                  color: Theme.of(context).colorScheme.secondary,
                                  height: height,
                                  width: width,
                                  text: UiUtils.getTranslatedLabel(context, addAddressLabel),
                                  start: width! / 40.0,
                                  end: width! / 40.0,
                                  bottom: height! / 55.0,
                                  top: 0,
                                  status: false,
                                  borderColor: Theme.of(context).colorScheme.secondary,
                                  textColor: white,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushNamed(Routes.address,
                                        arguments: {'from': '', 'addressModel': AddressModel()}).then((value) => {refreshList()});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
                ],
              ),
            );
          });
        });
  }

  offlineCartTotal(List<ProductDetails>? productDetails) async {
    for (int i = 0; i < productDetails!.length; i++) {
      for (int j = 0; j < productDetails[i].variants!.length; j++) {
        if (productVariantId!.contains(productDetails[i].variants![j].id)) {
          String qty = (await db.checkCartItemExists(productDetails[i].id!, productDetails[i].variants![j].id!))!;

          List<ProductDetails>? prList = [];
          productDetails[i].variants![j].cartCount = qty;
          prList.add(productDetails[i]);
          //print("productDetails[i].variants![j].cartCount:${productDetails[i].variants![j].cartCount}");
/*
           context.read<CartProvider>().addCartItem(SectionModel(
                        id: cartList[i].id,
                        varientId: cartList[i].prVarientList![j].id,
                        qty: qty,
                        productList: prList,
                      )); */

          //final currentCartModel = context.read<OfflineCartCubit>().getOfflineCart();
          //context.read<OfflineCartCubit>().updateOfflineCartList(currentCartModel.updateCart(prList));

          double price = double.parse(productDetails[i].variants![j].specialPrice!);
          if (price == 0) {
            price = double.parse(productDetails[i].variants![j].price!);
          }

          double total = (price * int.parse(qty));
          setState(() {
            oriPrice = oriPrice + total;
            //context.read<SettingsCubit>().setCartTotal(oriPrice.toString());
            //print("oriPrice$oriPrice");
            status = 1;
          });
        }
      }
    }
  }

  Widget noCartData() {
    return NoDataContainer(
        image: "empty_cart",
        title: UiUtils.getTranslatedLabel(context, noOrderYetLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noOrderYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  double total() {
    if (orderTypeIndex.toString() == "0") {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! + deliveryCharge + deliveryTip - promoAmt);
    } else {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! + deliveryTip - promoAmt);
    }
  }

  Widget cartData() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
          ? BlocConsumer<OfflineCartCubit, OfflineCartState>(
              bloc: context.read<OfflineCartCubit>(),
              listener: (context, state) {
                print("Listener$status");
                if (state is OfflineCartSuccess) {
                  final offlineCartList = (state).productModel;
                  print("Listener$status--${offlineCartList.length}");
                  if (status == 0) {
                    offlineCartTotal(offlineCartList);
                  }
                }
              },
              builder: (context, state) {
                if (state is OfflineCartProgress) {
                  return CartSimmer(width: width!, height: height!);
                }
                if (state is OfflineCartInitial) {
                  //print(state.toString());
                  return noCartData();
                }
                if (state is OfflineCartFailure) {
                  //return Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center,));
                  return noCartData();
                }

                final offlineCartList = (state as OfflineCartSuccess).productModel;
                restaurantName =
                    offlineCartList.isEmpty ? UiUtils.getTranslatedLabel(context, myCartLabel) : offlineCartList[0].partnerDetails![0].partnerName!;
                restaurantAddress = offlineCartList.isEmpty ? "" : offlineCartList[0].partnerDetails![0].partnerAddress!;
                restaurantCookTime = offlineCartList.isEmpty ? "" : offlineCartList[0].partnerDetails![0].partnerCookTime!;
                //isRestaurantOpen = offlineCartList.data![0].partnerDetails![0].isRestroOpen!;
                print("Listener$status--${offlineCartList.length}--");

                return offlineCartList.isEmpty
                    ? noCartData()
                    : SizedBox(
                        width: width,
                        child: Container(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 80.0,
                            ),
                            width: width!,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 80, start: width! / 40.0, bottom: height! / 80.0, end: width! / 40.0),
                                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                                        Row(children: [
                                          Text(
                                            UiUtils.getTranslatedLabel(context, yourOrderLabel),
                                            style: TextStyle(
                                                fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                          ),
                                          const Spacer(),
                                          BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                            return BlocConsumer<ClearCartCubit, ClearCartState>(
                                                bloc: context.read<ClearCartCubit>(),
                                                listener: (context, state) {
                                                  if (state is ClearCartSuccess) {
                                                    if (context.read<AuthCubit>().state is AuthInitial ||
                                                        context.read<AuthCubit>().state is Unauthenticated) {
                                                      print("");
                                                    } else {
                                                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, cartLabel),
                                                          UiUtils.getTranslatedLabel(context, clearCartLabel), context, false,
                                                          type: "1");
                                                      //context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
                                                    }
                                                  } else if (state is ClearCartFailure) {
                                                    if (context.read<AuthCubit>().state is AuthInitial ||
                                                        context.read<AuthCubit>().state is Unauthenticated) {
                                                      print("");
                                                    } else {
                                                      UiUtils.setSnackBar(
                                                          UiUtils.getTranslatedLabel(context, cartLabel), state.errorMessage, context, false,
                                                          type: "2");
                                                    }
                                                  }
                                                },
                                                builder: (context, state) {
                                                  return InkWell(
                                                    onTap: () {
                                                      db.clearCart();
                                                      offlineCartList.clear();
                                                      getOffLineCart();
                                                      clearOffLineCart(context);
                                                      setState(() {});
                                                      restaurantName = UiUtils.getTranslatedLabel(context, myCartLabel);
                                                      restaurantAddress = "";
                                                      restaurantCookTime = "";
                                                    },
                                                    child: Text(
                                                      UiUtils.getTranslatedLabel(context, clearCartLabel),
                                                      style: TextStyle(
                                                          fontSize: 12, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                                                    ),
                                                  );
                                                });
                                          }),
                                        ]),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                          ),
                                          child: DesignConfig.divider(),
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: offlineCartList.length,
                                            itemBuilder: (BuildContext context, i) {
                                              //double price = 0;
                                              //double off = 0;
                                              //int selectedIndex = 0;
                                              /* for (int j = 0; j < offlineCartList.data![i].variants!.length; j++) {
                                          if (productVariantId!.contains(offlineCartList.data![i].variants![j].id)) {
                                            selectedIndex = j;
                                            price = double.parse(offlineCartList.data![i].variants![j].specialPrice!);
                                            if (price == 0) {
                                              price = double.parse(offlineCartList.data![i].variants![j].price!);
                                            }
                                            if (offlineCartList.data![i].variants![j].specialPrice! != "0") {
                                              off = (double.parse(offlineCartList.data![i].variants![j].price!) -
                                                      double.parse(offlineCartList.data![i].variants![j].specialPrice!))
                                                  .toDouble();
                                              off = off * 100 / double.parse(offlineCartList.data![i].variants![j].price!).toDouble();
                                            }
                                          }
                                        } */
                                              return SizedBox(
                                                width: width!,
                                                child: Container(
                                                    margin: EdgeInsetsDirectional.only(end: width! / 80.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: List.generate(offlineCartList[i].variants!.length, (l) {
                                                        VariantsModel variantData = offlineCartList[i].variants![l];
                                                        //VariantsModel variantData = offlineCartList.data![i].variants![l];
                                                        double price = double.parse(variantData.specialPrice!);
                                                        if (price == 0) {
                                                          price = double.parse(variantData.price!);
                                                        }

                                                        double off = 0;
                                                        if (offlineCartList[i].variants![l].specialPrice! != "0") {
                                                          off =
                                                              (double.parse(variantData.price!) - double.parse(variantData.specialPrice!)).toDouble();
                                                          off = off * 100 / double.parse(variantData.price!).toDouble();
                                                        }
                                                        List<String> addOnIds = [];
                                                        List<String> addOnQty = [];
                                                        for (int a = 0; a < offlineCartList[i].productAddOns!.length; a++) {
                                                          ProductAddOnsModel addOnData = offlineCartList[i].productAddOns![a];
                                                          if (productAddOnId!.contains(addOnData.id)) {
                                                            addOnIds.add(addOnData.id!);
                                                            addOnQty.add("1");
                                                          }
                                                          print("$addOnIds$addOnQty");
                                                        }
                                                        //print("${offlineCartList.data![i].name!}${variantData.price}");
                                                        return (productVariantId!.contains(variantData.id))
                                                            ? Container(
                                                                margin: EdgeInsetsDirectional.only(end: width! / 60.0),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        offlineCartList[i].image!.isEmpty
                                                                            ? ClipRRect(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                child: SizedBox(
                                                                                  width: width! / 5.0,
                                                                                  height: height! / 10.0,
                                                                                ))
                                                                            : ClipRRect(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                child: ColorFiltered(
                                                                                  colorFilter:
                                                                                      offlineCartList[i].partnerDetails![0].isRestroOpen == "1"
                                                                                          ? const ColorFilter.mode(
                                                                                              Colors.transparent,
                                                                                              BlendMode.multiply,
                                                                                            )
                                                                                          : const ColorFilter.mode(
                                                                                              Colors.grey,
                                                                                              BlendMode.saturation,
                                                                                            ),
                                                                                  child: DesignConfig.imageWidgets(
                                                                                      offlineCartList[i].image!, 35, 35, "2"),
                                                                                )),
                                                                        SizedBox(width: width! / 40.0),
                                                                        Expanded(
                                                                          child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      offlineCartList[i].indicator == "1"
                                                                                          ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"),
                                                                                              width: 15, height: 15)
                                                                                          : offlineCartList[i].indicator == "2"
                                                                                              ? SvgPicture.asset(
                                                                                                  DesignConfig.setSvgPath("non_veg_icon"),
                                                                                                  width: 15,
                                                                                                  height: 15)
                                                                                              : const SizedBox(height: 15, width: 15.0),
                                                                                      const SizedBox(width: 5.0),
                                                                                      Expanded(
                                                                                        flex: 2,
                                                                                        child: Text(
                                                                                          "${variantData.cartCount!} x ${offlineCartList[i].name!}", //Text("${snapshot.data} x ${offlineCartList.data![i].name!}",
                                                                                          textAlign: Directionality.of(context) == TextDirection.rtl
                                                                                              ? TextAlign.right
                                                                                              : TextAlign.left,
                                                                                          style: TextStyle(
                                                                                              color: Theme.of(context).colorScheme.onSecondary,
                                                                                              fontSize: 14,
                                                                                              fontWeight: FontWeight.w400,
                                                                                              fontStyle: FontStyle.normal,
                                                                                              overflow: TextOverflow.ellipsis),
                                                                                          maxLines: 1,
                                                                                        ),
                                                                                      ),
                                                                                      /*Container(alignment: Alignment.center, height: 25.0, width: width!/4.8, decoration: DesignConfig.boxDecorationContainerBorder(
                                                                                                  commentBoxBorderColor, textFieldBackground, 5.0),
                                                                                              //padding: const EdgeInsetsDirectional.only(top: 6.5, bottom: 6.5),
                                                                                                child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                                  BlocConsumer<RemoveFromCartCubit, RemoveFromCartState>(
                                                                                                  bloc: context.read<RemoveFromCartCubit>(),
                                                                                                  listener: (context, state) {
                                                                                                    if (state is RemoveFromCartSuccess) {
                                                                                                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, deleteLabel),
                                                                                                          StringsRes.deleteSuccessFully, context, false,
                                                                                                          type: "1");
                                                                                                      offlineCartList.removeAt(i);
                                                                                                      context
                                                                                                          .read<GetCartCubit>()
                                                                                                          .getCartUser(userId: context.read<AuthCubit>().getId());
                                                                                                      // Navigator.pop(context);
                                                                                                    } else if (state is RemoveFromCartFailure) {
                                                                                                      //showMessage = state.errorMessage.toString();
                                                                                                      UiUtils.setSnackBar(
                                                                                                          UiUtils.getTranslatedLabel(context, cartLabel), state.errorMessage, context, false,
                                                                                                          type: "2");
                                                                                                    }
                                                                                                  },
                                                                                                  builder: (context1, state) {
                                                                                                    return Padding(padding: const EdgeInsetsDirectional.only(end: 8.0), child:InkWell(
                                                                                                      onTap: () async {
                                                                                                        /* if(snapshot.data==1){
                                                                                                        db.removeCart(
                                                                                                            variantData.id!,
                                                                                                            offlineCartList.data![i].id!,
                                                                                                            context);
                                                                                                        offlineCartList.data![i].variants!.removeWhere((item) =>
                                                                                                            item.id ==
                                                                                                            variantData.id);
                                                                                                        productVariant = (await db.getCart());
                                                                                                        if (offlineCartList.data!.length > 1) {
                                                                                                        } else {
                                                                                                          clearOffLineCart(context);
                                                                                                        }
                                                                                                        }else{
                                                                                                          db.insertCart(
                                                                                                              offlineCartList.data![i].id!,
                                                                                                              variantData.id!,
                                                                                                              (int.parse(snapshot.data!.toString())-1).toString(),
                                                                                                              //widget.qtyData[widget.productVariantId!].toString(),
                                                                                                              addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                                                              addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "",
                                                                                                              variantData.price!,
                                                                                                              offlineCartList.data![i].partnerDetails![0].partnerId!,
                                                                                                              context)
                                                                                                            .whenComplete(() async {
                                                                                                          await getOffLineCart();
                                                                                                      });
                                                                                                        } */
                                                                                                        productVariant = (await db.getCart());
                                                                                                        print("productVariant${productVariant!["VID"].runtimeType}");
                                                                                                        //print("snapshot.data:${snapshot.data}--${offlineCartList.data!.length}");
                                                                                                        if(int.parse(variantData.cartCount!.toString())==1){//if(snapshot.data==1){
                                                                                                        db.removeCart(
                                                                                                            variantData.id!,
                                                                                                            offlineCartList[i].id!,
                                                                                                            context);
                                                                                                            oriPrice = (oriPrice - price);
                                                                                                            context.read<OfflineCartCubit>().updateQuntity(offlineCartList[i],((int.parse(variantData.cartCount.toString())-1)).toString(), variantData.id);
                                                                                                        offlineCartList[i].variants!.removeWhere((item) =>
                                                                                                            item.id ==
                                                                                                            variantData.id);
                                                                                                        productVariant = (await db.getCart());
                                                                                                        print("productVariant${productVariant!["VID"]}");
                                                                                                        if (/* offlineCartList.data!.length > 1 */productVariant!["VID"].isNotEmpty) {
                                                                                                        } else {
                                                                                                          db.clearCart();
                                                                                                          offlineCartList.clear();
                                                                                                          getOffLineCart();
                                                                                                          clearOffLineCart(context);
                                                                                                          //setState(() {});
                                                                                                          restaurantName = UiUtils.getTranslatedLabel(context, myCartLabel);
                                                                                                          restaurantAddress = "";
                                                                                                          restaurantCookTime = "";
                                                                                                          oriPrice=0;
                                                                                                        }
                                                                                                        }else{
                                                                                                          db.insertCart(
                                                                                                              offlineCartList[i].id!,
                                                                                                              variantData.id!,
                                                                                                              (int.parse(variantData.cartCount!.toString())-1).toString(),//(int.parse(snapshot.data!.toString())-1).toString(),
                                                                                                              //widget.qtyData[widget.productVariantId!].toString(),
                                                                                                              addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                                                              addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "",
                                                                                                              price.toString(),//variantData.price!,
                                                                                                              offlineCartList[i].partnerDetails![0].partnerId!,
                                                                                                              context)
                                                                                                            .whenComplete(() async {
                                                                                                              oriPrice = (oriPrice - price);
                                                                                                              context.read<OfflineCartCubit>().updateQuntity(offlineCartList[i],((int.parse(variantData.cartCount.toString())-1)).toString(), variantData.id);
                                                                                                          //await getOffLineCart();
                                                                                                      });
                                                                                                        }
                                                                                                        setState(() {});
                                                                                                      },
                                                                                                      child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSecondary, size: 15.0),
                                                                                                    ));
                                                                                                  }),
                                                                                            SizedBox(width: width! / 50.0),
                                                                                            Text(variantData.cartCount!.toString(),//Text(snapshot.data.toString(),
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w500, fontStyle:  FontStyle.normal,)),
                                                                                            //Text(qty.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                                                                                            SizedBox(width: width! / 50.0),
                                                                                            Padding(
                                                                                              padding: const EdgeInsetsDirectional.only(start: 8.0),
                                                                                              child: InkWell(
                                                                                                onTap:(){
                                                                                                  List<Data> data = [];
                                                                                                  if(offlineCartList[i].type=="variable_product"){
                                                                                                        itemEditQtyBottomSheet(offlineCartList, i, variantData.id!, i, data, l);
                                                                                                  }else{
                                                                                                  /* setState(() {
                                                                                                          if(int.parse(snapshot.data!.toString()) < int.parse(offlineCartList.data![i].minimumOrderQuantity!)){
                                                                                                            Navigator.pop(context);
                                                                                                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, quantityLabel), "${StringsRes.minimumQuantityAllowed} ${offlineCartList.data![i].minimumOrderQuantity!}", context, false,
                                                                                                            type: "2");
                                                                                                          }else if (int.parse(snapshot.data.toString()) >= int.parse(offlineCartList.data![i].totalAllowedQuantity!)) {
                                                                                                            //snapshot.data! = offlineCartList.data![i].totalAllowedQuantity!;
                                                                                                            //Navigator.pop(context);
                                                                                                            UiUtils.setSnackBar(
                                                                                                                UiUtils.getTranslatedLabel(context, quantityLabel),
                                                                                                                "${StringsRes.minimumQuantityAllowed} ${offlineCartList.data![i].totalAllowedQuantity!}",
                                                                                                                context,
                                                                                                                false,
                                                                                                                type: "2");
                                                                                                          } else {
                                                                                                            db.insertCart(
                                                                                                                  offlineCartList.data![i].id!,
                                                                                                                  variantData.id!,
                                                                                                                  (int.parse(snapshot.data!.toString())+1).toString(),
                                                                                                                  //widget.qtyData[widget.productVariantId!].toString(),
                                                                                                                  addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                                                                  addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "",
                                                                                                                  variantData.price!,
                                                                                                                  offlineCartList.data![i].partnerDetails![0].partnerId!,
                                                                                                                  context)
                                                                                                              .whenComplete(() async {
                                                                                                            await getOffLineCart();
                                                                                                          });
                                                                                                          }
                                                                                                        }); */
                                                                                                        setState(() {
                                                                                                          if(int.parse(variantData.cartCount!.toString())<int.parse(offlineCartList[i].minimumOrderQuantity!)){//if(int.parse(snapshot.data!.toString()) < int.parse(offlineCartList.data![i].minimumOrderQuantity!)){
                                                                                                            Navigator.pop(context);
                                                                                                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, quantityLabel), "${StringsRes.minimumQuantityAllowed} ${offlineCartList[i].minimumOrderQuantity!}", context, false,
                                                                                                            type: "2");
                                                                                                          }else if(int.parse(variantData.cartCount!.toString()) >= int.parse(offlineCartList[i].totalAllowedQuantity!)){//else if (int.parse(snapshot.data.toString()) >= int.parse(offlineCartList.data![i].totalAllowedQuantity!)) {
                                                                                                            //snapshot.data! = offlineCartList.data![i].totalAllowedQuantity!;
                                                                                                            //Navigator.pop(context);
                                                                                                            UiUtils.setSnackBar(
                                                                                                                UiUtils.getTranslatedLabel(context, quantityLabel),
                                                                                                                "${StringsRes.minimumQuantityAllowed} ${offlineCartList[i].totalAllowedQuantity!}",
                                                                                                                context,
                                                                                                                false,
                                                                                                                type: "2");
                                                                                                          } else {
                                                                                                            db.insertCart(
                                                                                                                  offlineCartList[i].id!,
                                                                                                                  variantData.id!,
                                                                                                                  (int.parse(variantData.cartCount!.toString())+1).toString(),//(int.parse(snapshot.data!.toString())+1).toString(),
                                                                                                                  //widget.qtyData[widget.productVariantId!].toString(),
                                                                                                                  addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                                                                  addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "",
                                                                                                                  price.toString(),//variantData.price!,
                                                                                                                  offlineCartList[i].partnerDetails![0].partnerId!,
                                                                                                                  context)
                                                                                                              .whenComplete(() async {
                                                                                                                oriPrice = (oriPrice + price);
                                                                                                                context.read<OfflineCartCubit>().updateQuntity(offlineCartList[i],((int.parse(variantData.cartCount.toString())+1)).toString(), variantData.id);
                                                                                                                //context.read<SettingsCubit>().setCartTotal(oriPrice.toString());
                                                                                                            //await getOffLineCart();
                                                                                                          });
                                                                                                          }
                                                                                                          setState(() {});
                                                                                                        });
                                                                                                        }
                                                                                                },
                                                                                                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary, size: 15.0)),
                                                                                            ),
                                                                                          ]),
                                                                                        )*/
                                                                                      Container(
                                                                                        padding: EdgeInsetsDirectional.only(
                                                                                            top: 3.0, bottom: 3.0, start: 5.0, end: 5.0),
                                                                                        alignment: Alignment.center,
                                                                                        height: 28.0,
                                                                                        width: width! / 4.8,
                                                                                        decoration: DesignConfig.boxDecorationContainerBorder(
                                                                                            commentBoxBorderColor, textFieldBackground, 5.0),
                                                                                        child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            children: [
                                                                                              BlocConsumer<RemoveFromCartCubit, RemoveFromCartState>(
                                                                                                  bloc: context.read<RemoveFromCartCubit>(),
                                                                                                  listener: (context, state) {
                                                                                                    if (state is RemoveFromCartSuccess) {
                                                                                                      UiUtils.setSnackBar(
                                                                                                          UiUtils.getTranslatedLabel(
                                                                                                              context, deleteLabel),
                                                                                                          StringsRes.deleteSuccessFully,
                                                                                                          context,
                                                                                                          false,
                                                                                                          type: "1");
                                                                                                      offlineCartList.removeAt(i);
                                                                                                      //context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId(),res: context.read<SettingsCubit>().getSettings().branchId);
                                                                                                    } else if (state is RemoveFromCartFailure) {
                                                                                                      UiUtils.setSnackBar(
                                                                                                          UiUtils.getTranslatedLabel(
                                                                                                              context, cartLabel),
                                                                                                          state.errorMessage,
                                                                                                          context,
                                                                                                          false,
                                                                                                          type: "2");
                                                                                                    }
                                                                                                  },
                                                                                                  builder: (contextRemoveCart, state) {
                                                                                                    return InkWell(
                                                                                                      overlayColor: WidgetStateProperty.all(
                                                                                                          Theme.of(context)
                                                                                                              .colorScheme
                                                                                                              .onPrimary
                                                                                                              .withOpacity(0.10)),
                                                                                                      onTap: () async {
                                                                                                        productVariant = (await db.getCart());
                                                                                                        productVariantData = (await db.getCartData());
                                                                                                        List<ProductAddOnsModel> addOnsDataModel =
                                                                                                            offlineCartList[i].productAddOns!;
                                                                                                        List<String> addOnIds = [];
                                                                                                        List<String> addOnQty = [];
                                                                                                        var totalSum = 0.0;
                                                                                                        if (productVariantData!
                                                                                                            .containsKey(variantData.id)) {
                                                                                                          productAddOnId =
                                                                                                              productVariantData![variantData.id]
                                                                                                                  .toString()
                                                                                                                  .replaceAll("[", "")
                                                                                                                  .replaceAll("]", "")
                                                                                                                  .split(",");
                                                                                                        }
                                                                                                        productAddOnId!
                                                                                                            .removeWhere((element) => element == '');
                                                                                                        for (int qt = 0;
                                                                                                            qt < addOnsDataModel.length;
                                                                                                            qt++) {
                                                                                                          if (productAddOnId!
                                                                                                              .contains(addOnsDataModel[qt].id)) {
                                                                                                            addOnIds.add(
                                                                                                                addOnsDataModel[qt].id.toString());
                                                                                                            addOnQty.add((int.parse(variantData
                                                                                                                        .cartCount!
                                                                                                                        .toString()) -
                                                                                                                    1)
                                                                                                                .toString());
                                                                                                            totalSum += (double.parse(
                                                                                                                    addOnsDataModel[qt]
                                                                                                                        .price!
                                                                                                                        .toString()) *
                                                                                                                (int.parse(variantData.cartCount!
                                                                                                                        .toString()) -
                                                                                                                    1));
                                                                                                          }
                                                                                                        }
                                                                                                        double overAllTotalPrice = (price *
                                                                                                                (int.parse(variantData.cartCount!
                                                                                                                        .toString()) -
                                                                                                                    1) +
                                                                                                            totalSum);
                                                                                                        print(
                                                                                                            "productVariant${productVariant!["VID"].runtimeType}");

                                                                                                        if (int.parse(
                                                                                                                variantData.cartCount!.toString()) ==
                                                                                                            1) {
                                                                                                          db.removeCart(variantData.id!,
                                                                                                              offlineCartList[i].id!, context);
                                                                                                          oriPrice = (oriPrice - price);
                                                                                                          context
                                                                                                              .read<OfflineCartCubit>()
                                                                                                              .updateQuntity(
                                                                                                                  offlineCartList[i],
                                                                                                                  ((int.parse(variantData.cartCount
                                                                                                                              .toString()) -
                                                                                                                          1))
                                                                                                                      .toString(),
                                                                                                                  variantData.id);
                                                                                                          offlineCartList[i].variants!.removeWhere(
                                                                                                              (item) => item.id == variantData.id);
                                                                                                          productVariant = (await db.getCart());
                                                                                                          productVariantData =
                                                                                                              (await db.getCartData());
                                                                                                          print(
                                                                                                              "productVariant${productVariant!["VID"]}--${productVariant!["VID"].isEmpty}");
                                                                                                          if (productVariant!["VID"].isEmpty) {
                                                                                                            db.clearCart();
                                                                                                            offlineCartList.clear();
                                                                                                            getOffLineCart();
                                                                                                            clearOffLineCart(context);
                                                                                                            context
                                                                                                                .read<OfflineCartCubit>()
                                                                                                                .clearOfflineCartModel();
                                                                                                            setState(() {});
                                                                                                            oriPrice = 0;
                                                                                                          }
                                                                                                        } else {
                                                                                                          db
                                                                                                              .insertCart(
                                                                                                                  offlineCartList[i].id!,
                                                                                                                  variantData.id!,
                                                                                                                  (int.parse(variantData.cartCount!
                                                                                                                              .toString()) -
                                                                                                                          1)
                                                                                                                      .toString(),
                                                                                                                  addOnIds.isNotEmpty
                                                                                                                      ? addOnIds.join(",").toString()
                                                                                                                      : "",
                                                                                                                  addOnQty.isNotEmpty
                                                                                                                      ? addOnQty.join(",").toString()
                                                                                                                      : "",
                                                                                                                  overAllTotalPrice.toString(),
                                                                                                                  context
                                                                                                                      .read<SettingsCubit>()
                                                                                                                      .getSettings()
                                                                                                                      .restaurantId,
                                                                                                                  context)
                                                                                                              .whenComplete(() async {
                                                                                                            oriPrice = (oriPrice - price);
                                                                                                            context
                                                                                                                .read<OfflineCartCubit>()
                                                                                                                .updateQuntity(
                                                                                                                    offlineCartList[i],
                                                                                                                    ((int.parse(variantData.cartCount
                                                                                                                                .toString()) -
                                                                                                                            1))
                                                                                                                        .toString(),
                                                                                                                    variantData.id);
                                                                                                          });
                                                                                                        }
                                                                                                        setState(() {});
                                                                                                      },
                                                                                                      child: Icon(Icons.remove,
                                                                                                          color: Theme.of(context)
                                                                                                              .colorScheme
                                                                                                              .onSecondary,
                                                                                                          size: 15.0),
                                                                                                    );
                                                                                                  }),
                                                                                              const Spacer(),
                                                                                              Text(
                                                                                                variantData.cartCount!.toString(),
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                                                                  fontSize: 10,
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontStyle: FontStyle.normal,
                                                                                                ),
                                                                                              ),
                                                                                              const Spacer(),
                                                                                              InkWell(
                                                                                                overlayColor: WidgetStateProperty.all(
                                                                                                    Theme.of(context)
                                                                                                        .colorScheme
                                                                                                        .onPrimary
                                                                                                        .withOpacity(0.10)),
                                                                                                onTap: () {
                                                                                                  List<ProductAddOnsModel> addOnsDataModel =
                                                                                                      offlineCartList[i].productAddOns!;
                                                                                                  List<String> addOnIds = [];
                                                                                                  List<String> addOnQty = [];
                                                                                                  var totalSum = 0.0;
                                                                                                  if (productVariantData!
                                                                                                      .containsKey(variantData.id)) {
                                                                                                    productAddOnId =
                                                                                                        productVariantData![variantData.id]
                                                                                                            .toString()
                                                                                                            .replaceAll("[", "")
                                                                                                            .replaceAll("]", "")
                                                                                                            .split(",");
                                                                                                  }
                                                                                                  productAddOnId!
                                                                                                      .removeWhere((element) => element == '');
                                                                                                  for (int qt = 0;
                                                                                                      qt < addOnsDataModel.length;
                                                                                                      qt++) {
                                                                                                    if (productAddOnId!
                                                                                                        .contains(addOnsDataModel[qt].id)) {
                                                                                                      addOnIds.add(addOnsDataModel[qt].id.toString());
                                                                                                      addOnQty.add((int.parse(
                                                                                                                  variantData.cartCount!.toString()) +
                                                                                                              1)
                                                                                                          .toString());
                                                                                                      totalSum += (double.parse(
                                                                                                              addOnsDataModel[qt].price!.toString()) *
                                                                                                          (int.parse(
                                                                                                                  variantData.cartCount!.toString()) +
                                                                                                              1));
                                                                                                    }
                                                                                                  }
                                                                                                  double overAllTotalPrice = (price *
                                                                                                          (int.parse(
                                                                                                                  variantData.cartCount!.toString()) +
                                                                                                              1) +
                                                                                                      totalSum);
                                                                                                  setState(() {
                                                                                                    if (int.parse(variantData.cartCount!.toString()) <
                                                                                                        int.parse(offlineCartList[i]
                                                                                                            .minimumOrderQuantity!)) {
                                                                                                      Navigator.pop(context);
                                                                                                      UiUtils.setSnackBar(
                                                                                                          UiUtils.getTranslatedLabel(
                                                                                                              context, quantityLabel),
                                                                                                          "${StringsRes.minimumQuantityAllowed} ${offlineCartList[i].minimumOrderQuantity!}",
                                                                                                          context,
                                                                                                          false,
                                                                                                          type: "2");
                                                                                                    } else if (offlineCartList[i]
                                                                                                                .totalAllowedQuantity !=
                                                                                                            "" &&
                                                                                                        int.parse(
                                                                                                                variantData.cartCount!.toString()) >=
                                                                                                            int.parse(offlineCartList[i]
                                                                                                                .totalAllowedQuantity!)) {
                                                                                                      UiUtils.setSnackBar(
                                                                                                          UiUtils.getTranslatedLabel(
                                                                                                              context, quantityLabel),
                                                                                                          "${StringsRes.minimumQuantityAllowed} ${offlineCartList[i].totalAllowedQuantity!}",
                                                                                                          context,
                                                                                                          false,
                                                                                                          type: "2");
                                                                                                    } else {
                                                                                                      db
                                                                                                          .insertCart(
                                                                                                              offlineCartList[i].id!,
                                                                                                              variantData.id!,
                                                                                                              (int.parse(variantData.cartCount!
                                                                                                                          .toString()) +
                                                                                                                      1)
                                                                                                                  .toString(),
                                                                                                              addOnIds.isNotEmpty
                                                                                                                  ? addOnIds.join(",").toString()
                                                                                                                  : "",
                                                                                                              addOnQty.isNotEmpty
                                                                                                                  ? addOnQty.join(",").toString()
                                                                                                                  : "",
                                                                                                              overAllTotalPrice.toString(),
                                                                                                              context
                                                                                                                  .read<SettingsCubit>()
                                                                                                                  .getSettings()
                                                                                                                  .restaurantId,
                                                                                                              context)
                                                                                                          .whenComplete(() async {
                                                                                                        oriPrice = (oriPrice + price);
                                                                                                        context
                                                                                                            .read<OfflineCartCubit>()
                                                                                                            .updateQuntity(
                                                                                                                offlineCartList[i],
                                                                                                                ((int.parse(variantData.cartCount
                                                                                                                            .toString()) +
                                                                                                                        1))
                                                                                                                    .toString(),
                                                                                                                variantData.id);
                                                                                                      });
                                                                                                    }
                                                                                                    setState(() {});
                                                                                                  });
                                                                                                },
                                                                                                child: Icon(Icons.add,
                                                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                                                    size: 15.0),
                                                                                              ),
                                                                                            ]),
                                                                                      ),
                                                                                    ]),
                                                                                SingleChildScrollView(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      /* 
                                                                                          variantData.attrName != ""
                                                                                              ? Text("${variantData.attrName!} : ",
                                                                                                  textAlign: TextAlign.left,
                                                                                                  style: const TextStyle(
                                                                                                      color: lightFont,
                                                                                                      fontSize: 12,
                                                                                                      fontWeight: FontWeight.w500))
                                                                                              : Container(), */
                                                                                      variantData.variantValues != ""
                                                                                          ? Text("${variantData.variantValues!} ",
                                                                                              textAlign: TextAlign.left,
                                                                                              style: const TextStyle(
                                                                                                color: lightFont,
                                                                                                fontSize: 12,
                                                                                              ))
                                                                                          : Container(),
                                                                                      Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: List.generate(
                                                                                              offlineCartList[i].productAddOns!.length, (m) {
                                                                                            ProductAddOnsModel addOnData =
                                                                                                offlineCartList[i].productAddOns![m];
                                                                                            if (productVariantData!.containsKey(variantData.id)) {
                                                                                              productAddOnId = productVariantData![variantData.id]
                                                                                                  .toString()
                                                                                                  .replaceAll("[", "")
                                                                                                  .replaceAll("]", "")
                                                                                                  .split(",");
                                                                                            }
                                                                                            productAddOnId!.removeWhere((element) => element == '');
                                                                                            return (productVariantData![variantData.id]!
                                                                                                    .contains(addOnData.id))
                                                                                                ? Text(
                                                                                                    "${addOnData.title!}, ",
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: const TextStyle(
                                                                                                        color: lightFontColor,
                                                                                                        fontSize: 12,
                                                                                                        overflow: TextOverflow.ellipsis),
                                                                                                    maxLines: 1,
                                                                                                  )
                                                                                                : Container();
                                                                                          }))
                                                                                      /*: Container(),*/
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 5.0),
                                                                                Row(children: [
                                                                                  Text(
                                                                                      context.read<SystemConfigCubit>().getCurrency() +
                                                                                          price.toString(),
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                          color: Theme.of(context).colorScheme.primary,
                                                                                          fontSize: 13,
                                                                                          fontWeight: FontWeight.w700)),
                                                                                  SizedBox(width: width! / 99.0),
                                                                                  off.toStringAsFixed(2) == "0.00" || off.toStringAsFixed(2) == "0.0"
                                                                                      ? const SizedBox()
                                                                                      : Text(
                                                                                          context.read<SystemConfigCubit>().getCurrency() +
                                                                                              (double.parse(variantData.price!.toString()) *
                                                                                                      int.parse(variantData.cartCount!.toString()))
                                                                                                  .toStringAsFixed(2),
                                                                                          //(double.parse(variantData.price!.toString())*int.parse(snapshot.data.toString())).toStringAsFixed(2),
                                                                                          style: const TextStyle(
                                                                                              decoration: TextDecoration.lineThrough,
                                                                                              letterSpacing: 0,
                                                                                              color: lightFont,
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              overflow: TextOverflow.ellipsis),
                                                                                          maxLines: 1,
                                                                                        ),
                                                                                  off.toStringAsFixed(2) == "0.00"
                                                                                      ? const SizedBox()
                                                                                      : Text(
                                                                                          "  |  ",
                                                                                          style: TextStyle(
                                                                                              color: Theme.of(context).colorScheme.onSecondary,
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w700,
                                                                                              overflow: TextOverflow.ellipsis),
                                                                                          maxLines: 1,
                                                                                        ),
                                                                                  off.toStringAsFixed(2) == "0.00"
                                                                                      ? const SizedBox()
                                                                                      : Text(
                                                                                          "${off.toStringAsFixed(2)}${StringsRes.percentSymbol} ${StringsRes.off}",
                                                                                          style: TextStyle(
                                                                                              color: Theme.of(context).colorScheme.primary,
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w700,
                                                                                              overflow: TextOverflow.ellipsis),
                                                                                          maxLines: 1,
                                                                                        ),
                                                                                ]),
                                                                                const SizedBox(height: 5.0),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      bottomModelSheetShowEdit(
                                                                                          offlineCartList, i, variantData.id!, l);
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    width: width! / 8.0,
                                                                                    padding: const EdgeInsets.all(3.0),
                                                                                    decoration:
                                                                                        DesignConfig.boxDecorationContainer(textFieldBackground, 4.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          UiUtils.getTranslatedLabel(context, editLabel),
                                                                                          style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              color: Theme.of(context).colorScheme.primary),
                                                                                        ),
                                                                                        Icon(Icons.keyboard_arrow_down,
                                                                                            color: Theme.of(context).colorScheme.primary, size: 10.0),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.only(
                                                                        top: height! / 99.0,
                                                                        bottom: height! / 99.0,
                                                                      ),
                                                                      child: DesignConfig.divider(),
                                                                    ),
                                                                  ],
                                                                ))
                                                            : Container();
                                                      }),
                                                    )),
                                              );
                                            }),
                                        Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: width! / 40.0,
                                              end: width! / 40.0,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(Routes.restaurantDetail,
                                                    arguments: {'restaurant': offlineCartList[0].partnerDetails![0]}).then((value) {
                                                  //status = 0;
                                                  //oriPrice = 0;
                                                  //getOffLineCart();
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 20.0),
                                                  const SizedBox(width: 2.0),
                                                  Text(UiUtils.getTranslatedLabel(context, addMoreFoodInCartLabel),
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FontStyle.normal,
                                                      )),
                                                ],
                                              ),
                                            )),
                                      ])),
                                  Container(
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 60.0),
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              UiUtils.getTranslatedLabel(context, billDetailLabel),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional.only(
                                                top: 4.5,
                                                bottom: 4.5,
                                              ),
                                              child: DesignConfig.divider(),
                                            ),
                                            BlocConsumer<SettingsCubit, SettingsState>(
                                                bloc: context.read<SettingsCubit>(),
                                                listener: (context, state) {},
                                                builder: (context, state) {
                                                  return Padding(
                                                    padding: const EdgeInsetsDirectional.only(
                                                      top: 4.5,
                                                      bottom: 4.5,
                                                    ),
                                                    child: Row(children: [
                                                      Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.onSecondary,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w700)),
                                                      const Spacer(),
                                                      (context.read<AuthCubit>().state is AuthInitial ||
                                                                  context.read<AuthCubit>().state is Unauthenticated) &&
                                                              (state.settingsModel!.cartCount == "0" ||
                                                                  state.settingsModel!.cartCount == "" ||
                                                                  state.settingsModel!.cartCount == "0.0") &&
                                                              (state.settingsModel!.cartTotal == "0" ||
                                                                  state.settingsModel!.cartTotal == "" ||
                                                                  state.settingsModel!.cartTotal == "0.0" ||
                                                                  state.settingsModel!.cartTotal == "0.00")
                                                          ? const SizedBox.shrink()
                                                          : Text(
                                                              /* context.read<SystemConfigCubit>().getCurrency() + state.settingsModel!.cartTotal.toString() == ""
                                                    ? "0"
                                                    : double.parse(state.settingsModel!.cartTotal.toString()).toStringAsFixed(2), */ /* oriPrice.toStringAsFixed(2) */ context
                                                                              .read<SystemConfigCubit>()
                                                                              .getCurrency() +
                                                                          state.settingsModel!.cartTotal.toString() ==
                                                                      ""
                                                                  ? "0"
                                                                  : "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(state.settingsModel!.cartTotal.toString()).toStringAsFixed(2)}",
                                                              textAlign: TextAlign.end,
                                                              style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w700,
                                                                  letterSpacing: 0.8)),
                                                    ]),
                                                  );
                                                }),
                                          ])),
                                ],
                              ),
                            )));
              })
          : /* context.read<SettingsCubit>().state.settingsModel!.cartCount == "0" &&
                  context.read<SettingsCubit>().state.settingsModel!.cartTotal == "0.0"
              ? noCartData()
              :  */BlocConsumer<GetCartCubit, GetCartState>(
                  bloc: context.read<GetCartCubit>(),
                  listener: (context, state) {
                    if (state is GetCartFailure) {
                      if (state.errorStatusCode.toString() == "102") {
                        reLogin(context);
                      }
                    }
                    if (state is GetCartSuccess) {
                      final cartList = state.cartModel;
                      deliveryStatus = cartList.data![0].productDetails![0].partnerDetails![0].permissions!.deliveryOrders!;
                      availableTime.clear();
                      checkTime.clear();
                      for (int i = 0; i < cartList.data!.length; i++) {
                        if (cartList.data![i].productDetails![0].availableTime == "1") {
                          availableTime.add(cartList.data![i].productDetails![0].availableTime!);
                          checkTime.add(getStoreOpenStatus(context.read<GetCartCubit>().getCartModel().data![i].productDetails![0].startTime!,
                              context.read<GetCartCubit>().getCartModel().data![i].productDetails![0].endTime!));
                          print(
                              "data:${context.read<GetCartCubit>().getCartModel().data![i].productDetails![0].startTime!}-----${context.read<GetCartCubit>().getCartModel().data![i].productDetails![0].endTime!}");
                        }
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is GetCartProgress) {
                      return CartSimmer(width: width!, height: height!);
                    }
                    if (state is GetCartInitial) {
                      //return Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center,));
                      return noCartData();
                    }
                    if (state is GetCartFailure) {
                      print("cartdata:-----$state--${state.errorMessage}");
                      //return Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center,));
                      return noCartData();
                    }
                    final cartList = (state as GetCartSuccess).cartModel;
                    taxPercentage = cartList.taxPercentage!.isEmpty ? 0 : double.parse(cartList.taxPercentage!);
                    taxAmount = cartList.taxAmount!.isEmpty ? 0 : double.parse(cartList.taxAmount!);
                    subTotal = double.parse(cartList.subTotal!);
                    overAllAmount = cartList.overallAmount!;
                    finalTotal = cartList.overallAmount!;
                    cartModel = cartList;
                    isRestaurantOpen = cartList.data![0].productDetails![0].partnerDetails![0].isRestroOpen!;
                    pickupStatus = cartList.data![0].productDetails![0].partnerDetails![0].permissions!.selfPickup!;
                    deliveryStatus = cartList.data![0].productDetails![0].partnerDetails![0].permissions!.deliveryOrders!;
                    restaurantName = cartList.data![0].productDetails![0].partnerDetails![0].partnerName!;
                    restaurantAddress = cartList.data![0].productDetails![0].partnerDetails![0].partnerAddress!;
                    restaurantCookTime = cartList.data![0].productDetails![0].partnerDetails![0].partnerCookTime!;
                    if (deliveryStatus == "0") {
                      orderTypeIndex = 1;
                    }
                    //finalTotal = double.parse(cartList.subTotal!);
                    
                    return cartList.totalQuantity == ""
                        ? noCartData()
                        : Container(
                            margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            //height: height! / 0.9,
                            //decoration: DesignConfig.boxCurveShadow(white),
                            width: width,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      cartList.data![0].productDetails![0].partnerDetails![0].permissions!.deliveryOrders == "1"
                                          ? Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    orderTypeIndex = 0;
                                                  });
                                                },
                                                child: Container(
                                                  width: width!,
                                                  decoration: DesignConfig.boxDecorationContainer(
                                                      orderTypeIndex == 0
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Theme.of(context).colorScheme.onSurface,
                                                      10.0),
                                                  margin: EdgeInsetsDirectional.only(start: width! / 40.0),
                                                  padding: EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 70.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SvgPicture.asset(DesignConfig.setSvgPath("delivery"),
                                                          colorFilter: ColorFilter.mode(
                                                              orderTypeIndex == 0
                                                                  ? Theme.of(context).colorScheme.onSurface
                                                                  : Theme.of(context).colorScheme.onSecondary,
                                                              BlendMode.srcIn)),
                                                      const SizedBox(height: 5.0),
                                                      Text(
                                                        UiUtils.getTranslatedLabel(context, deliveryLabel),
                                                        style: TextStyle(
                                                            color: orderTypeIndex == 0 ? white : Theme.of(context).colorScheme.onSecondary,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      cartList.data![0].productDetails![0].partnerDetails![0].permissions!.selfPickup == "1"
                                          ? Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    orderTypeIndex = 1;
                                                  });
                                                },
                                                child: Container(
                                                  width: width!,
                                                  decoration: DesignConfig.boxDecorationContainer(
                                                      orderTypeIndex == 1
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Theme.of(context).colorScheme.onSurface,
                                                      10.0),
                                                  margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                                                  padding: EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 70.0),
                                                  child: Column(
                                                    children: [
                                                      SvgPicture.asset(DesignConfig.setSvgPath("pickup"),
                                                          colorFilter: ColorFilter.mode(
                                                              orderTypeIndex == 1
                                                                  ? Theme.of(context).colorScheme.onSurface
                                                                  : Theme.of(context).colorScheme.onSecondary,
                                                              BlendMode.srcIn)),
                                                      const SizedBox(height: 5.0),
                                                      Text(
                                                        UiUtils.getTranslatedLabel(context, pickupLabel),
                                                        style: TextStyle(
                                                            color: orderTypeIndex == 1 ? white : Theme.of(context).colorScheme.onSecondary,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                  orderTypeIndex == 1
                                      ? const SizedBox()
                                      : Container(
                                          padding: EdgeInsetsDirectional.only(
                                              start: width! / 40.0, top: height! / 80.0, end: width! / 40.0, bottom: height! / 99.0),
                                          width: width!,
                                          margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 40.0, end: width! / 40.0),
                                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                          child: Column(
                                            children: [
                                              BlocConsumer<AddressCubit, AddressState>(
                                                  bloc: context.read<AddressCubit>(),
                                                  listener: (context, state) {
                                                    if (state is AddressSuccess) {
                                                      final addressList = state.addressList;
                                                      for (int i = 0; i < addressList.length; i++) {
                                                        if (addressList[i].isDefault == "1") {
                                                          context
                                                              .read<DeliveryChargeCubit>()
                                                              .fetchDeliveryCharge(context.read<AuthCubit>().getId(), addressList[i].id!, context.read<GetCartCubit>().getCartModel().overallAmount.toString());
                                                        }
                                                      }
                                                    }
                                                  },
                                                  builder: (context, state) {
                                                    print("address${state.toString()}");
                                                    if (state is AddressProgress || state is AddressInitial) {
                                                      return AddressSimmer(width: width!, height: height!);
                                                    }
                                                    if (state is AddressFailure) {
                                                      return const SizedBox();
                                                    }
                                                    if (state is AddressSuccess) {
                                                      final addressList = state.addressList;
                                                      for (int i = 0; i < addressList.length; i++) {
                                                        if (addressList[i].isDefault == "1") {
                                                          context
                                                              .read<DeliveryChargeCubit>()
                                                              .fetchDeliveryCharge(context.read<AuthCubit>().getId(), addressList[i].id!, cartList.overallAmount.toString());
                                                        }
                                                      }
                                                      return Row(children: [
                                                        Text(
                                                          UiUtils.getTranslatedLabel(context, deliveryLocationLabel),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Theme.of(context).colorScheme.onSecondary,
                                                              fontWeight: FontWeight.w500),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          onTap: () {
                                                            bottomModelSheetShow();
                                                            //Navigator.of(context).pushNamed(Routes.selectAddress, arguments: false);
                                                          },
                                                          child: Text(
                                                            UiUtils.getTranslatedLabel(context, changeLabel),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(context).colorScheme.primary,
                                                                fontWeight: FontWeight.w700),
                                                          ),
                                                        ),
                                                      ]);
                                                    }
                                                    return const SizedBox();
                                                  }),
                                              context.read<AddressCubit>().gerCurrentAddress().id == "" ||
                                                      context.read<AddressCubit>().gerCurrentAddress().id!.isEmpty ||
                                                      orderTypeIndex == 1
                                                  ? const SizedBox()
                                                  : Padding(
                                                      padding: EdgeInsetsDirectional.only(
                                                        top: height! / 80.0,
                                                        bottom: height! / 50.0,
                                                        /* start: width! / 40.0,
                                            end: width! / 40.0, */
                                                      ),
                                                      child: DesignConfig.divider(),
                                                    ),
                                              orderTypeIndex == 1
                                                  ? const SizedBox()
                                                  : BlocProvider<UpdateAddressCubit>(
                                                      create: (_) => UpdateAddressCubit(AddressRepository()),
                                                      child: Builder(builder: (context) {
                                                        return BlocConsumer<AddressCubit, AddressState>(
                                                            bloc: context.read<AddressCubit>(),
                                                            listener: (context, state) {},
                                                            builder: (context, state) {
                                                              if (state is AddressProgress || state is AddressInitial) {
                                                                return AddressSimmer(width: width!, height: height!);
                                                              }
                                                              if (state is AddressFailure) {
                                                                return /*Center(
                                                      child: Text(
                                                    state.errorCode.toString(),
                                                    textAlign: TextAlign.center,
                                                  ))*/
                                                                    const SizedBox();
                                                              }

                                                              if (state is AddressSuccess) {
                                                                return ListView.builder(
                                                                    shrinkWrap: true,
                                                                    padding: EdgeInsets.zero,
                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                    itemCount: state.addressList.length,
                                                                    itemBuilder: (BuildContext context, i) {
                                                                      if (state.addressList[i].isDefault == "1") {
                                                                        addressIndex = i;
                                                                        selAddress = state.addressList[addressIndex!].id;
                                                                        latitude = double.parse(state.addressList[addressIndex!].latitude!);
                                                                        longitude = double.parse(state.addressList[addressIndex!].longitude!);
                                                                      }
                                                                      return state.addressList[i].isDefault == "0"
                                                                          ? Container()
                                                                          : Container(
                                                                              margin: const EdgeInsetsDirectional.only(top: 5),
                                                                              padding: EdgeInsetsDirectional.only(
                                                                                  bottom: height! /
                                                                                      99.0 /* , start: width! / 40.0, end: width! / 40.0 */),
                                                                              child: Column(children: [
                                                                                Row(children: [
                                                                                  state.addressList[i].type == homeKey
                                                                                      ? SvgPicture.asset(
                                                                                          DesignConfig.setSvgPath("home_address"),
                                                                                        )
                                                                                      : state.addressList[i].type == officeKey
                                                                                          ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                                                                                          : SvgPicture.asset(
                                                                                              DesignConfig.setSvgPath("other_address")),
                                                                                  SizedBox(width: height! / 99.0),
                                                                                  Text(
                                                                                    state.addressList[i]
                                                                                        .type! /*  == StringsRes.home
                                                                            ? StringsRes.home
                                                                            : state.addressList[i].type == StringsRes.office
                                                                                ? StringsRes.office
                                                                                : StringsRes.other */
                                                                                    ,
                                                                                    style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                                                        fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ]),
                                                                                SizedBox(width: height! / 99.0),
                                                                                Row(
                                                                                  children: [
                                                                                    SizedBox(width: width! / 11.0),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        "${state.addressList[i].address!},${state.addressList[i].area!},${state.addressList[i].city},${state.addressList[i].state!},${state.addressList[i].pincode!}",
                                                                                        style: TextStyle(
                                                                                            fontSize: 14,
                                                                                            color: Theme.of(context).colorScheme.onSecondary),
                                                                                        maxLines: 2,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ]),
                                                                            );
                                                                    });
                                                              }
                                                              return const SizedBox();
                                                            });
                                                      }),
                                                    ),
                                            ],
                                          ),
                                        ),
                                  /* 
                                  context.read<AddressCubit>().gerCurrentAddress().id == "" ||
                                          context.read<AddressCubit>().gerCurrentAddress().id!.isEmpty ||
                                          orderTypeIndex == 1
                                      ? const SizedBox()
                                      : Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 80.0,
                                            bottom: height! / 50.0,
                                            start: width! / 40.0,
                                            end: width! / 40.0,
                                          ),
                                          child: Divider(
                                            color: lightFont.withOpacity(0.50),
                                            height: 1.0,
                                          ),
                                        ), */
                                  Container(
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 60.0),
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                                        Row(children: [
                                          Text(
                                            UiUtils.getTranslatedLabel(context, yourOrderLabel),
                                            style: TextStyle(
                                                fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                          ),
                                          const Spacer(),
                                          BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                            return BlocProvider<ClearCartCubit>(
                                              create: (_) => ClearCartCubit(CartRepository()),
                                              child: Builder(builder: (context) {
                                                return BlocConsumer<ClearCartCubit, ClearCartState>(
                                                    bloc: context.read<ClearCartCubit>(),
                                                    listener: (context, state) {
                                                      if (state is ClearCartSuccess) {
                                                        if (context.read<AuthCubit>().state is AuthInitial ||
                                                            context.read<AuthCubit>().state is Unauthenticated) {
                                                          print("");
                                                        } else {
                                                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, cartLabel),
                                                              UiUtils.getTranslatedLabel(context, clearCartLabel), context, false,
                                                              type: "1");
                                                          context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
                                                          setState(() {
                                                            restaurantName = UiUtils.getTranslatedLabel(context, myCartLabel);
                                                            restaurantAddress = "";
                                                            restaurantCookTime = "";
                                                          });
                                                          context.read<ProductLoadCubit>().clearQty(cartList.data![0].productDetails);
                                                        }
                                                      } else if (state is ClearCartFailure) {
                                                        if (context.read<AuthCubit>().state is AuthInitial ||
                                                            context.read<AuthCubit>().state is Unauthenticated) {
                                                          print("");
                                                        } else {
                                                          UiUtils.setSnackBar(
                                                              UiUtils.getTranslatedLabel(context, cartLabel), state.errorMessage, context, false,
                                                              type: "2");
                                                        }
                                                      }
                                                    },
                                                    builder: (context, state) {
                                                      return InkWell(
                                                        onTap: () {
                                                          if (context.read<AuthCubit>().state is AuthInitial ||
                                                              context.read<AuthCubit>().state is Unauthenticated) {
                                                            db.clearCart();
                                                          } else {
                                                            context.read<ClearCartCubit>().clearCart(userId: context.read<AuthCubit>().getId());
                                                          }
                                                        },
                                                        child: Text(
                                                          UiUtils.getTranslatedLabel(context, clearCartLabel),
                                                          style: TextStyle(
                                                              fontSize: 12, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                                                        ),
                                                      );
                                                    });
                                              }),
                                            );
                                          }),
                                        ]),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                          ),
                                          child: DesignConfig.divider(),
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: cartList.data!.length,
                                            itemBuilder: (BuildContext context, i) {
                                              /*int qty = int.parse(cartList.data![i].qty!);
                                              double price = double.parse(cartList.data![i].specialPrice!);
                                              if (price == 0) {
                                                price = double.parse(cartList.data![i].price!);
                                              }

                                              double off = 0;
                                              if (cartList.data![i].specialPrice! != "0") {
                                                off = (double.parse(cartList.data![i].price!) - double.parse(cartList.data![i].specialPrice!))
                                                    .toDouble();
                                                off = off * 100 / double.parse(cartList.data![i].price!).toDouble();
                                              }*/
                                              //availableTime.clear();
                                              /* if(availableTime.isNotEmpty){}else{
                                              availableTime.add(cartList.data![i].productDetails![0].availableTime!); 
                                              } */
                                              return BlocProvider<RemoveFromCartCubit>(
                                                create: (_) => RemoveFromCartCubit(CartRepository()),
                                                child: Builder(builder: (context) {
                                                  return Container(
                                                      padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                                      width: width!,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              cartList.data![i].image!.isEmpty
                                                                  ? const ClipRRect(
                                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                                      child: SizedBox(
                                                                        width: 35,
                                                                        height: 35,
                                                                      ))
                                                                  : ClipRRect(
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                      child: ColorFiltered(
                                                                        colorFilter:
                                                                            cartList.data![i].productDetails![0].partnerDetails![0].isRestroOpen ==
                                                                                    "1"
                                                                                ? const ColorFilter.mode(
                                                                                    Colors.transparent,
                                                                                    BlendMode.multiply,
                                                                                  )
                                                                                : const ColorFilter.mode(
                                                                                    Colors.grey,
                                                                                    BlendMode.saturation,
                                                                                  ),
                                                                        child: DesignConfig.imageWidgets(cartList.data![i].image!, 35, 35, "2"),
                                                                      )),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional.only(
                                                                      start: width! / 50.0,
                                                                      //top: height! / 99.0,
                                                                      bottom: height! / 99.0),
                                                                  child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Column(
                                                                            children: List.generate(cartList.data![i].productDetails!.length, (j) {
                                                                          //ProductDetails productDetail = cartList.data![i].productDetails![j];
                                                                          return Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                /* Row(children:[
                                                                                cartList.data![i].productDetails![j].indicator == "1"
                                                                        ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                                        : cartList.data![i].productDetails![j].indicator == "2"
                                                                            ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                                            : const SizedBox(height: 15, width: 15.0),
                                                                            const SizedBox(width: 5.0),
                                                                        Expanded(flex: 2,
                                                                          child: Text("${cartList.data![i].qty!} x ${cartList.data![i].name!}",
                                                                            textAlign: Directionality.of(context) == TextDirection.rtl
                                                                                ? TextAlign.right
                                                                                : TextAlign.left,
                                                                            style: const TextStyle(
                                                                                color: Theme.of(context).colorScheme.onSecondary,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400, fontStyle:  FontStyle.normal,
                                                                                overflow: TextOverflow.ellipsis),
                                                                            maxLines: 1,
                                                                          ),
                                                                        ),
                                                                        ]), */
                                                                                Column(
                                                                                    children: List.generate(
                                                                                        cartList.data![i].productDetails![j].variants!.length, (l) {
                                                                                  VariantsModel variantData =
                                                                                      cartList.data![i].productDetails![j].variants![l];
                                                                                  double price = double.parse(variantData.specialPrice!);
                                                                                  if (price == 0) {
                                                                                    price = double.parse(variantData.price!);
                                                                                  }

                                                                                  double off = 0;
                                                                                  if (cartList.data![i].specialPrice! != "0") {
                                                                                    off = (double.parse(variantData.price!) -
                                                                                            double.parse(variantData.specialPrice!))
                                                                                        .toDouble();
                                                                                    off = off * 100 / double.parse(variantData.price!).toDouble();
                                                                                  }
                                                                                  return (cartList.data![i].productVariantId ==
                                                                                          cartList.data![i].productDetails![j].variants![l].id!)
                                                                                      ? Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                              Row(children: [
                                                                                                cartList.data![i].productDetails![j].indicator == "1"
                                                                                                    ? SvgPicture.asset(
                                                                                                        DesignConfig.setSvgPath("veg_icon"),
                                                                                                        width: 15,
                                                                                                        height: 15)
                                                                                                    : cartList.data![i].productDetails![j]
                                                                                                                .indicator ==
                                                                                                            "2"
                                                                                                        ? SvgPicture.asset(
                                                                                                            DesignConfig.setSvgPath("non_veg_icon"),
                                                                                                            width: 15,
                                                                                                            height: 15)
                                                                                                        : const SizedBox(height: 15, width: 15.0),
                                                                                                const SizedBox(width: 5.0),
                                                                                                Expanded(
                                                                                                  flex: 2,
                                                                                                  child: Text(
                                                                                                    "${cartList.data![i].qty!} x ${cartList.data![i].name!}",
                                                                                                    textAlign: Directionality.of(context) ==
                                                                                                            TextDirection.rtl
                                                                                                        ? TextAlign.right
                                                                                                        : TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                        color:
                                                                                                            Theme.of(context).colorScheme.onSecondary,
                                                                                                        fontSize: 14,
                                                                                                        fontWeight: FontWeight.w400,
                                                                                                        fontStyle: FontStyle.normal,
                                                                                                        overflow: TextOverflow.ellipsis),
                                                                                                    maxLines: 1,
                                                                                                  ),
                                                                                                ),
                                                                                                BlocConsumer<ManageCartCubit, ManageCartState>(
                                                                                                    bloc: context.read<ManageCartCubit>(),
                                                                                                    listener: (context, state) {
                                                                                                      print(state.toString());
                                                                                                      if (state is ManageCartFailure) {
                                                                                                        if (state.errorStatusCode.toString() ==
                                                                                                            "102") {
                                                                                                          reLogin(context);
                                                                                                        }
                                                                                                      }
                                                                                                      if (state is ManageCartSuccess) {
                                                                                                        if (context.read<AuthCubit>().state
                                                                                                                is AuthInitial ||
                                                                                                            context.read<AuthCubit>().state
                                                                                                                is Unauthenticated) {
                                                                                                          return;
                                                                                                        } else {
                                                                                                          final currentCartModel = context
                                                                                                              .read<GetCartCubit>()
                                                                                                              .getCartModel();
                                                                                                          context.read<GetCartCubit>().updateCartList(
                                                                                                              currentCartModel.updateCart(
                                                                                                                  state.data,
                                                                                                                  (int.parse(currentCartModel
                                                                                                                                  .totalQuantity ??
                                                                                                                              '0') +
                                                                                                                          int.parse(
                                                                                                                              state.totalQuantity!))
                                                                                                                      .toString(),
                                                                                                                  state.subTotal,
                                                                                                                  state.taxPercentage,
                                                                                                                  state.taxAmount,
                                                                                                                  state.overallAmount,
                                                                                                                  List.from(state.variantId ?? [])
                                                                                                                    ..addAll(
                                                                                                                        currentCartModel.variantId ??
                                                                                                                            [])));
                                                                                                          context
                                                                                                              .read<ProductLoadCubit>()
                                                                                                              .updateQuntity(
                                                                                                                  cartList
                                                                                                                      .data![i].productDetails![j],
                                                                                                                  cartList.data![i].qty
                                                                                                                      .toString(), //widget.qtyData[widget.productVariantId!].toString(),
                                                                                                                  cartList.data![i].productVariantId
                                                                                                                      .toString());
                                                                                                          print(currentCartModel.variantId);
                                                                                                          context
                                                                                                              .read<ValidatePromoCodeCubit>()
                                                                                                              .getValidatePromoCode(
                                                                                                                  promoCode,
                                                                                                                  context.read<AuthCubit>().getId(),
                                                                                                                  state.overallAmount!
                                                                                                                      .toStringAsFixed(2),
                                                                                                                  walletBalanceUsed.toString(), context.read<GetCartCubit>().cartPartnerId());
                                                                                                        }
                                                                                                      } else if (state is ManageCartFailure) {
                                                                                                        if (context.read<AuthCubit>().state
                                                                                                                is AuthInitial ||
                                                                                                            context.read<AuthCubit>().state
                                                                                                                is Unauthenticated) {
                                                                                                          return;
                                                                                                        } else {
                                                                                                          UiUtils.setSnackBar(
                                                                                                              UiUtils.getTranslatedLabel(
                                                                                                                  context, addToCartLabel),
                                                                                                              state.errorMessage,
                                                                                                              context,
                                                                                                              false,
                                                                                                              type: "2");
                                                                                                        }
                                                                                                      }
                                                                                                    },
                                                                                                    builder: (context, state) {
                                                                                                      return Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        height: 25.0,
                                                                                                        width: width! / 4.8,
                                                                                                        decoration:
                                                                                                            DesignConfig.boxDecorationContainerBorder(
                                                                                                                commentBoxBorderColor,
                                                                                                                textFieldBackground,
                                                                                                                5.0),
                                                                                                        //padding: const EdgeInsetsDirectional.only(top: 6.5, bottom: 6.5),
                                                                                                        child: Row(
                                                                                                            mainAxisAlignment:
                                                                                                                MainAxisAlignment.center,
                                                                                                            crossAxisAlignment:
                                                                                                                CrossAxisAlignment.center,
                                                                                                            children: [
                                                                                                              BlocConsumer<RemoveFromCartCubit,
                                                                                                                      RemoveFromCartState>(
                                                                                                                  bloc: context
                                                                                                                      .read<RemoveFromCartCubit>(),
                                                                                                                  listener: (context, state) {
                                                                                                                    if (state
                                                                                                                        is RemoveFromCartSuccess) {
                                                                                                                      UiUtils.setSnackBar(
                                                                                                                          UiUtils.getTranslatedLabel(
                                                                                                                              context, deleteLabel),
                                                                                                                          StringsRes
                                                                                                                              .deleteSuccessFully,
                                                                                                                          context,
                                                                                                                          false,
                                                                                                                          type: "1");
                                                                                                                      cartList.data!.removeAt(i);
                                                                                                                      context
                                                                                                                          .read<GetCartCubit>()
                                                                                                                          .getCartUser(
                                                                                                                              userId: context
                                                                                                                                  .read<AuthCubit>()
                                                                                                                                  .getId());
                                                                                                                    } else if (state
                                                                                                                        is RemoveFromCartFailure) {
                                                                                                                      UiUtils.setSnackBar(
                                                                                                                          UiUtils.getTranslatedLabel(
                                                                                                                              context, cartLabel),
                                                                                                                          state.errorMessage,
                                                                                                                          context,
                                                                                                                          false,
                                                                                                                          type: "2");
                                                                                                                      if (state.errorStatusCode
                                                                                                                              .toString() ==
                                                                                                                          "102") {
                                                                                                                        reLogin(context);
                                                                                                                      }
                                                                                                                    }
                                                                                                                  },
                                                                                                                  builder: (context, state) {
                                                                                                                    return Padding(
                                                                                                                      padding:
                                                                                                                          const EdgeInsetsDirectional
                                                                                                                              .only(end: 8.0),
                                                                                                                      child: InkWell(
                                                                                                                        onTap: () {
                                                                                                                          setState(() {
                                                                                                                            if (int.parse(cartList
                                                                                                                                    .data![i].qty!) <=
                                                                                                                                int.parse(cartList
                                                                                                                                    .data![i]
                                                                                                                                    .minimumOrderQuantity!)) {
                                                                                                                              context
                                                                                                                                  .read<
                                                                                                                                      RemoveFromCartCubit>()
                                                                                                                                  .removeFromCart(
                                                                                                                                      userId: context
                                                                                                                                          .read<
                                                                                                                                              AuthCubit>()
                                                                                                                                          .getId(),
                                                                                                                                      productVariantId:
                                                                                                                                          cartList
                                                                                                                                              .data![
                                                                                                                                                  i]
                                                                                                                                              .productVariantId);
                                                                                                                            } else if (int.parse(
                                                                                                                                    cartList.data![i]
                                                                                                                                        .qty!) ==
                                                                                                                                1) {
                                                                                                                              context
                                                                                                                                  .read<
                                                                                                                                      RemoveFromCartCubit>()
                                                                                                                                  .removeFromCart(
                                                                                                                                      userId: context
                                                                                                                                          .read<
                                                                                                                                              AuthCubit>()
                                                                                                                                          .getId(),
                                                                                                                                      productVariantId:
                                                                                                                                          cartList
                                                                                                                                              .data![
                                                                                                                                                  i]
                                                                                                                                              .productVariantId);
                                                                                                                            } else {
                                                                                                                              cartList.data![i].qty =
                                                                                                                                  (int.parse(cartList
                                                                                                                                              .data![
                                                                                                                                                  i]
                                                                                                                                              .qty!) -
                                                                                                                                          1)
                                                                                                                                      .toString();
                                                                                                                              /* if (int.parse(cartList.data![i].qty!) <= int.parse(cartList.data![i].minimumOrderQuantity!)) {
                                                                                                  //widget.qty = int.parse(widget.productDetailsModel.quantityStepSize!);
                                                                                                  cartList.data![i].qty = cartList.data![i].minimumOrderQuantity!;
                                                                                                } else { */
                                                                                                                              List<AddOnsDataModel>
                                                                                                                                  addOnsDataModel =
                                                                                                                                  variantData
                                                                                                                                      .addOnsData!;
                                                                                                                              List<String> addOnIds =
                                                                                                                                  [];
                                                                                                                              List<String> addOnQty =
                                                                                                                                  [];
                                                                                                                              for (int qt = 0;
                                                                                                                                  qt <
                                                                                                                                      addOnsDataModel
                                                                                                                                          .length;
                                                                                                                                  qt++) {
                                                                                                                                addOnIds.add(
                                                                                                                                    addOnsDataModel[
                                                                                                                                            qt]
                                                                                                                                        .id
                                                                                                                                        .toString());
                                                                                                                                addOnQty.add((int.parse(
                                                                                                                                            addOnsDataModel[
                                                                                                                                                    qt]
                                                                                                                                                .qty
                                                                                                                                                .toString()) -
                                                                                                                                        1)
                                                                                                                                    .toString());
                                                                                                                              }
                                                                                                                              context
                                                                                                                                  .read<
                                                                                                                                      ManageCartCubit>()
                                                                                                                                  .manageCartUser(
                                                                                                                                    userId: context
                                                                                                                                        .read<
                                                                                                                                            AuthCubit>()
                                                                                                                                        .getId(),
                                                                                                                                    productVariantId:
                                                                                                                                        cartList
                                                                                                                                            .data![i]
                                                                                                                                            .productVariantId,
                                                                                                                                    isSavedForLater:
                                                                                                                                        "0",
                                                                                                                                    qty: cartList
                                                                                                                                        .data![i].qty,
                                                                                                                                    addOnId: addOnIds
                                                                                                                                            .isNotEmpty
                                                                                                                                        ? addOnIds
                                                                                                                                            .join(",")
                                                                                                                                            .toString()
                                                                                                                                        : "",
                                                                                                                                    addOnQty: addOnQty
                                                                                                                                            .isNotEmpty
                                                                                                                                        ? addOnQty
                                                                                                                                            .join(",")
                                                                                                                                            .toString()
                                                                                                                                        : "",
                                                                                                                                  );
                                                                                                                              //}
                                                                                                                            }

                                                                                                                            //UiUtils.clearAll();
                                                                                                                            if (orderTypeIndex
                                                                                                                                    .toString() ==
                                                                                                                                "0") {
                                                                                                                              finalTotal = cartList
                                                                                                                                      .overallAmount! +
                                                                                                                                  deliveryCharge;
                                                                                                                            } else {
                                                                                                                              finalTotal = cartList
                                                                                                                                      .overallAmount! -
                                                                                                                                  deliveryCharge;
                                                                                                                            }

                                                                                                                            context
                                                                                                                                .read<
                                                                                                                                    ValidatePromoCodeCubit>()
                                                                                                                                .getValidatePromoCode(
                                                                                                                                    promoCode,
                                                                                                                                    context
                                                                                                                                        .read<
                                                                                                                                            AuthCubit>()
                                                                                                                                        .getId(),
                                                                                                                                    overAllAmount
                                                                                                                                        .toStringAsFixed(
                                                                                                                                            2),
                                                                                                                                    walletBalanceUsed
                                                                                                                                        .toString(), context.read<GetCartCubit>().cartPartnerId());
                                                                                                                            //cartList.data!.removeWhere((element) => element.productVariantId == cartList.data![i].productVariantId);
                                                                                                                          });
                                                                                                                        },
                                                                                                                        child: Icon(Icons.remove,
                                                                                                                            color: Theme.of(context)
                                                                                                                                .colorScheme
                                                                                                                                .onSecondary,
                                                                                                                            size: 15.0),
                                                                                                                      ),
                                                                                                                    );
                                                                                                                  }),
                                                                                                              SizedBox(width: width! / 50.0),
                                                                                                              Text(cartList.data![i].qty!,
                                                                                                                  textAlign: TextAlign.center,
                                                                                                                  style: TextStyle(
                                                                                                                    color: Theme.of(context)
                                                                                                                        .colorScheme
                                                                                                                        .onSecondary,
                                                                                                                    fontSize: 10,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                    fontStyle: FontStyle.normal,
                                                                                                                  )),
                                                                                                              //Text(qty.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                                                                                                              SizedBox(width: width! / 50.0),
                                                                                                              Padding(
                                                                                                                padding:
                                                                                                                    const EdgeInsetsDirectional.only(
                                                                                                                        start: 8.0),
                                                                                                                child: InkWell(
                                                                                                                    onTap: () {
                                                                                                                      if (cartList
                                                                                                                              .data![i]
                                                                                                                              .productDetails![0]
                                                                                                                              .type ==
                                                                                                                          "variable_product") {
                                                                                                                        itemEditQtyBottomSheet(
                                                                                                                            cartList.data![i]
                                                                                                                                .productDetails!,
                                                                                                                            j,
                                                                                                                            variantData.id!,
                                                                                                                            i,
                                                                                                                            cartList.data!,
                                                                                                                            l);
                                                                                                                      } else {
                                                                                                                        setState(() {
                                                                                                                          if (int.parse(cartList
                                                                                                                                  .data![i].qty!) <
                                                                                                                              int.parse(cartList
                                                                                                                                  .data![i]
                                                                                                                                  .productDetails![l]
                                                                                                                                  .minimumOrderQuantity!)) {
                                                                                                                            Navigator.pop(context);
                                                                                                                            UiUtils.setSnackBar(
                                                                                                                                UiUtils
                                                                                                                                    .getTranslatedLabel(
                                                                                                                                        context,
                                                                                                                                        quantityLabel),
                                                                                                                                "${StringsRes.minimumQuantityAllowed} ${cartList.data![i].productDetails![l].minimumOrderQuantity!}",
                                                                                                                                context,
                                                                                                                                false,
                                                                                                                                type: "2");
                                                                                                                          } else if (int.parse(
                                                                                                                                  cartList.data![i]
                                                                                                                                      .qty!) >=
                                                                                                                              int.parse(cartList
                                                                                                                                  .data![i]
                                                                                                                                  .productDetails![l]
                                                                                                                                  .totalAllowedQuantity!)) {
                                                                                                                            cartList.data![i].qty =
                                                                                                                                cartList
                                                                                                                                    .data![i]
                                                                                                                                    .productDetails![
                                                                                                                                        l]
                                                                                                                                    .totalAllowedQuantity!;
                                                                                                                            //Navigator.pop(context);
                                                                                                                            UiUtils.setSnackBar(
                                                                                                                                UiUtils
                                                                                                                                    .getTranslatedLabel(
                                                                                                                                        context,
                                                                                                                                        quantityLabel),
                                                                                                                                "${StringsRes.minimumQuantityAllowed} ${cartList.data![i].productDetails![l].totalAllowedQuantity!}",
                                                                                                                                context,
                                                                                                                                false,
                                                                                                                                type: "2");
                                                                                                                          } else {
                                                                                                                            cartList.data![i].qty =
                                                                                                                                (int.parse(cartList
                                                                                                                                            .data![i]
                                                                                                                                            .qty!) +
                                                                                                                                        1)
                                                                                                                                    .toString();
                                                                                                                            List<AddOnsDataModel>
                                                                                                                                addOnsDataModel =
                                                                                                                                variantData
                                                                                                                                    .addOnsData!;
                                                                                                                            List<String> addOnIds =
                                                                                                                                [];
                                                                                                                            List<String> addOnQty =
                                                                                                                                [];
                                                                                                                            for (int qt = 0;
                                                                                                                                qt <
                                                                                                                                    addOnsDataModel
                                                                                                                                        .length;
                                                                                                                                qt++) {
                                                                                                                              addOnIds.add(
                                                                                                                                  addOnsDataModel[qt]
                                                                                                                                      .id
                                                                                                                                      .toString());
                                                                                                                              addOnQty.add((int.parse(
                                                                                                                                          addOnsDataModel[
                                                                                                                                                  qt]
                                                                                                                                              .qty
                                                                                                                                              .toString()) +
                                                                                                                                      1)
                                                                                                                                  .toString());
                                                                                                                            }
                                                                                                                            context
                                                                                                                                .read<
                                                                                                                                    ManageCartCubit>()
                                                                                                                                .manageCartUser(
                                                                                                                                  userId: context
                                                                                                                                      .read<
                                                                                                                                          AuthCubit>()
                                                                                                                                      .getId(),
                                                                                                                                  productVariantId:
                                                                                                                                      cartList
                                                                                                                                          .data![i]
                                                                                                                                          .productVariantId,
                                                                                                                                  isSavedForLater:
                                                                                                                                      "0",
                                                                                                                                  qty: cartList
                                                                                                                                      .data![i].qty,
                                                                                                                                  addOnId: addOnIds
                                                                                                                                          .isNotEmpty
                                                                                                                                      ? addOnIds
                                                                                                                                          .join(",")
                                                                                                                                          .toString()
                                                                                                                                      : "",
                                                                                                                                  addOnQty: addOnQty
                                                                                                                                          .isNotEmpty
                                                                                                                                      ? addOnQty
                                                                                                                                          .join(",")
                                                                                                                                          .toString()
                                                                                                                                      : "",
                                                                                                                                );
                                                                                                                            //cartList.data![i].qty = (int.parse(cartList.data![i].qty!) +1);
                                                                                                                          }
                                                                                                                          //widget.qtyData[widget.productVariantId!] = widget.qty!;
                                                                                                                          //productDetailsModel.variants![0].cartCount = (int.parse(productDetailsModel.variants![0].cartCount!) + 1).toString();
                                                                                                                        });
                                                                                                                      }
                                                                                                                    },
                                                                                                                    /* onTap: () {
                                                                                        setState(() {
                                                                                          if (widget.qty! >= int.parse(widget.productDetailsModel.totalAllowedQuantity!)) {
                                                                                            widget.qty = int.parse(widget.productDetailsModel.totalAllowedQuantity!);
                                                                                            Navigator.pop(context);
                                                                                            UiUtils.setSnackBar(
                                                                                                StringsRes.quantity,
                                                                                                "${StringsRes.minimumQuantityAllowed} ${widget.productDetailsModel.totalAllowedQuantity!}",
                                                                                                context,
                                                                                                false,
                                                                                                type: "2");
                                                                                          } else {
                                                                                            widget.qty = (widget.qty! +1/* + int.parse(widget.productDetailsModel.quantityStepSize!) */);
                                                                                          }
                                                                                          widget.qtyData[widget.productVariantId!] = widget.qty!;
                                                                                          //productDetailsModel.variants![0].cartCount = (int.parse(productDetailsModel.variants![0].cartCount!) + 1).toString();
                                                                                        });
                                                                                      }, */
                                                                                                                    child: Icon(Icons.add,
                                                                                                                        color: Theme.of(context)
                                                                                                                            .colorScheme
                                                                                                                            .onSecondary,
                                                                                                                        size: 15.0)),
                                                                                                              ),
                                                                                                            ]),
                                                                                                      );
                                                                                                    })
                                                                                              ]),
                                                                                              SingleChildScrollView(
                                                                                                physics: const NeverScrollableScrollPhysics(),
                                                                                                scrollDirection: Axis.horizontal,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    /* 
                                                                                                      variantData.attrName != ""
                                                                                                          ? Text("${variantData.attrName!} : ",
                                                                                                              textAlign: TextAlign.left,
                                                                                                              style: const TextStyle(
                                                                                                                  color: lightFont,
                                                                                                                  fontSize: 12,
                                                                                                                  fontWeight: FontWeight.w500))
                                                                                                          : Container(), */
                                                                                                    variantData.variantValues != ""
                                                                                                        ? Text("${variantData.variantValues!} ",
                                                                                                            textAlign: TextAlign.left,
                                                                                                            style: const TextStyle(
                                                                                                              color: lightFont,
                                                                                                              fontSize: 12,
                                                                                                            ))
                                                                                                        : Container(),
                                                                                                    cartList.data![i].productDetails![j].variants![l]
                                                                                                            .addOnsData!.isNotEmpty
                                                                                                        ? Row(
                                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                                            mainAxisAlignment:
                                                                                                                MainAxisAlignment.start,
                                                                                                            /*crossAxisAlignment:
                                                                                                                WrapCrossAlignment.start,*/
                                                                                                            children: List.generate(
                                                                                                                cartList
                                                                                                                    .data![i]
                                                                                                                    .productDetails![j]
                                                                                                                    .variants![l]
                                                                                                                    .addOnsData!
                                                                                                                    .length, (m) {
                                                                                                              AddOnsDataModel addOnData =
                                                                                                                  variantData.addOnsData![m];
                                                                                                              return GestureDetector(
                                                                                                                onTap: () {},
                                                                                                                child: Text(
                                                                                                                  "${addOnData.title!}, ",
                                                                                                                  textAlign: TextAlign.center,
                                                                                                                  style: const TextStyle(
                                                                                                                      color: lightFontColor,
                                                                                                                      fontSize: 12,
                                                                                                                      overflow:
                                                                                                                          TextOverflow.ellipsis),
                                                                                                                  maxLines: 1,
                                                                                                                ),
                                                                                                              );
                                                                                                            }))
                                                                                                        : Container(),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(height: 5.0),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                children: [
                                                                                                  (cartList.data![i].productDetails![j].type ==
                                                                                                          "variable_product")
                                                                                                      ? InkWell(
                                                                                                          onTap: () {
                                                                                                            setState(() {
                                                                                                              bottomModelSheetShowEdit(
                                                                                                                  cartList.data![i].productDetails!,
                                                                                                                  j,
                                                                                                                  variantData.id!,
                                                                                                                  l);
                                                                                                            });
                                                                                                          },
                                                                                                          child: Container(
                                                                                                            width: width! / 8.0,
                                                                                                            padding: const EdgeInsets.all(3.0),
                                                                                                            decoration:
                                                                                                                DesignConfig.boxDecorationContainer(
                                                                                                                    textFieldBackground, 4.0),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  UiUtils.getTranslatedLabel(
                                                                                                                      context, editLabel),
                                                                                                                  style: TextStyle(
                                                                                                                      fontSize: 12,
                                                                                                                      color: Theme.of(context)
                                                                                                                          .colorScheme
                                                                                                                          .primary),
                                                                                                                ),
                                                                                                                Icon(Icons.keyboard_arrow_down,
                                                                                                                    color: Theme.of(context)
                                                                                                                        .colorScheme
                                                                                                                        .primary,
                                                                                                                    size: 10.0),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        )
                                                                                                      : const SizedBox(),
                                                                                                  const Spacer(),
                                                                                                  Row(
                                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                            context
                                                                                                                    .read<SystemConfigCubit>()
                                                                                                                    .getCurrency() +
                                                                                                                (double.parse(price.toString()) *
                                                                                                                        int.parse(
                                                                                                                            cartList.data![i].qty!))
                                                                                                                    .toStringAsFixed(2),
                                                                                                            textAlign: TextAlign.center,
                                                                                                            style: TextStyle(
                                                                                                                color: Theme.of(context)
                                                                                                                    .colorScheme
                                                                                                                    .onSecondary,
                                                                                                                fontSize: 13,
                                                                                                                fontWeight: FontWeight.w700)),
                                                                                                        off.toStringAsFixed(2) == "0.00"
                                                                                                            ? const SizedBox()
                                                                                                            : Text(
                                                                                                                " | ",
                                                                                                                style: TextStyle(
                                                                                                                    color: Theme.of(context)
                                                                                                                        .colorScheme
                                                                                                                        .onSecondary,
                                                                                                                    fontSize: 12,
                                                                                                                    fontWeight: FontWeight.w700,
                                                                                                                    overflow: TextOverflow.ellipsis),
                                                                                                                maxLines: 1,
                                                                                                              ),
                                                                                                        //SizedBox(width: width! / 99.0),
                                                                                                        off.toStringAsFixed(2) == "0.00" ||
                                                                                                                off.toStringAsFixed(2) == "0.0"
                                                                                                            ? const SizedBox()
                                                                                                            : Text(
                                                                                                                context
                                                                                                                        .read<SystemConfigCubit>()
                                                                                                                        .getCurrency() +
                                                                                                                    (double.parse(
                                                                                                                            cartList.data![i].price!))
                                                                                                                        .toStringAsFixed(2),
                                                                                                                style: const TextStyle(
                                                                                                                    decoration:
                                                                                                                        TextDecoration.lineThrough,
                                                                                                                    letterSpacing: 0,
                                                                                                                    color: lightFont,
                                                                                                                    fontSize: 12,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    overflow: TextOverflow.ellipsis),
                                                                                                                maxLines: 1,
                                                                                                              ),
                                                                                                      ]),
                                                                                                ],
                                                                                              ),
                                                                                              const SizedBox(height: 5.0),
                                                                                            ])
                                                                                      : Container();
                                                                                })),
                                                                              ]);
                                                                        })),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsetsDirectional.only(
                                                              top: height! / 99.0,
                                                              bottom: height! / 99.0,
                                                            ),
                                                            child: DesignConfig.divider(),
                                                          ),
                                                        ],
                                                      ));
                                                }),
                                              );
                                            } /*)*/),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            start: width! / 40.0,
                                            end: width! / 40.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(Routes.restaurantDetail,
                                                  arguments: {'restaurant': cartList.data![0].productDetails![0].partnerDetails![0]});
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 20.0),
                                                const SizedBox(width: 2.0),
                                                Text(UiUtils.getTranslatedLabel(context, addMoreFoodInCartLabel),
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.primary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FontStyle.normal,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ])),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => const OfferCouponsScreen(),
                                        ),
                                      ).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            promoCode = value['code'];
                                            context.read<ValidatePromoCodeCubit>().getValidatePromoCode(promoCode, context.read<AuthCubit>().getId(),
                                                cartList.overallAmount!.toStringAsFixed(2), walletBalanceUsed.toString(), context.read<GetCartCubit>().cartPartnerId());
                                            if (orderTypeIndex.toString() == "0") {
                                              finalTotal = value['finalAmount'] + deliveryCharge;
                                            } else {
                                              finalTotal = value['finalAmount'] - deliveryCharge;
                                            }
                                            promoAmt = value['amount'];
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: width!,
                                      margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 40.0, end: width! / 40.0),
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 70.0, bottom: height! / 70.0, start: width! / 40.0, end: width! / 40.0),
                                      child:
                                          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                        Text(UiUtils.getTranslatedLabel(context, addCouponLabel),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                        const Spacer(),
                                        Text(
                                          UiUtils.getTranslatedLabel(context, viewAllLabel),
                                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                                        ),
                                      ]),
                                    ),
                                  ),
                                  promoCode != ""
                                      ? Padding(
                                          padding:
                                              EdgeInsetsDirectional.only(top: height! / 70.0, start: width! / 40.0, bottom: 5.0, end: width! / 40.0),
                                          child: Row(
                                            children: [
                                              Text(UiUtils.getTranslatedLabel(context, usedCouponLabel),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                              const Spacer(),
                                              promoAmt == 0
                                                  ? const SizedBox()
                                                  : InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          promoCode = "";
                                                          promoAmt = 0;
                                                          if (orderTypeIndex.toString() == "0") {
                                                            finalTotal = cartList.overallAmount! + deliveryCharge;
                                                          } else {
                                                            finalTotal = cartList.overallAmount! - deliveryCharge;
                                                          }
                                                        });
                                                      },
                                                      child: Text(
                                                        UiUtils.getTranslatedLabel(context, removeCouponLabel),
                                                        style: TextStyle(
                                                            fontSize: 12, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  promoCode != ""
                                      ? Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            start: width! / 40.0,
                                            end: width! / 40.0,
                                          ),
                                          child: BlocConsumer<ValidatePromoCodeCubit, ValidatePromoCodeState>(
                                              bloc: context.read<ValidatePromoCodeCubit>(),
                                              listener: (context, state) {
                                                if (state is ValidatePromoCodeFetchFailure) {
                                                  const Text("");
                                                }
                                                if (state is ValidatePromoCodeFetchSuccess) {
                                                  promoCode = state.promoCodeValidateModel!.promoCode!.toString();
                                                  promoAmt = double.parse(state.promoCodeValidateModel!.finalDiscount!);
                                                  if (orderTypeIndex.toString() == "0") {
                                                    finalTotal = double.parse(state.promoCodeValidateModel!.finalTotal!) + deliveryCharge;
                                                  } else {
                                                    finalTotal = double.parse(state.promoCodeValidateModel!.finalTotal!) - deliveryCharge;
                                                  }
                                                }
                                              },
                                              builder: (context, state) {
                                                if (state is ValidatePromoCodeFetchSuccess) {
                                                  return Row(
                                                    children: [
                                                      Text(StringsRes.coupon + state.promoCodeValidateModel!.promoCode.toString(),
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                                                      const Spacer(),
                                                      Text(
                                                          context.read<SystemConfigCubit>().getCurrency() +
                                                              state.promoCodeValidateModel!.finalDiscount.toString(),
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.onPrimary,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700))
                                                      /*Text(context.read<SystemConfigCubit>().getCurrency() + promoAmt.toString(),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w700)),*/
                                                    ],
                                                  );
                                                } else {
                                                  return const SizedBox();
                                                }
                                              }),
                                        )
                                      : Container(),
                                  /* 
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      top: height! / 70.0,
                                      bottom: height! / 70.0,
                                      start: width! / 40.0,
                                      end: width! / 40.0,
                                    ),
                                    child: Divider(
                                      color: lightFont.withOpacity(0.50),
                                      height: 1.0,
                                    ),
                                  ), */
                                  orderTypeIndex.toString() == "1"
                                      ? const SizedBox()
                                      : Container(
                                          width: width!,
                                          padding: EdgeInsetsDirectional.only(
                                              //start: width! / 35.0,
                                              top: height! / 80.0,
                                              //end: width! / 35.0,
                                              bottom: height! / 80.0),
                                          margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 40.0, end: width! / 40.0),
                                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                          child: Column(children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.only(
                                                start: width! / 40.0,
                                                end: width! / 40.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 18,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(UiUtils.getTranslatedLabel(context, tipDeliveryPartnerLabel),
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                                color: Theme.of(context).colorScheme.onSecondary,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w500)),
                                                        const SizedBox(height: 3.0),
                                                        Text(UiUtils.getTranslatedLabel(context, tipDeliveryPartnerSubTitleLabel),
                                                            textAlign: TextAlign.start,
                                                            style: const TextStyle(color: lightFont, fontSize: 12),
                                                            maxLines: 2),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  deliveryTip == 0
                                                      ? const SizedBox()
                                                      : Column(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedIndex = -1;
                                                                  deliveryTip = 0;
                                                                  tipOther = false;
                                                                  deliveryTipController.clear();
                                                                });
                                                              },
                                                              child: Text(
                                                                UiUtils.getTranslatedLabel(context, removeTipLabel),
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Theme.of(context).colorScheme.error,
                                                                    fontWeight: FontWeight.w700),
                                                              ),
                                                            ),
                                                            Text(context.read<SystemConfigCubit>().getCurrency() + deliveryTip.toString(),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14)),
                                                          ],
                                                        ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.only(
                                                top: height! / 70.0,
                                                bottom: height! / 70.0,
                                                start: width! / 40.0,
                                                end: width! / 40.0,
                                              ),
                                              child: DesignConfig.divider(),
                                            ),
                                            deliveryTips(),
                                          ])),
                                  Container(
                                    width: width!,
                                    padding: EdgeInsetsDirectional.only(
                                        start: width! / 35.0, top: height! / 80.0, end: width! / 35.0, bottom: height! / 80.0),
                                    margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 60.0, end: width! / 60.0),
                                    decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(UiUtils.getTranslatedLabel(context, addNotesForFoodPartnerLabel),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 70.0,
                                            bottom: height! / 70.0,
                                          ),
                                          child: DesignConfig.divider(),
                                        ),
                                        addNote(),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsetsDirectional.only(
                                          start: width! / 40.0, top: height! / 80.0, end: width! / 40.0, bottom: height! / 99.0),
                                      width: width!,
                                      margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 40.0, end: width! / 40.0),
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                      child:
                                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(UiUtils.getTranslatedLabel(context, billDetailLabel),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary, fontSize: 15, fontWeight: FontWeight.w700)),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            top: 4.5,
                                            bottom: 4.5,
                                          ),
                                          child: DesignConfig.divider(),
                                        ),
                                        Row(children: [
                                          Text(UiUtils.getTranslatedLabel(context, subTotalLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                          const Spacer(),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + (subTotal).toStringAsFixed(2),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                  fontSize: 15,
                                                  //fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8)),
                                        ]),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            top: 4.5,
                                            bottom: 4.5,
                                          ),
                                          child: Row(children: [
                                            Text(
                                                "${UiUtils.getTranslatedLabel(context, chargesAndTaxesLabel)} (${cartList.taxPercentage!}${StringsRes.percentSymbol})",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                                            const Spacer(),
                                            Text(context.read<SystemConfigCubit>().getCurrency() + cartList.taxAmount!,
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontSize: 12, /* fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                                )),
                                          ]),
                                        ),
                                        Row(children: [
                                          Text(UiUtils.getTranslatedLabel(context, totalLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                          const Spacer(),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + cartList.overallAmount!.toStringAsFixed(2),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                  fontSize: 15,
                                                  //fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8)),
                                        ]),
                                        const Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: 4.5,
                                            bottom: 4.5,
                                          ),
                                          child: DashLineView(
                                            fillRate: 0.7,
                                            direction: Axis.horizontal,
                                          ),
                                        ),
                                        promoAmt != 0
                                            ? Padding(
                                                padding: EdgeInsetsDirectional.only(
                                                  bottom:
                                                      4.5, /* 
                                            start: width! / 40.0,
                                            end: width! / 40.0, */
                                                ),
                                                child: BlocConsumer<ValidatePromoCodeCubit, ValidatePromoCodeState>(
                                                    bloc: context.read<ValidatePromoCodeCubit>(),
                                                    listener: (context, state) {
                                                      if (state is ValidatePromoCodeFetchFailure) {
                                                        const Text("");
                                                      }
                                                      if (state is ValidatePromoCodeFetchSuccess) {
                                                        promoCode = state.promoCodeValidateModel!.promoCode!.toString();
                                                        promoAmt = double.parse(state.promoCodeValidateModel!.finalDiscount!);
                                                        print(promoAmt);
                                                        if (orderTypeIndex.toString() == "0") {
                                                          finalTotal = double.parse(state.promoCodeValidateModel!.finalTotal!) + deliveryCharge;
                                                        } else {
                                                          finalTotal = double.parse(state.promoCodeValidateModel!.finalTotal!) - deliveryCharge;
                                                        }
                                                        print(
                                                            "${state.promoCodeValidateModel!.promoCode!.toString()}=$finalTotal=${state.promoCodeValidateModel!.finalTotal!}");
                                                      }
                                                    },
                                                    builder: (context, state) {
                                                      if (state is ValidatePromoCodeFetchSuccess) {
                                                        return Row(children: [
                                                          Text(StringsRes.coupon + state.promoCodeValidateModel!.promoCode!.toString(),
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                                                          const Spacer(),
                                                          Text(
                                                              " - ${context.read<SystemConfigCubit>().getCurrency()}${state.promoCodeValidateModel!.finalDiscount}",
                                                              textAlign: TextAlign.end,
                                                              style: TextStyle(
                                                                color: Theme.of(context).colorScheme.onPrimary,
                                                                fontSize: 12, /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                                              ))
                                                          /*Text(" - " + context.read<SystemConfigCubit>().getCurrency() + promoAmt.toString(),
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                    color: green,
                                                    fontSize: 12, */ /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/ /*
                                                  )),*/
                                                        ]);
                                                      } else {
                                                        return const SizedBox();
                                                      }
                                                    }),
                                              )
                                            : Container(),
                                        Row(children: [
                                          Text(UiUtils.getTranslatedLabel(context, deliveryTipLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                                          const Spacer(),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + deliveryTip.toString(),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontSize: 12, /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                              )),
                                        ]),
                                        orderTypeIndex.toString() == "0"
                                            ? BlocConsumer<DeliveryChargeCubit, DeliveryChargeState>(
                                                bloc: context.read<DeliveryChargeCubit>(),
                                                listener: (context, state) {
                                                  if (state is DeliveryChargeFailure) {
                                                    print(state.errorMessage);
                                                    if (state.errorStatusCode.toString() == "102") {
                                                      reLogin(context);
                                                    }
                                                    //UiUtils.setSnackBar(StringsRes.address, state.errorCode, context, false, type: "2");
                                                  }
                                                  if (state is DeliveryChargeSuccess) {
                                                    deliveryCharge = double.parse(state.isFreeDelivery == "1" ? "0.0" : state.delivaryCharge.toString());
                                                    if (promoAmt == 0) {
                                                      if (orderTypeIndex.toString() == "0") {
                                                        //finalTotal = subTotal + deliveryCharge;
                                                        finalTotal = cartList.overallAmount! /* -promoAmt  */ + deliveryCharge;
                                                      } else {
                                                        //finalTotal = subTotal - deliveryCharge;
                                                        finalTotal = cartList.overallAmount! /* -promoAmt */ - deliveryCharge;
                                                      }
                                                    } else {
                                                      //finalTotal = subTotal - deliveryCharge;
                                                    }
                                                  }
                                                },
                                                builder: (context, state) {
                                                  print("${state.toString()}-$deliveryCharge");
                                                  //double deliveryCharge = 0;
                                                  if (state is DeliveryChargeSuccess) {
                                                    deliveryCharge = double.parse(state.isFreeDelivery == "1" ? "0.0" : state.delivaryCharge.toString());
                                                    if (orderTypeIndex.toString() == "0") {
                                                      print("$subTotal=$deliveryCharge");
                                                      //finalTotal = subTotal + deliveryCharge - promoAmt;
                                                      finalTotal = cartList.overallAmount! + deliveryCharge - promoAmt;
                                                    }
                                                    //finalTotal = subTotal + deliveryCharge;
                                                    return Padding(
                                                        padding: const EdgeInsetsDirectional.only(
                                                          top: 4.5,
                                                          bottom: 4.5,
                                                        ),
                                                        child: Column(children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(UiUtils.getTranslatedLabel(context, deliveryChargesLabel),
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                                                                  context.read<SystemConfigCubit>().isFirstOrder() == "1"
                                                                      ? Text(
                                                                          " (${UiUtils.getTranslatedLabel(context, freeDeliveryOnOrdersOverLabel)} ${context.read<SystemConfigCubit>().getCurrency()}${context.read<SystemConfigCubit>().getCartMinAmount()})",
                                                                          textAlign: TextAlign.left,
                                                                          style: TextStyle(
                                                                              color: Theme.of(context).colorScheme.onSecondary, fontSize: 11))
                                                                      : const SizedBox.shrink(),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              Text("${context.read<SystemConfigCubit>().getCurrency()}${state.delivaryCharge.toString()}",
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.primary,
                                                                    decoration: state.isFreeDelivery == "1"
                                                                        ? TextDecoration.lineThrough
                                                                        : TextDecoration.none,
                                                                    fontSize: 12, /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                                                  )),
                                                              Text(
                                                                "${state.isFreeDelivery == "1" ? " ${UiUtils.getTranslatedLabel(context, freeLabel)}" : ""}",
                                                                textAlign: TextAlign.end,
                                                                style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.primary,
                                                                  fontSize: 12, fontWeight: FontWeight.w700, /* letterSpacing: 0.8*/
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsetsDirectional.only(
                                                              top: 4.5,
                                                              bottom: 4.5,
                                                            ),
                                                            child: DashLineView(
                                                              fillRate: 0.7,
                                                              direction: Axis.horizontal,
                                                            ),
                                                          ),
                                                          Row(children: [
                                                            Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w700)),
                                                            const Spacer(),
                                                            Text(
                                                                context.read<SystemConfigCubit>().getCurrency() +
                                                                    /* (finalTotal + deliveryTip) */ total().toStringAsFixed(2),
                                                                textAlign: TextAlign.end,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w700,
                                                                    letterSpacing: 0.8)),
                                                          ]),
                                                        ]));
                                                  } else {
                                                    if (orderTypeIndex.toString() == "0") {
                                                      print("$subTotal=$deliveryCharge==${state.toString()}=${cartList.overallAmount}=$promoAmt");
                                                      //finalTotal = subTotal + deliveryCharge - promoAmt;
                                                      finalTotal = cartList.overallAmount! + deliveryCharge - promoAmt;
                                                      print(
                                                          "$subTotal=$deliveryCharge==${state.toString()}=${cartList.overallAmount}=$promoAmt=$finalTotal");
                                                    }
                                                    return Padding(
                                                        padding: const EdgeInsetsDirectional.only(
                                                          top: 4.5,
                                                          bottom: 4.5,
                                                        ),
                                                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                                                          Row(children: [
                                                            /* Padding(
                                                      padding: const EdgeInsetsDirectional.only(
                                                        top: 4.5,
                                                        bottom: 4.5,
                                                      ),
                                                        child: DashLineView(
                                                          fillRate: 0.7,
                                                          direction: Axis.horizontal,
                                                        ),
                                                      ), */
                                                            Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w700)),
                                                            const Spacer(),
                                                            Text(
                                                                context.read<SystemConfigCubit>().getCurrency() +
                                                                    /* (finalTotal + deliveryTip) */ total().toStringAsFixed(2),
                                                                textAlign: TextAlign.end,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w700,
                                                                    letterSpacing: 0.8)),
                                                          ]),
                                                        ]));
                                                  }
                                                })
                                            : const SizedBox(),
                                        orderTypeIndex.toString() == "0"
                                            ? const SizedBox()
                                            : Padding(
                                                padding: EdgeInsetsDirectional.only(
                                                  top: 4.5,
                                                  bottom: 4.5,
                                                  start: width! / 40.0,
                                                  end: width! / 40.0,
                                                ),
                                                child: const DashLineView(
                                                  fillRate: 0.7,
                                                  direction: Axis.horizontal,
                                                ),
                                              ),
                                        orderTypeIndex.toString() == "0"
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsetsDirectional.only(
                                                  top: 4.5,
                                                  bottom: 4.5,
                                                ),
                                                child: Row(children: [
                                                  Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSecondary,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700)),
                                                  const Spacer(),
                                                  Text(
                                                      context.read<SystemConfigCubit>().getCurrency() + /* (finalTotal + deliveryTip - promoAmt) */
                                                          total().toStringAsFixed(2),
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSecondary,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700,
                                                          letterSpacing: 0.8)),
                                                ]),
                                              ),
                                      ])),
                                ],
                              ),
                            )
                            /*}
                  )*/
                            );
                  });
    });
  }

  Future<void> refreshList() async {
    clearAll();
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      status = 0;
      oriPrice = 0;
      getOffLineCart();
      //getOffLineCart();
    } else {
      await context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
      Future.delayed(Duration.zero, () async {
        await context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
      });
    }
  }

  /* Future<bool> navigator() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
    return Future.value(true);
  } */

  @override
  void dispose() {
    addNoteController.dispose();
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
                appBar: DesignConfig.appBar(
                    context,
                    width!,
                    restaurantName.toString(),
                    PreferredSize(
                      preferredSize: Size(width!, height! / 70.0),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: width! / 7.0, end: width! / 40.0, bottom: height! / 80.0),
                          child: RichText(
                            text: TextSpan(
                              text: restaurantAddress.toString(),
                              style: const TextStyle(color: lightFont, fontSize: 10),
                              children: <TextSpan>[
                                TextSpan(
                                    text: restaurantCookTime.isEmpty ? "" : " - $restaurantCookTime",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    )),
                bottomNavigationBar: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                      ? BlocConsumer<OfflineCartCubit, OfflineCartState>(
                          bloc: context.read<OfflineCartCubit>(),
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state is OfflineCartSuccess) {
                              return ButtonContainer(
                                color: Theme.of(context).colorScheme.secondary,
                                height: height,
                                width: width,
                                text: UiUtils.getTranslatedLabel(context, addPersonalDetailsLabel),
                                start: width! / 40.0,
                                end: width! / 40.0,
                                bottom: height! / 55.0,
                                top: 0,
                                status: false,
                                borderColor: Theme.of(context).colorScheme.secondary,
                                textColor: white,
                                onPressed: () {
                                  if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
                                    Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'cart'}).then((value) {
                                      if(mounted){
                                        appDataRefresh(navigatorKey.currentContext!);
                                      }
                                    });
                                    return;
                                  }
                                },
                              );
                            } else {
                              return ButtonContainer(
                                color: Theme.of(context).colorScheme.secondary,
                                height: height,
                                width: width,
                                text: UiUtils.getTranslatedLabel(context, browseMenuLabel),
                                start: width! / 40.0,
                                end: width! / 40.0,
                                bottom: height! / 55.0,
                                top: 0,
                                status: false,
                                borderColor: Theme.of(context).colorScheme.secondary,
                                textColor: white,
                                onPressed: () {
                                  Future.delayed(Duration.zero, () => Navigator.of(context).popUntil((route) => route.isFirst));
                                },
                              );
                            }

                            //final offlineCartList = (state as OfflineCartSuccess).productModel;
                            //isRestaurantOpen = offlineCartList.data![0].partnerDetails![0].isRestroOpen!;
                          })
                      : /* orderTypeIndex.toString() == "0" && context.read<GetCartCubit>().getDeliveryStatus() == "1"
                        ? */
                      BlocConsumer<GetCartCubit, GetCartState>(
                          bloc: context.read<GetCartCubit>(),
                          listener: (context, state) {},
                          builder: (context, state) {
                            print("availableTime:$availableTime-----$checkTime");
                            if (state is GetCartSuccess) {
                              final cartList = state.cartModel;
                              deliveryStatus = cartList.data![0].productDetails![0].partnerDetails![0].permissions!.deliveryOrders!;
                              if (orderTypeIndex.toString() == "0" && deliveryStatus == "1") {
                                return BlocProvider<UpdateAddressCubit>(
                                  create: (_) => UpdateAddressCubit(AddressRepository()),
                                  child: Builder(builder: (context) {
                                    //print(state.toString());
                                    return BlocConsumer<AddressCubit, AddressState>(
                                        bloc: context.read<AddressCubit>(),
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          if (state is AddressProgress || state is AddressInitial) {
                                            return Padding(
                                                padding: EdgeInsetsDirectional.only(top: height! / 10.0),
                                                child: CartSimmer(width: width!, height: height!));
                                          }
                                          if (state is AddressFailure) {
                                            return ButtonContainer(
                                              color: Theme.of(context).colorScheme.secondary,
                                              height: height,
                                              width: width,
                                              text: UiUtils.getTranslatedLabel(context, addAddressLabel),
                                              start: width! / 40.0,
                                              end: width! / 40.0,
                                              bottom: height! / 55.0,
                                              top: 0,
                                              status: false,
                                              borderColor: Theme.of(context).colorScheme.secondary,
                                              textColor: white,
                                              onPressed: () {
                                                //AddressModel addressModel = context.read<AddressCubit>().gerCurrentAddress();
                                                //print("addressModel:${addressModel.id}");
                                                bottomModelSheetShow();
                                              },
                                            );
                                          }
                                          final addressList = (state as AddressSuccess).addressList;
                                          return BlocConsumer<GetCartCubit, GetCartState>(
                                              bloc: context.read<GetCartCubit>(),
                                              listener: (context, state) {
                                                if (state is GetCartSuccess) {
                                                  for (int i = 0; i < addressList.length; i++) {
                                                    if (addressList[i].isDefault == "1") {
                                                      context
                                                          .read<DeliveryChargeCubit>()
                                                          .fetchDeliveryCharge(context.read<AuthCubit>().getId(), addressList[i].id!, state.cartModel.overallAmount.toString());
                                                    }
                                                  }
                                                }
                                                if (state is GetCartFailure) {
                                                  if (state.errorStatusCode.toString() == "102") {
                                                    reLogin(context);
                                                  }
                                                }
                                              },
                                              builder: (context, state) {
                                                if (state is GetCartSuccess) {
                                                  return BlocListener<IsOrderDeliverableCubit, IsOrderDeliverableState>(
                                                    listener: (context, state) {
                                                      if (state is IsOrderDeliverableSuccess) {
                                                        //var sum = 0;
                                                        final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                                        /*for(int i=0; i< currentCartModel.data!.length; i++){
                                                                                                              sum += int.parse(currentCartModel.data![i].qty!);
                                                                                                          }*/
                                                        if (isRestaurantOpen == "1") {
                                                          print("data1");
                                                          if (currentCartModel.data!.length >
                                                              int.parse(context.read<SystemConfigCubit>().getCartMaxItemAllow())) {
                                                            print("data2");
                                                            UiUtils.setSnackBar(
                                                                UiUtils.getTranslatedLabel(context, itemLabel),
                                                                "${StringsRes.maximumItemAllowed} ${context.read<SystemConfigCubit>().getCartMaxItemAllow()}",
                                                                context,
                                                                false,
                                                                type: "2");
                                                          } else {
                                                            print("data3");
                                                            if ((context.read<AuthCubit>().getType() == "google") ||
                                                                (context.read<AuthCubit>().getType() == "facebook")) {
                                                              if (context.read<AuthCubit>().getMobile().isEmpty) {
                                                                Navigator.of(context).pushNamed(Routes.profile, arguments: false);
                                                              } else {
                                                                Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                  'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                  'addNote': addNoteController.text
                                                                });
                                                              }
                                                            } else {
                                                              print("data4${checkTime.any((element) => element != false)}");
                                                              if (availableTime.contains("1")) {
                                                                print("datat2:${checkTime.any((element) => element != false)}");
                                                                if (!checkTime.contains(false)) {
                                                                  Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                    'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                    'addNote': addNoteController.text
                                                                  });
                                                                } else {
                                                                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, itemLabel),
                                                                      StringsRes.oneOfTheItemInYourCartNotDeliveryOnTheTime, context, false,
                                                                      type: "2");
                                                                }
                                                              } else {
                                                                Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                  'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                  'addNote': addNoteController.text
                                                                });
                                                              }
                                                              /* Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                                                                'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                                                                'addNote': addNoteController.text
                                                                                                              }); */
                                                            }
                                                          }
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                                                        }
                                                      }
                                                      if (state is IsOrderDeliverableFailure) {
                                                        UiUtils.setSnackBar(
                                                            UiUtils.getTranslatedLabel(context, addressLabel), state.errorMessage, context, false,
                                                            type: "2");
                                                      }
                                                    },
                                                    child: BlocBuilder<DeliveryChargeCubit, DeliveryChargeState>(
                                                        bloc: context.read<DeliveryChargeCubit>(),
                                                        builder: (context, state) {
                                                          if (state is DeliveryChargeProgress) {
                                                            return ButtonSimmer(width: width!, height: height!);
                                                          }
                                                          return ButtonContainer(
                                                            color: Theme.of(context).colorScheme.secondary,
                                                            height: height,
                                                            width: width,
                                                            text: UiUtils.getTranslatedLabel(context, confirmOrderLabel),
                                                            start: width! / 40.0,
                                                            end: width! / 40.0,
                                                            bottom: height! / 55.0,
                                                            top: 0,
                                                            status: false,
                                                            borderColor: Theme.of(context).colorScheme.secondary,
                                                            textColor: white,
                                                            onPressed: () {
                                                              if (isRestaurantOpen == "1") {
                                                                if (orderTypeIndex.toString() == "0" && deliveryStatus == "1") {
                                                                  context.read<IsOrderDeliverableCubit>().fetchIsOrderDeliverable(
                                                                      context
                                                                          .read<GetCartCubit>()
                                                                          .getCartModel()
                                                                          .data![0]
                                                                          .productDetails![0]
                                                                          .partnerId,
                                                                      latitude.toString(),
                                                                      longitude.toString(),
                                                                      selAddress);
                                                                } else {
                                                                  Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                    'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                    'addNote': addNoteController.text
                                                                  });
                                                                }
                                                              } else {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (_) =>
                                                                        const RestaurantCloseDialog(hours: "", minute: "", status: false));
                                                              }
                                                            },
                                                          );
                                                        }),
                                                  );
                                                }
                                                return ButtonContainer(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  height: height,
                                                  width: width,
                                                  text: UiUtils.getTranslatedLabel(context, browseMenuLabel),
                                                  start: width! / 40.0,
                                                  end: width! / 40.0,
                                                  bottom: height! / 55.0,
                                                  top: 0,
                                                  status: false,
                                                  borderColor: Theme.of(context).colorScheme.secondary,
                                                  textColor: white,
                                                  onPressed: () {
                                                    Future.delayed(Duration.zero, () => Navigator.of(context).popUntil((route) => route.isFirst));
                                                  },
                                                );
                                              });
                                        });
                                  }),
                                );
                              }
                            }
                            return BlocConsumer<GetCartCubit, GetCartState>(
                                bloc: context.read<GetCartCubit>(),
                                listener: (context, state) {},
                                builder: (context, state) {
                                  if (state is GetCartSuccess) {
                                    return ButtonContainer(
                                      color: Theme.of(context).colorScheme.secondary,
                                      height: height,
                                      width: width,
                                      text: UiUtils.getTranslatedLabel(context, confirmOrderLabel),
                                      start: width! / 40.0,
                                      end: width! / 40.0,
                                      bottom: height! / 55.0,
                                      top: 0,
                                      status: false,
                                      borderColor: Theme.of(context).colorScheme.secondary,
                                      textColor: white,
                                      onPressed: () {
                                        if (isRestaurantOpen == "1") {
                                        if (orderTypeIndex.toString() == "0" && deliveryStatus == "1") {
                                          context.read<IsOrderDeliverableCubit>().fetchIsOrderDeliverable(
                                              context.read<GetCartCubit>().getCartModel().data![0].productDetails![0].partnerId,
                                              latitude.toString(),
                                              longitude.toString(),
                                              selAddress);
                                        } else {
                                          Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                            'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                            'addNote': addNoteController.text
                                          });
                                        }
                                        } else {
                                          showDialog(
                                              context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                                        }
                                        /* var sum = 0;
                                      final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                      for(int i=0; i< currentCartModel.data!.length; i++){
                                        sum += int.parse(currentCartModel.data![i].qty!);
                                      }
                                      if (isRestaurantOpen == "1") {
                                        if (currentCartModel.data!.length >
                                          int.parse(context.read<SystemConfigCubit>().getCartMaxItemAllow())) {
                                            UiUtils.setSnackBar(
                                              UiUtils.getTranslatedLabel(context, itemLabel),
                                              "${StringsRes.maximumItemAllowed} ${context.read<SystemConfigCubit>().getCartMaxItemAllow()}",
                                              context,
                                              false,
                                              type: "2");
                                         } else {
                                          if((context.read<AuthCubit>().getType()=="google")||(context.read<AuthCubit>().getType()=="facebook")){
                                            if(context.read<AuthCubit>().getMobile().isEmpty){
                                              Navigator.of(context).pushNamed(Routes.profile, arguments: false);
                                          }}else{
                                                            if(availableTime.contains("1")){
                                                              if(!checkTime.contains(false)){
                                                                 Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                'addNote': addNoteController.text
                                                              });
                                                              }else{
                                                                UiUtils.setSnackBar(
                                                                  UiUtils.getTranslatedLabel(context, itemLabel),
                                                                  StringsRes.oneOfTheItemInYourCartNotDeliveryOnTheTime,
                                                                  context,
                                                                  false,
                                                                  type: "2");
                                                              }
                                                            }else{
                                                                 Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                                'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                                'addNote': addNoteController.text
                                                              });
                                                            }
                                                             
                                                              
                                            //
                                            
                                        /*     Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                              'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                              'addNote': addNoteController.text
                                            }); */
                                            }
                                          }
                                      } else {
                                        showDialog(
                                            context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                                      } */
                                      },
                                    );
                                  } else {
                                    return ButtonContainer(
                                      color: Theme.of(context).colorScheme.secondary,
                                      height: height,
                                      width: width,
                                      text: UiUtils.getTranslatedLabel(context, browseMenuLabel),
                                      start: width! / 40.0,
                                      end: width! / 40.0,
                                      bottom: height! / 55.0,
                                      top: 0,
                                      status: false,
                                      borderColor: Theme.of(context).colorScheme.secondary,
                                      textColor: white,
                                      onPressed: () {
                                        Future.delayed(Duration.zero, () => Navigator.of(context).popUntil((route) => route.isFirst));
                                      },
                                    );
                                  }
                                });
                          });
                }),
                body: RefreshIndicator(
                  onRefresh: refreshList,
                  color: Theme.of(context).colorScheme.primary,
                  child: Container(
                      margin: EdgeInsetsDirectional.only(top: height! / 99.0),
                      //decoration: DesignConfig.boxDecorationContainerHalf(white),
                      width: width,
                      height: height!,
                      child: cartData()),
                ),
              ));
  }
}

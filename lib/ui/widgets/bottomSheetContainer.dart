import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/cart/manageCartCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteProduct.dart';
import 'package:project1/cubit/product/productLoadCubit.dart';
import 'package:project1/data/model/productAddOnsModel.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/data/model/variantsModel.dart';
import 'package:project1/cubit/product/offlineCartCubit.dart';
import 'package:project1/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/utils/SqliteData.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import '../../utils/apiBodyParameterLabels.dart';

// ignore: must_be_immutable
class BottomSheetContainer extends StatefulWidget {
  final ProductDetails productDetailsModel;
  Map<String, int> qtyData = {};
  int? currentIndex = 0, qty = 0;
  final List<bool> isChecked;
  String? productVariantId, from;
  List<String> addOnIds = [];
  List<String> addOnQty = [];
  List<double> addOnPrice = [];
  List<String> productAddOnIds = [];
  bool? descTextShowFlag = false;
  final double? width, height;
  BottomSheetContainer(
      {Key? key,
      required this.productDetailsModel,
      this.width,
      this.height,
      required this.addOnIds,
      required this.addOnQty,
      required this.addOnPrice,
      required this.productAddOnIds,
      required this.isChecked,
      this.productVariantId,
      this.descTextShowFlag,
      required this.qtyData,
      this.currentIndex,
      this.qty,
      this.from})
      : super(key: key);

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  var db = DatabaseHelper();
  //List<String> addOnId = [];
  bool status = false;
  int QtyData = 0, qty = 0;
  int cartQty = 0;
  @override
  void initState() {
    print("productAddOnId2:${widget.productAddOnIds}-----$productAddOnId");
    super.initState();
    QtyData = widget.qtyData[widget.productVariantId!] ?? 0;
    qty = widget.qty ?? 0;
    cartQty = widget.qtyData[widget.productVariantId!] ?? 0;
    //addOnId = widget.productAddOnIds;
  }

  Future<void> getOffLineCart(String variantId) async {
    if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
      productVariant = (await db.getCart());
      if (productVariant!.isEmpty) {
      } else {
        productVariantId = productVariant!['VID'];
        productAddOnId = productVariant!['ADDONID'];
        /* if (productVariantId!.isNotEmpty) {
          if (mounted) {
            await context.read<OfflineCartCubit>().getOfflineCart(
                latitude: context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
                longitude: context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
                cityId: context.read<CityDeliverableCubit>().getCityId(),
                productVariantIds: "${productVariantId!.join(',')},$variantId");
          }
        } else {} */
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      for (int q = 0; q < widget.productDetailsModel.variants!.length; q++) {
        if (widget.productVariantId == widget.productDetailsModel.variants![q].id!) {
          widget.currentIndex = q;
        }
      }
      double priceCurrent = double.parse(widget.productDetailsModel.variants![widget.currentIndex!].specialPrice!);
      if (priceCurrent == 0) {
        priceCurrent = double.parse(widget.productDetailsModel.variants![widget.currentIndex!].price!);
      }

      double offCurrent = 0;
      if (widget.productDetailsModel.variants![widget.currentIndex!].specialPrice! != "0") {
        offCurrent = (double.parse(widget.productDetailsModel.variants![widget.currentIndex!].price!) -
                double.parse(widget.productDetailsModel.variants![widget.currentIndex!].specialPrice!))
            .toDouble();
        offCurrent = offCurrent * 100 / double.parse(widget.productDetailsModel.variants![widget.currentIndex!].price!).toDouble();
      }
      widget.productVariantId = widget.productDetailsModel.variants![widget.currentIndex!].id;
      return BlocProvider<UpdateProductFavoriteStatusCubit>(
        create: (context) => UpdateProductFavoriteStatusCubit(),
        child: Builder(builder: (context) {
          print(offCurrent.toStringAsFixed(2));
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                  width: widget.width!,
                  height: (MediaQuery.of(context).size.height / 1.14),
                  padding: EdgeInsetsDirectional.only(top: widget.height! / 15.0),
                  child: Container(
                    decoration: DesignConfig.boxDecorationContainerRoundHalf(Theme.of(context).colorScheme.onSurface, 25, 0, 25, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      top: widget.height! / 40.0,
                                      start: widget.width! / 30.0,
                                      end: widget.width! / 30.0,
                                      bottom: widget.height! / 60.0),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                      child: /*Image.network(productDetailsModel.image!, width: width!/5.0, height: height!/10.2, fit: BoxFit.cover)*/
                                          ColorFiltered(
                                        colorFilter: widget.productDetailsModel.partnerDetails![0].isRestroOpen == "1"
                                            ? const ColorFilter.mode(
                                                Colors.transparent,
                                                BlendMode.multiply,
                                              )
                                            : const ColorFilter.mode(
                                                Colors.grey,
                                                BlendMode.saturation,
                                              ),
                                        child: DesignConfig.imageWidgets(widget.productDetailsModel.image!, widget.height! / 4.5, widget.width!, "2"),
                                      )),
                                ),
                                SizedBox(height: widget.height! / 99.0),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(start: widget.width! / 25.0, end: widget.width! / 25.0),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(children: [
                                          widget.productDetailsModel.indicator == "1"
                                              ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                              : widget.productDetailsModel.indicator == "2"
                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                  : const SizedBox(),
                                          widget.productDetailsModel.isSpicy == "1" ? DesignConfig().spicyWidget(widget.width) : const SizedBox.shrink(),
                                          widget.productDetailsModel.bestSeller == "1"
                                              ? DesignConfig().bestSellerWidget(widget.width, context)
                                              : const SizedBox.shrink(),
                                          const Spacer(),
                                          widget.productDetailsModel.noOfRatings == "0"
                                              ? const SizedBox()
                                              : GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.of(context).pushNamed(Routes.productRatingDetail,
                                                        arguments: {'productId': widget.productDetailsModel.id!});
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SvgPicture.asset(DesignConfig.setSvgPath("rating"),
                                                          fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                      const SizedBox(width: 5.0),
                                                      Text(double.parse(widget.productDetailsModel.rating!).toStringAsFixed(1),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.onSecondary,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.normal)),
                                                    ],
                                                  ),
                                              )
                                        ]),
                                        const SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [/* 
                                            widget.productDetailsModel.indicator == "1"
                                                ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                : widget.productDetailsModel.indicator == "2"
                                                    ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                    : const SizedBox(),
                                            SizedBox(width: widget.width! / 99.0), */
                                            Text(widget.productDetailsModel.name!,
                                                textAlign: Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.normal,
                                                )),
                                            /* widget.productDetailsModel.noOfRatings == "0"
                                                ? const SizedBox()
                                                : GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.of(context).pushNamed(Routes.productRatingDetail,
                                                          arguments: {'productId': widget.productDetailsModel.id!});
                                                    },
                                                    child: Container(
                                                        padding: const EdgeInsetsDirectional.only(top: 2, bottom: 2, start: 4.5, end: 4.5),
                                                        decoration:
                                                            DesignConfig.boxDecorationContainerBorder(yellowColor, yellowColor.withOpacity(0.10), 5),
                                                        margin: EdgeInsetsDirectional.only(start: widget.width! / 20.0),
                                                        child: Row(
                                                          children: [
                                                            RatingBar.builder(
                                                              itemSize: 10.9,
                                                              glowColor: Theme.of(context).colorScheme.onSurface,
                                                              initialRating: double.parse(widget.productDetailsModel.rating!),
                                                              minRating: 1,
                                                              direction: Axis.horizontal,
                                                              allowHalfRating: true,
                                                              itemCount: 5,
                                                              ignoreGestures: true,
                                                              itemPadding: const EdgeInsetsDirectional.only(end: 2.0),
                                                              itemBuilder: (context, _) => const Icon(
                                                                Icons.star,
                                                                color: yellowColor,
                                                              ),
                                                              onRatingUpdate: (ratings) {
                                                                print(ratings);
                                                              },
                                                            ),
                                                            Text(" | ${widget.productDetailsModel.rating!}",
                                                                textAlign: TextAlign.left,
                                                                style: const TextStyle(
                                                                    color: greayLightColor,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontStyle: FontStyle.normal)),
                                                          ],
                                                        )),
                                                  ), */
                                          ],
                                        ),
                                        SizedBox(height: widget.height! / 99.0),
                                        Text(
                                          widget.productDetailsModel.shortDescription!,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: greayLightColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                          ),
                                          maxLines: widget.descTextShowFlag! ? null : 2,
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: const EdgeInsetsDirectional.only(end: 10),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                widget.descTextShowFlag = !widget.descTextShowFlag!;
                                              });
                                            },
                                            child: widget.descTextShowFlag!
                                                ? Text(
                                                    UiUtils.getTranslatedLabel(context, readLessLabel),
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: FontStyle.normal,
                                                    ),
                                                  )
                                                : Text(UiUtils.getTranslatedLabel(context, readMoreLabel),
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: FontStyle.normal,
                                                    )),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(context.read<SystemConfigCubit>().getCurrency() + priceCurrent.toString(),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                                            const SizedBox(width: 2.5),
                                            offCurrent.toStringAsFixed(2) == "0.00"
                                                ? const SizedBox()
                                                : Text(
                                                    context.read<SystemConfigCubit>().getCurrency() +
                                                        widget.productDetailsModel.variants![widget.currentIndex!].price!,
                                                    style: const TextStyle(
                                                        decoration: TextDecoration.lineThrough,
                                                        letterSpacing: 0,
                                                        color: lightFont,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        overflow: TextOverflow.ellipsis),
                                                    maxLines: 1,
                                                  ),
                                            offCurrent.toStringAsFixed(2) == "0.00"
                                                ? const SizedBox()
                                                : Text(" | ${offCurrent.toStringAsFixed(2)}${StringsRes.percentSymbol} ${StringsRes.off}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 1.04))
                                          ],
                                        ),
                                        SizedBox(height: widget.height! / 99.0),
                                      ]),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: widget.width! / 20.0, top: widget.height! / 99.0, end: widget.width! / 20.0),
                                  child: Row(
                                    children: [
                                      BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                        return BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
                                            bloc: context.read<FavoriteProductsCubit>(),
                                            builder: (context, favoriteProductState) {
                                              if (favoriteProductState is FavoriteProductsFetchSuccess) {
                                                //check if restaurant is favorite or not
                                                bool isProductFavorite =
                                                    context.read<FavoriteProductsCubit>().isProductFavorite(widget.productDetailsModel.id!);
                                                return BlocConsumer<UpdateProductFavoriteStatusCubit, UpdateProductFavoriteStatusState>(
                                                  bloc: context.read<UpdateProductFavoriteStatusCubit>(),
                                                  listener: ((context, state) {
                                                    //
                                                    if (state is UpdateProductFavoriteStatusFailure) {
                                                      if (state.errorStatusCode.toString() == "102") {
                                                        reLogin(context);
                                                      }
                                                    }
                                                    if (state is UpdateProductFavoriteStatusSuccess) {
                                                      //
                                                      if (state.wasFavoriteProductProcess) {
                                                        context.read<FavoriteProductsCubit>().addFavoriteProduct(state.product);
                                                      } else {
                                                        //
                                                        context.read<FavoriteProductsCubit>().removeFavoriteProduct(state.product);
                                                      }
                                                    }
                                                  }),
                                                  builder: (context, state) {
                                                    if (state is UpdateProductFavoriteStatusInProgress) {
                                                      return Container(
                                                          margin: const EdgeInsetsDirectional.only(end: 10.0),
                                                          height: widget.height! / 27,
                                                          width: widget.width! / 14,
                                                          padding: const EdgeInsets.all(8.0),
                                                          decoration: DesignConfig.boxDecorationCircle(Theme.of(context).colorScheme.surface,
                                                              Theme.of(context).colorScheme.surface, 50.0),
                                                          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                                                    }
                                                    return InkWell(
                                                        onTap: () {
                                                          //
                                                          if (state is UpdateProductFavoriteStatusFailure) {
                                                            if (state.errorStatusCode.toString() == "102") {
                                                              reLogin(context);
                                                            }
                                                          }
                                                          if (state is UpdateProductFavoriteStatusInProgress) {
                                                            return;
                                                          }
                                                          if (isProductFavorite) {
                                                            context.read<UpdateProductFavoriteStatusCubit>().unFavoriteProduct(
                                                                userId: context.read<AuthCubit>().getId(),
                                                                type: productsKey,
                                                                product: widget.productDetailsModel);
                                                          } else {
                                                            //
                                                            context.read<UpdateProductFavoriteStatusCubit>().favoriteProduct(
                                                                userId: context.read<AuthCubit>().getId(),
                                                                type: productsKey,
                                                                product: widget.productDetailsModel);
                                                          }
                                                        },
                                                        child: Container(
                                                            height: widget.height! / 27,
                                                            width: widget.width! / 14,
                                                            alignment: Alignment.center,
                                                            decoration: DesignConfig.boxDecorationCircle(Theme.of(context).colorScheme.surface,
                                                                Theme.of(context).colorScheme.surface, 50.0),
                                                            child: isProductFavorite
                                                                ? SvgPicture.asset(DesignConfig.setSvgPath("wishlist-filled"),
                                                                    width: 20.0, height: 20)
                                                                : SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"), width: 20.0, height: 20)));
                                                  },
                                                );
                                              }
                                              //if some how failed to fetch favorite products or still fetching the products
                                              return InkWell(
                                                  onTap: () {
                                                    //
                                                    if (favoriteProductState is FavoriteProductsFetchFailure) {
                                                      if (favoriteProductState.errorStatusCode.toString() == "102") {
                                                        reLogin(context);
                                                      }
                                                    }
                                                    if (context.read<AuthCubit>().state is AuthInitial ||
                                                        context.read<AuthCubit>().state is Unauthenticated) {
                                                      Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'product'}).then((value) {
                                                        appDataRefresh(context);
                                                      });
                                                      return;
                                                    }
                                                  },
                                                  child: Container(
                                                      height: widget.height! / 20,
                                                      width: widget.width! / 10,
                                                      alignment: Alignment.center,
                                                      decoration: DesignConfig.boxDecorationCircle(
                                                          Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface, 10.0),
                                                      child: SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"), width: 20.0, height: 20)));
                                            });
                                      }),
                                      const Spacer(),
                                      Container(
                                        alignment: Alignment.center,
                                        width: 108.5,
                                        decoration: DesignConfig.boxDecorationContainerBorder(
                                            Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.10), 5.0),
                                        padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 8.0),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsetsDirectional.only(end: 8.0),
                                                child: InkWell(
                                                    onTap: qty > 1 /* widget.qty! > 1 */
                                                        ? () {
                                                            setState(() {
                                                              if (/* widget.qty! */ qty <=
                                                                  int.parse(widget.productDetailsModel.minimumOrderQuantity!)) {
                                                                //widget.qty = int.parse(widget.productDetailsModel.quantityStepSize!);
                                                                //widget.qty = int.parse(widget.productDetailsModel.minimumOrderQuantity!);
                                                                qty = int.parse(widget.productDetailsModel.minimumOrderQuantity!);
                                                              } else {
                                                                qty = qty - 1;
                                                                //widget.qty = widget.qty! - 1 /*  - int.parse(widget.productDetailsModel.quantityStepSize!) */;
                                                              }
                                                              print("data");
                                                              //widget.qtyData[widget.productVariantId!] = widget.qty!;
                                                              widget.qtyData[widget.productVariantId!] = qty;
                                                              QtyData = qty;
                                                            });
                                                          }
                                                        : null,
                                                    child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSecondary)),
                                              ),
                                              SizedBox(width: widget.width! / 50.0),
                                              Text(QtyData.toString(), //widget.qtyData[widget.productVariantId!].toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                              //Text(qty.toString(), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                                              SizedBox(width: widget.width! / 50.0),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.only(start: 8.0),
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (/* widget.qty! */ qty >= int.parse(widget.productDetailsModel.totalAllowedQuantity!)) {
                                                          //widget.qty = int.parse(widget.productDetailsModel.totalAllowedQuantity!);
                                                          qty = int.parse(widget.productDetailsModel.totalAllowedQuantity!);
                                                          Navigator.pop(context);
                                                          UiUtils.setSnackBar(
                                                              UiUtils.getTranslatedLabel(context, quantityLabel),
                                                              "${StringsRes.minimumQuantityAllowed} ${widget.productDetailsModel.totalAllowedQuantity!}",
                                                              context,
                                                              false,
                                                              type: "2");
                                                        } else {
                                                          //widget.qty = (widget.qty! + 1 /* + int.parse(widget.productDetailsModel.quantityStepSize!) */);
                                                          qty = (qty + 1);
                                                        }
                                                        //widget.qtyData[widget.productVariantId!] = widget.qty!;
                                                        widget.qtyData[widget.productVariantId!] = qty;
                                                        QtyData = qty;
                                                        //productDetailsModel.variants![0].cartCount = (int.parse(productDetailsModel.variants![0].cartCount!) + 1).toString();
                                                      });
                                                    },
                                                    child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary)),
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                widget.productDetailsModel.attributes!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          bottom: widget.height! / 80.0,
                                          top: widget.height! / 40.0,
                                          start: widget.width! / 25.0,
                                          end: widget.width! / 25.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                widget.productDetailsModel.attributes!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(start: widget.width! / 25.0, end: widget.width! / 25.0),
                                        child: Row(
                                          children: [
                                            Text(UiUtils.getTranslatedLabel(context, variationLabel),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal)),
                                            //Text(StringsRes.chose, textAlign: TextAlign.left, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                widget.productDetailsModel.attributes!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          bottom: widget.height! / 99.0,
                                          top: widget.height! / 80.0,
                                          start: widget.width! / 25.0,
                                          end: widget.width! / 25.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                widget.productDetailsModel.attributes!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(start: widget.width! / 25.0, end: widget.width! / 25.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(widget.productDetailsModel.variants!.length, (index) {
                                              VariantsModel data = widget.productDetailsModel.variants![index];
                                              double price = double.parse(data.specialPrice!);
                                              if (price == 0) {
                                                price = double.parse(data.price!);
                                              }

                                              double off = 0;
                                              if (data.specialPrice! != "0") {
                                                off = (double.parse(data.price!) - double.parse(data.specialPrice!)).toDouble();
                                                off = off * 100 / double.parse(data.price!).toDouble();
                                              }
                                              return RadioListTile(
                                                contentPadding: EdgeInsets.zero,
                                                dense: true,
                                                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                activeColor: Theme.of(context).colorScheme.primary,
                                                controlAffinity: ListTileControlAffinity.trailing,
                                                value: index,
                                                groupValue: widget.currentIndex,
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(data.variantValues!,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Theme.of(context).colorScheme.onSecondary,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            fontStyle: FontStyle.normal)),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        Text(context.read<SystemConfigCubit>().getCurrency() + price.toString(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: Theme.of(context).colorScheme.primary,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                fontStyle: FontStyle.normal)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                onChanged: (int? value) {
                                                  widget.currentIndex = value!;
                                                  widget.productVariantId = widget.productDetailsModel.variants![value].id!;

                                                  if (widget.qtyData.containsKey(widget.productVariantId)) {
                                                    widget.qty = widget.qtyData[widget.productVariantId] ?? 1;
                                                  } else {
                                                    int newQty = 0;
                                                    if (widget.productDetailsModel.variants![value].cartCount != "0") {
                                                      newQty = int.parse(widget.productDetailsModel.variants![value].cartCount!);
                                                    } else {
                                                      newQty = int.parse(widget.productDetailsModel.minimumOrderQuantity!);
                                                    }
                                                    widget.qtyData[widget.productVariantId!] = newQty;
                                                    widget.qty = newQty;
                                                  }
                                                  setState(() {});
                                                },
                                              );
                                            })),
                                      ),
                                widget.productDetailsModel.productAddOns!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            bottom: widget.height! / 80.0,
                                            top: widget.height! / 80.0,
                                            start: widget.width! / 25.0,
                                            end: widget.width! / 25.0),
                                        child: DesignConfig.divider(),
                                      ),
                                widget.productDetailsModel.productAddOns!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(start: widget.width! / 25.0, end: widget.width! / 25.0),
                                        child: Text(UiUtils.getTranslatedLabel(context, extraAddOnLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ),
                                widget.productDetailsModel.productAddOns!.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            bottom: widget.height! / 80.0,
                                            top: widget.height! / 80.0,
                                            start: widget.width! / 25.0,
                                            end: widget.width! / 25.0),
                                        child: DesignConfig.divider(),
                                      ),
                                widget.productDetailsModel.productAddOns!.isEmpty
                                    ? Container()
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(widget.productDetailsModel.productAddOns!.length, (index) {
                                          ProductAddOnsModel data = widget.productDetailsModel.productAddOns![index];
                                          if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                            print("${widget.productAddOnIds}-${data.id!}-${widget.productAddOnIds.contains(data.id)}");
                                            if (widget.productAddOnIds.contains(data.id)) {
                                              widget.isChecked[index] = true;
                                              if (!widget.addOnIds.contains(data.id!)) {
                                                widget.addOnIds.add(data.id!);
                                                widget.addOnQty.add(widget.qtyData[widget.productVariantId!].toString());
                                                //widget.addOnQty.add("1");
                                                widget.addOnPrice.add(double.parse(data.price!));
                                              }
                                            } else {
                                              widget.isChecked[index] = false;
                                            }
                                          } else {
                                            if (widget.productAddOnIds.contains(data.id)) {
                                              widget.isChecked[index] = true;
                                              if (!widget.addOnIds.contains(data.id!)) {
                                                widget.addOnIds.add(data.id!);
                                                widget.addOnQty.add(widget.qtyData[widget.productVariantId!].toString());
                                                //widget.addOnQty.add("1");
                                                widget.addOnPrice.add(double.parse(data.price!));
                                              }
                                            } else {
                                              widget.isChecked[index] = false;
                                            }
                                          }
                                          return Container(
                                              margin: EdgeInsetsDirectional.only(
                                                start: widget.width! / 25.0,
                                                end: widget.width! / 25.0,
                                                //bottom: height! / 99.0,
                                                //top: height! / 99.0,
                                              ), //padding: EdgeInsetsDirectional.only(start: width!/25.0, end: width!/25.0),
                                              //decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 10.0),
                                              child: CheckboxListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  dense: true,
                                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                  activeColor: Theme.of(context).colorScheme.primary,
                                                  title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                          width: widget.width! / 2.0,
                                                          child: Text(
                                                            data.title!,
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                                color: Theme.of(context).colorScheme.onSecondary,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                fontStyle: FontStyle.normal),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          )),
                                                      const Spacer(),
                                                      Text(context.read<SystemConfigCubit>().getCurrency() + data.price!,
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.primary,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w400,
                                                              fontStyle: FontStyle.normal)),
                                                    ],
                                                  ),
                                                  value: widget.isChecked[index],
                                                  onChanged: (val) {
                                                    setState(
                                                      () {
                                                        widget.isChecked[index] = val!;
                                                        if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                          if (widget.isChecked[index] == false) {
                                                            //widget.addOnIds.removeAt(index);
                                                            widget.addOnIds.remove(data.id);
                                                            widget.productAddOnIds.remove(data.id);
                                                            //widget.addOnQty.removeAt(index);
                                                            widget.addOnQty.remove(data.id);
                                                            //widget.addOnPrice.removeAt(index);
                                                            widget.addOnPrice.remove(data.id);
                                                          } else {
                                                            widget.productAddOnIds.add(data.id!);
                                                            if (!widget.addOnIds.contains(data.id!)) {
                                                              widget.addOnIds.add(data.id!);
                                                              widget.addOnQty.add(widget.qtyData[widget.productVariantId!].toString());
                                                              //widget.addOnQty.add("1");
                                                              widget.addOnPrice.add(double.parse(data.price!));
                                                            }
                                                          }
                                                        } else {
                                                          if (widget.isChecked[index] == false) {
                                                            //widget.addOnIds.removeAt(index);
                                                            widget.addOnIds.remove(data.id);
                                                            widget.productAddOnIds.remove(data.id);
                                                            //widget.addOnQty.removeAt(index);
                                                            widget.addOnQty.remove(data.id);
                                                            //widget.addOnPrice.removeAt(index);
                                                            widget.addOnPrice.remove(data.id);
                                                          } else {
                                                            widget.productAddOnIds.add(data.id!);
                                                            if (!widget.addOnIds.contains(data.id!)) {
                                                              widget.addOnIds.add(data.id!);
                                                              widget.addOnQty.add(widget.qtyData[widget.productVariantId!].toString());
                                                              //widget.addOnQty.add("1");
                                                              widget.addOnPrice.add(double.parse(data.price!));
                                                            }
                                                          }
                                                        }
                                                      },
                                                    );
                                                  }));
                                        }),
                                      )
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                          var sum = 0.0;
                          for (var i = 0; i < widget.productDetailsModel.productAddOns!.length; i++) {
                            if (widget.productAddOnIds.contains(widget.productDetailsModel.productAddOns![i].id)) {
                              sum += double.parse(widget.productDetailsModel.productAddOns![i].price!) * widget.qtyData[widget.productVariantId!]!;
                            }
                          }
                          double overAllTotal = ((priceCurrent * widget.qtyData[widget.productVariantId!]!) + sum);
                          //double overAllTotal = 100;
                          return Container(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsetsDirectional.only(start: widget.width! / 25.0, end: widget.width! / 25.0),
                            child: SizedBox(
                                width: widget.width!,
                                child: widget.productDetailsModel.variants![widget.currentIndex!].availability == "1" ||
                                        widget.productDetailsModel.variants![widget.currentIndex!].availability == ""
                                    ? BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                        return BlocConsumer<ManageCartCubit, ManageCartState>(
                                            bloc: context.read<ManageCartCubit>(),
                                            listener: (context, state) {
                                              print(state.toString());
                                              if (state is ManageCartFailure) {
                                                if (state.errorStatusCode.toString() == "102") {
                                                  reLogin(context);
                                                }
                                              }
                                              if (state is ManageCartSuccess) {
                                                status = false;
                                                if (context.read<AuthCubit>().state is AuthInitial ||
                                                    context.read<AuthCubit>().state is Unauthenticated) {
                                                  return;
                                                } else {
                                                  final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                                  /* for(int i=0; i< currentCartModel.data!.length; i++){
                                                    print(currentCartModel.data![i].qty);
                                                  } */
                                                  context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(
                                                      state.data,
                                                      (int.parse(currentCartModel.totalQuantity ?? '0') + int.parse(state.totalQuantity!)).toString(),
                                                      state.subTotal,
                                                      state.taxPercentage,
                                                      state.taxAmount,
                                                      state.overallAmount,
                                                      List.from(state.variantId ?? [])..addAll(currentCartModel.variantId ?? [])));

                                                  context.read<ProductLoadCubit>().updateQuntity(
                                                      widget.productDetailsModel,
                                                      (int.parse(widget.productDetailsModel.variants![widget.currentIndex!].cartCount!) +
                                                              int.parse(widget.qtyData[widget.productVariantId!].toString()))
                                                          .toString(), //widget.qtyData[widget.productVariantId!].toString(),
                                                      widget.productDetailsModel.variants![widget.currentIndex!].id);

                                                  print(currentCartModel.variantId);
                                                  Navigator.pop(context);
                                                  context.read<ValidatePromoCodeCubit>().getValidatePromoCode(
                                                      promoCode, context.read<AuthCubit>().getId(), state.overallAmount!.toStringAsFixed(2),walletBalanceUsed.toString(), context.read<GetCartCubit>().cartPartnerId());

                                                  if (widget.productDetailsModel.variants![widget.currentIndex!].cartCount! ==
                                                      widget.qtyData[widget.productVariantId!].toString()) {
                                                  } else {
                                                    //UiUtils.setSnackBar(StringsRes.addToCart, StringsRes.updateSuccessFully, context, false, type: "1");
                                                  }
                                                }
                                                // Navigator.pop(context);
                                              } else if (state is ManageCartFailure) {
                                                status = false;
                                                if (context.read<AuthCubit>().state is AuthInitial ||
                                                    context.read<AuthCubit>().state is Unauthenticated) {
                                                  return;
                                                } else {
                                                  Navigator.pop(context);
                                                  //showMessage = state.errorMessage.toString();
                                                  UiUtils.setSnackBar(
                                                      UiUtils.getTranslatedLabel(context, addToCartLabel), state.errorMessage, context, false,
                                                      type: "2");
                                                }
                                              }
                                            },
                                            builder: (context, state) {
                                              return BlocConsumer<OfflineCartCubit, OfflineCartState>(
                                                  bloc: context.read<OfflineCartCubit>(),
                                                  listener: (context, state) {
                                                    if (state is OfflineCartProgress) {
                                                      print("state22:${state.toString()}");
                                                    } else if (state is OfflineCartSuccess) {
                                                      if (context.read<AuthCubit>().state is AuthInitial ||
                                                          context.read<AuthCubit>().state is Unauthenticated) {
                                                        /* final currentOfflineCartModel = context.read<OfflineCartCubit>().getOfflineCartModel();
                                                        context
                                                            .read<OfflineCartCubit>()
                                                            .updateOfflineCartList(
                                                              state.productModel,
                                                            ); */
                                                      }
                                                      // Navigator.pop(context);
                                                    }
                                                  },
                                                  builder: (context, state) {
                                                    return ButtonContainer(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      height: widget.height,
                                                      width: widget.width,
                                                      text:
                                                          "${UiUtils.getTranslatedLabel(context, addToCartLabel)} (${context.read<SystemConfigCubit>().getCurrency() + overAllTotal.toStringAsFixed(2)})",
                                                      top: widget.height! / 55.0,
                                                      bottom: widget.height! / 55.0,
                                                      start: widget.width! / 99.0,
                                                      end: widget.width! / 99.0,
                                                      status: status,
                                                      borderColor: Theme.of(context).colorScheme.secondary,
                                                      textColor: white,
                                                      onPressed: () {
                                                        if (widget.qty == 0) {
                                                          Navigator.pop(context);
                                                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, quantityLabel),
                                                              StringsRes.quantityMessage, context, false,
                                                              type: "2");
                                                        } else {
                                                          /*context.read<ManageCartCubit>().manageCartUser(
                                                                userId: context.read<AuthCubit>().getId(),
                                                                productVariantId: widget.productVariantId,
                                                                isSavedForLater: "0",
                                                                qty: widget.from == "cart"
                                                                    ? widget.qtyData[widget.productVariantId!].toString()
                                                                    : (int.parse(widget
                                                                                .productDetailsModel.variants![widget.currentIndex!].cartCount!) +
                                                                            int.parse(widget.qtyData[widget.productVariantId!].toString()))
                                                                        .toString(), //widget.qtyData[widget.productVariantId!].toString(),
                                                                addOnId: widget.addOnIds.isNotEmpty ? widget.addOnIds.join(",").toString() : "",
                                                                addOnQty: widget.addOnQty.isNotEmpty ? widget.addOnQty.join(",").toString() : "");*/
                                                          if (context.read<AuthCubit>().state is AuthInitial ||
                                                              context.read<AuthCubit>().state is Unauthenticated) {
                                                            if (context.read<SettingsCubit>().state.settingsModel!.restaurantId.toString() ==
                                                                    widget.productDetailsModel.partnerDetails![0].partnerId! ||
                                                                context.read<SettingsCubit>().state.settingsModel!.cartCount.toString() == "0" ||
                                                                context.read<SettingsCubit>().state.settingsModel!.cartCount.toString() == "") {
                                                              db
                                                                  .insertCart(
                                                                      widget.productDetailsModel.id!,
                                                                      widget.productVariantId!,
                                                                      widget.qtyData[widget.productVariantId!].toString(),
                                                                      //widget.qtyData[widget.productVariantId!].toString(),
                                                                      widget.addOnIds.isNotEmpty ? widget.addOnIds.join(",").toString() : "",
                                                                      widget.addOnQty.isNotEmpty ? widget.addOnQty.join(",").toString() : "",
                                                                      overAllTotal.toString(),
                                                                      widget.productDetailsModel.partnerDetails![0].partnerId!,
                                                                      context)
                                                                  .whenComplete(() async {
                                                                await getOffLineCart(widget.productVariantId!).then((value) {
                                                                  context.read<OfflineCartCubit>().updateQuntity(widget.productDetailsModel,
                                                                      widget.qtyData[widget.productVariantId!].toString(), widget.productVariantId);
                                                                });
                                                              });
                                                              if (widget.qty.toString() == widget.qtyData[widget.productVariantId!].toString()) {
                                                              } else {
                                                                //UiUtils.setSnackBar(StringsRes.addToCart, StringsRes.updateSuccessFully, context, false,type: "1");
                                                              }
                                                              Navigator.pop(context);
                                                            } else {
                                                              print(context.read<SettingsCubit>().state.settingsModel!.cartCount.toString());
                                                              Navigator.pop(context);
                                                              UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addToCartLabel),
                                                                  StringsRes.singleRestaurantAddMessage, context, false,
                                                                  type: "2");
                                                            }
                                                          } else {
                                                            int qty = 0;
                                                            //if (widget.from == "cart") {
                                                            qty = int.parse(widget.qtyData[widget.productVariantId!].toString());
                                                            /* } else {
                                                              qty =
                                                                  (int.parse(widget.productDetailsModel.variants![widget.currentIndex!].cartCount!) +
                                                                      int.parse(widget.qtyData[widget.productVariantId!].toString()));
                                                            } */
                                                            print(
                                                                "${widget.productDetailsModel.minimumOrderQuantity!}-${widget.productDetailsModel.totalAllowedQuantity!}");
                                                            if (qty < int.parse(widget.productDetailsModel.minimumOrderQuantity!)) {
                                                              Navigator.pop(context);
                                                              UiUtils.setSnackBar(
                                                                  UiUtils.getTranslatedLabel(context, quantityLabel),
                                                                  "${StringsRes.minimumQuantityAllowed} ${widget.productDetailsModel.minimumOrderQuantity!}",
                                                                  context,
                                                                  false,
                                                                  type: "2");
                                                            } else if (qty > int.parse(widget.productDetailsModel.totalAllowedQuantity!)) {
                                                              Navigator.pop(context);
                                                              UiUtils.setSnackBar(
                                                                  UiUtils.getTranslatedLabel(context, quantityLabel),
                                                                  "${StringsRes.maximumQuantityAllowed} ${widget.productDetailsModel.totalAllowedQuantity!}",
                                                                  context,
                                                                  false,
                                                                  type: "2");
                                                            } else {
                                                              setState(() {
                                                                status = true;
                                                              });
                                                              widget.addOnQty.clear();
                                                              for (int qty = 0; qty < widget.addOnIds.length; qty++) {
                                                                widget.addOnQty.add(widget.qtyData[widget.productVariantId!].toString());
                                                              }
                                                              context.read<ManageCartCubit>().manageCartUser(
                                                                  userId: context.read<AuthCubit>().getId(),
                                                                  productVariantId: widget.productVariantId,
                                                                  isSavedForLater: "0",
                                                                  qty: /* widget.from == "cart"
                                                                      ?  */
                                                                      widget.qtyData[widget.productVariantId!].toString()
                                                                  /* : (int.parse(widget
                                                                                  .productDetailsModel.variants![widget.currentIndex!].cartCount!) +
                                                                              int.parse(widget.qtyData[widget.productVariantId!].toString()))
                                                                          .toString() */
                                                                  , //widget.qtyData[widget.productVariantId!].toString(), //widget.qtyData[widget.productVariantId!].toString(),
                                                                  addOnId: widget.addOnIds.isNotEmpty ? widget.addOnIds.join(",").toString() : "",
                                                                  addOnQty: widget.addOnQty.isNotEmpty ? widget.addOnQty.join(",").toString() : "");
                                                            }
                                                          }
                                                          db.getCart();
                                                        }
                                                        setState(() {});
                                                      },
                                                    );
                                                  });
                                            });
                                      })
                                    : ButtonContainer(
                                        color: Theme.of(context).colorScheme.surface,
                                        height: widget.height,
                                        width: widget.width,
                                        text: UiUtils.getTranslatedLabel(context, outOfStockLabel),
                                        top: widget.height! / 55.0,
                                        bottom: widget.height! / 55.0,
                                        start: widget.width! / 99.0,
                                        end: widget.width! / 99.0,
                                        status: false,
                                        borderColor: commentBoxBorderColor,
                                        textColor: commentBoxBorderColor,
                                        onPressed: () {})),
                            // showMessage==""?Container():Text(showMessage, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: ColorsRes.darkFontColor, fontSize: 16, fontWeight: FontWeight.w500))
                          );
                        }),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
            ],
          );
        }),
      );
    });
  }
}

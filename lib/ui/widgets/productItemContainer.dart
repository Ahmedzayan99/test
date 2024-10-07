import 'dart:ui';

import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteProduct.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/widgets/productUnavailableDialog.dart';
import 'package:project1/utils/SqliteData.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/restaurantCloseDialog.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../utils/apiBodyParameterLabels.dart';

class ProductItemContainer extends StatefulWidget {
  final ProductDetails dataItem;
  final List<ProductDetails> dataMainList;
  final int? i;
  final double? width, height, price, off;
  const ProductItemContainer({Key? key, required this.dataItem, this.i, this.width, this.height, this.price, this.off, required this.dataMainList})
      : super(key: key);

  @override
  State<ProductItemContainer> createState() => _ProductItemContainerState();
}

class _ProductItemContainerState extends State<ProductItemContainer> {
  var db = DatabaseHelper();
  bottomModelSheetShow(ProductDetails productList) async {
    /* ProductDetails productDetailsModel = productList[index];
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
    bool descTextShowFlag = false; */
    ProductDetails productDetailsModel = productList;
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
            height: widget.height!,
            width: widget.width!,
            productVariantId: productVariantId,
            addOnIds: addOnIds,
            addOnPrice: addOnPrice,
            addOnQty: addOnQty,
            productAddOnIds: productAddOnIds,
            qtyData: qtyData,
            currentIndex: currentIndex,
            descTextShowFlag: descTextShowFlag,
            qty: qty,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateProductFavoriteStatusCubit>(
      create: (context) => UpdateProductFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return InkWell(
          onTap: () {
            if (widget.dataItem.partnerDetails![0].isRestroOpen == "1") {
            bool check = getStoreOpenStatus(widget.dataItem.startTime!, widget.dataItem.endTime!);
            print("check:$check:${widget.dataItem.availableTime}");
            if (widget.dataItem.availableTime == "1") {
              if (check == true) {
                bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                      widget.dataItem.id!, widget.dataItem)[0] /* widget.dataMainList, widget.i! */);
              } else {
                showDialog(
                    context: context,
                    builder: (_) => ProductUnavailableDialog(startTime: widget.dataItem.startTime, endTime: widget.dataItem.endTime));
              }
            } else {
              bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                    widget.dataItem.id!, widget.dataItem)[0] /* widget.dataMainList, widget.i! */);
            }
            }else {
              showDialog(
                context: context,
                builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
            }
          },
          child: Container(
              width: widget.width!,
              margin: EdgeInsetsDirectional.only(
                start: widget.width! / 60.0,
                end: widget.width! / 60.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                  child: ColorFiltered(
                                    colorFilter: widget.dataItem.partnerDetails![0].isRestroOpen == "1"
                                        ? const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.multiply,
                                          )
                                        : const ColorFilter.mode(
                                            Colors.grey,
                                            BlendMode.saturation,
                                          ),
                                    child: DesignConfig.imageWidgets(widget.dataItem.image!, widget.height! / 8.0, widget.width!, "2"),
                                  )),
                              Positioned.directional(
                                textDirection: Directionality.of(context),
                                end: 5.0,
                                top: 5.0,
                                //right: 0,
                                child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                  return BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
                                      bloc: context.read<FavoriteProductsCubit>(),
                                      builder: (context, favoriteProductState) {
                                        if (favoriteProductState is FavoriteProductsFetchSuccess) {
                                          //check if restaurant is favorite or not
                                          bool isProductFavorite = context.read<FavoriteProductsCubit>().isProductFavorite(widget.dataItem.id!);
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
                                                return SizedBox(
                                                  width: 30.0,
                                                  height: 30,
                                                  child: ClipOval(
                                                    //borderRadius: BorderRadius.circular(10.0),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                                      child: Container(
                                                          alignment: Alignment.center,
                                                          padding: const EdgeInsets.all(3.5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60),
                                                          ),
                                                          child: CircularProgressIndicator(
                                                            color: Theme.of(context).colorScheme.primary,
                                                            value: 5.0,
                                                          )),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return InkWell(
                                                  onTap: () {
                                                    //
                                                    if (state is UpdateProductFavoriteStatusFailure) {
                                                      if (state.errorMessage.toString() == "102") {
                                                        reLogin(context);
                                                      }
                                                    }
                                                    if (state is UpdateProductFavoriteStatusInProgress) {
                                                      return;
                                                    }
                                                    if (isProductFavorite) {
                                                      context.read<UpdateProductFavoriteStatusCubit>().unFavoriteProduct(
                                                          userId: context.read<AuthCubit>().getId(), type: productsKey, product: widget.dataItem);
                                                    } else {
                                                      //
                                                      context.read<UpdateProductFavoriteStatusCubit>().favoriteProduct(
                                                          userId: context.read<AuthCubit>().getId(), type: productsKey, product: widget.dataItem);
                                                    }
                                                  },
                                                  child: ClipOval(
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                                      child: Container(
                                                          alignment: Alignment.center,
                                                          padding: const EdgeInsets.all(3.5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60),
                                                          ),
                                                          child: isProductFavorite
                                                              ? SvgPicture.asset(DesignConfig.setSvgPath("wishlist-filled"),
                                                                  fit: BoxFit.scaleDown, width: 18.0, height: 18.3)
                                                              : SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                                  fit: BoxFit.scaleDown, width: 18.0, height: 18.3)),
                                                    ),
                                                  ));
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
                                            child: ClipOval(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets.all(3.5),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60),
                                                    ),
                                                    child: SvgPicture.asset(DesignConfig.setSvgPath("wishlist1"),
                                                        fit: BoxFit.scaleDown, width: 18.0, height: 18.3)),
                                              ),
                                            ));
                                      });
                                }),
                              ),
                            ],
                          )),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: widget.width! / 50.0, top: widget.height! / 99.0, bottom: widget.height! / 99.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children:[
                              widget.dataItem.indicator == "1"
                                  ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                  : widget.dataItem.indicator == "2"
                                      ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                      : const SizedBox(),
                              widget.dataItem.isSpicy == "1" ? DesignConfig().spicyWidget(widget.width) : const SizedBox.shrink(),
                              widget.dataItem.bestSeller == "1" ? DesignConfig().bestSellerWidget(widget.width, context) : const SizedBox.shrink(),
                              const Spacer(),
                              widget.dataItem.noOfRatings == "0"
                                  ? const SizedBox()
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(DesignConfig.setSvgPath("rating"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                  const SizedBox(width: 5.0),
                                  Text(double.parse(widget.dataItem.rating!).toStringAsFixed(1),
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.normal)),
                                ],
                              )
                            ]),
                            const SizedBox(height: 5.0),
                            widget.off!.toStringAsFixed(2) == "0.00"
                                ? const SizedBox()
                                : Text("${widget.off!.toStringAsFixed(2)}${StringsRes.percentSymbol} ${StringsRes.off}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal)),
                            const SizedBox(height: 5.0),
                            Text(widget.dataItem.name!,
                                textAlign: Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1),
                            const SizedBox(height: 5.0),
                            Row(
                              children: [
                                Text(context.read<SystemConfigCubit>().getCurrency() + widget.price.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                                SizedBox(width: widget.width! / 99.0),
                                widget.off!.toStringAsFixed(2) == "0.00"
                                    ? const SizedBox()
                                    : Text(
                                        "${context.read<SystemConfigCubit>().getCurrency()}${widget.dataItem.variants![0].price!}",
                                        style: const TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            letterSpacing: 0,
                                            color: lightFont,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: 1,
                                      ),
                              ],
                            ),
                            /* const SizedBox(height: 5.0),
                            widget.dataItem.noOfRatings == "0"
                                ? const SizedBox()
                                : FittedBox(
                                    child: Container(
                                      padding: const EdgeInsetsDirectional.only(top: 2, bottom: 2, start: 4.5, end: 4.5),
                                      decoration: DesignConfig.boxDecorationContainerBorder(yellowColor, yellowColor.withOpacity(0.10), 5),
                                      //margin: EdgeInsetsDirectional.only(start: width! / 20.0),
                                      child: Row(
                                        children: [
                                          RatingBar.builder(
                                            itemSize: 10.9,
                                            glowColor: Theme.of(context).colorScheme.onSurface,
                                            initialRating: double.parse(widget.dataItem.rating!),
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
                                          Text(" | ${widget.dataItem.noOfRatings!}",
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: greayLightColor, fontSize: 10, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal)),
                                        ],
                                      ),
                                    ),
                                  ), */
                            // widget.dataItem.noOfRatings == "0" ? const SizedBox() : const SizedBox(width: 5.0),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: widget.height! / 80.0),
                    child: widget.dataItem.partnerDetails![0].isRestroOpen == "1"
                        ? InkWell(
                            onTap: () {
                              if (widget.dataItem.partnerDetails![0].isRestroOpen == "1") {
                              bool check = getStoreOpenStatus(widget.dataItem.startTime!, widget.dataItem.endTime!);
                              if (widget.dataItem.availableTime == "1") {
                                if (check == true) {
                                  bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                        widget.dataItem.id!,
                                        widget.dataItem)[0] /* widget.dataMainList, widget.i! */);
                                  /* if (widget.dataItem.type == "variable_product") {
                                  bottomModelSheetShow(widget.dataMainList, widget.i!);
                                  }else if(widget.dataItem.variants![0].cartCount=="0"){
                                  context.read<ProductLoadCubit>().updateQuntity(widget.dataItem,
                                    ((int.parse(widget.dataItem.variants![0].cartCount.toString()) + 1)).toString(), widget.dataItem.variants![0].id);
                                      } */
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (_) =>
                                          ProductUnavailableDialog(startTime: widget.dataItem.startTime, endTime: widget.dataItem.endTime));
                                }
                              } else {
                                bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(widget.dataItem.id!,
                                      widget.dataItem)[0] /* widget.dataMainList, widget.i! */);
                                /* if (widget.dataItem.type == "variable_product") {
                                bottomModelSheetShow(widget.dataMainList, widget.i!);
                                }else if(widget.dataItem.variants![0].cartCount=="0"){
                                context.read<ProductLoadCubit>().updateQuntity(widget.dataItem,
                                    ((int.parse(widget.dataItem.variants![0].cartCount.toString()) + 1)).toString(), widget.dataItem.variants![0].id);
                                    } */
                              }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                              }
                            },
                            child: /* widget.dataItem.variants![0].cartCount == "0"
                                ?  */Container(
                                    alignment: Alignment.center,
                                    width: widget.width! / 2.9,
                                    height: widget.height! / 22,
                                    decoration: DesignConfig.boxDecorationContainerBorder(
                                        Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.onSurface, 5.0),
                                    child: Text(UiUtils.getTranslatedLabel(context, addLabel),
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                        textAlign: TextAlign.left))
                                /* : BlocConsumer<ManageCartCubit, ManageCartState>(
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
                                          context
                                              .read<ValidatePromoCodeCubit>()
                                              .getValidatePromoCode(promoCode, context.read<AuthCubit>().getId(), state.subTotal);
                                        }
                                      } else if (state is ManageCartFailure) {
                                        if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
                                          return;
                                        } else {
                                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addToCartLabel), state.errorMessage, context, false,
                                              type: "2");
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return Container(
                                        alignment: Alignment.center, width: widget.width! / 3.1,
                                        height: widget.height! / 22,
                                        decoration: DesignConfig.boxDecorationContainerBorder(
                                            Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.onSurface, 5.0),
                                        //padding: const EdgeInsetsDirectional.only(top: 6.5, bottom: 6.5),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              BlocConsumer<RemoveFromCartCubit, RemoveFromCartState>(
                                                  bloc: context.read<RemoveFromCartCubit>(),
                                                  listener: (context, state) {
                                                    if (state is RemoveFromCartSuccess) {
                                                      /* UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, deleteLabel),
                                                          StringsRes.deleteSuccessFully, context, false,
                                                          type: "1"); */
                                                      //widget.dataItem.removeAt(i);
                                                      context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
                                                    } else if (state is RemoveFromCartFailure) {
                                                      /* UiUtils.setSnackBar(
                                                          UiUtils.getTranslatedLabel(context, cartLabel), state.errorMessage, context, false,
                                                          type: "2"); */
                                                      if (state.errorStatusCode.toString() == "102") {
                                                        reLogin(context);
                                                      }
                                                    }
                                                  },
                                                  builder: (context, state) {
                                                    return Padding(
                                                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          //setState(() {
                                                            if (int.parse(widget.dataItem.variants![0].cartCount!) <=
                                                                int.parse(widget.dataItem.minimumOrderQuantity!)) {
                                                              context.read<RemoveFromCartCubit>().removeFromCart(
                                                                  userId: context.read<AuthCubit>().getId(),
                                                                  productVariantId: widget.dataItem.variants![0].id);
                                                                  context.read<ProductLoadCubit>().updateQuntity(
                                                                  widget.dataItem,
                                                                  "0",
                                                                  widget.dataItem.variants![0].id);
                                                                  context.read<ProductLoadCubit>().updateQuntity(
                                                                widget.dataItem,
                                                                ("0").toString(),
                                                                widget.dataItem.variants![0].id);
                                                            } else if (int.parse(widget.dataItem.variants![0].cartCount!) == 1) {
                                                              context.read<RemoveFromCartCubit>().removeFromCart(
                                                                  userId: context.read<AuthCubit>().getId(),
                                                                  productVariantId: widget.dataItem.variants![0].id);
                                                                  context.read<ProductLoadCubit>().updateQuntity(
                                                                  widget.dataItem,
                                                                  "0",
                                                                  widget.dataItem.variants![0].id);
                                                                  context.read<ProductLoadCubit>().updateQuntity(
                                                                widget.dataItem,
                                                                ("0").toString(),
                                                                widget.dataItem.variants![0].id);
                                                            } else {
                                                              //widget.dataItem.variants![0].cartCount = (int.parse(widget.dataItem.variants![0].cartCount!) -1).toString();
                                                              context.read<ProductLoadCubit>().updateQuntity(
                                                                  widget.dataItem,
                                                                  ((int.parse(widget.dataItem.variants![0].cartCount.toString()) - 1)).toString(),
                                                                  widget.dataItem.variants![0].id);
                                                              context.read<ManageCartCubit>().manageCartUser(
                                                                  userId: context.read<AuthCubit>().getId(),
                                                                  productVariantId: widget.dataItem.variants![0].id,
                                                                  isSavedForLater: "0",
                                                                  qty: widget.dataItem.variants![0].cartCount,
                                                                  addOnId: "",
                                                                  addOnQty: "");
                                                              //}
                                                            }

                                                            /* //UiUtils.clearAll();
                                                            if (orderTypeIndex.toString() == "0") {
                                                              //finalTotal = cartList.overallAmount! + deliveryCharge;
                                                            } else {
                                                              //finalTotal = cartList.overallAmount! - deliveryCharge;
                                                            } */

                                                            context.read<ValidatePromoCodeCubit>().getValidatePromoCode(
                                                                promoCode, context.read<AuthCubit>().getId(), subTotal.toString());
                                                          //});
                                                        },
                                                        child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSecondary),
                                                      ),
                                                    );
                                                  }),
                                              SizedBox(width: widget.width! / 50.0),
                                              Text(widget.dataItem.variants![0].cartCount!,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 14.0)),
                                              SizedBox(width: widget.width! / 50.0),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.only(start: 8.0),
                                                child: InkWell(
                                                    onTap: () {
                                                      if (widget.dataItem.type == "variable_product") {
                                                        //itemEditQtyBottomSheet(cartList.data![i].productDetails!, j, variantData.id!, i, cartList.data!, l);
                                                      } else {
                                                        setState(() {
                                                          if (int.parse(widget.dataItem.variants![0].cartCount!) <
                                                              int.parse(widget.dataItem.minimumOrderQuantity!)) {
                                                            Navigator.pop(context);
                                                            UiUtils.setSnackBar(
                                                                UiUtils.getTranslatedLabel(context, quantityLabel),
                                                                "${StringsRes.minimumQuantityAllowed} ${widget.dataItem.minimumOrderQuantity!}",
                                                                context,
                                                                false,
                                                                type: "2");
                                                          } else if (int.parse(widget.dataItem.variants![0].cartCount!) >=
                                                              int.parse(widget.dataItem.totalAllowedQuantity!)) {
                                                            //widget.dataItem.variants![0].cartCount = widget.dataItem.totalAllowedQuantity!;
                                                            context.read<ProductLoadCubit>().updateQuntity(
                                                                widget.dataItem,
                                                                (widget.dataItem.totalAllowedQuantity!).toString(),
                                                                widget.dataItem.variants![0].id);
                                                            //Navigator.pop(context);
                                                            UiUtils.setSnackBar(
                                                                UiUtils.getTranslatedLabel(context, quantityLabel),
                                                                "${StringsRes.minimumQuantityAllowed} ${widget.dataItem.totalAllowedQuantity!}",
                                                                context,
                                                                false,
                                                                type: "2");
                                                          } else {
                                                            //widget.dataItem.variants![0].cartCount = (int.parse(widget.dataItem.variants![0].cartCount!) + 1).toString();
                                                            context.read<ProductLoadCubit>().updateQuntity(
                                                                widget.dataItem,
                                                                ((int.parse(widget.dataItem.variants![0].cartCount.toString()) + 1)).toString(),
                                                                widget.dataItem.variants![0].id);
                                                            context.read<ManageCartCubit>().manageCartUser(
                                                                userId: context.read<AuthCubit>().getId(),
                                                                productVariantId: widget.dataItem.variants![0].id,
                                                                isSavedForLater: "0",
                                                                qty: widget.dataItem.variants![0].cartCount,
                                                                addOnId: "",
                                                                addOnQty: "");
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary)),
                                              ),
                                            ]),
                                      );
                                    }) */)
                        : InkWell(
                            onTap: () {
                              if (widget.dataItem.partnerDetails![0].partnerWorkingTime != null) {
                                DateTime now = DateTime.now();
                                var format = DateFormat("HH:mm");
                                var one = format.parse("${now.hour.toString()}:${now.minute.toString()}");
                                var two = format.parse(widget.dataItem.partnerDetails![0].partnerWorkingTime![widget.i!].closingTime!);
                                var ans = two.difference(one);
                                var finalAns = format.parse(ans.toString());
                                DateTime check = finalAns;
                                for (int i = 0; i < widget.dataItem.partnerDetails![0].partnerWorkingTime!.length; i++) {
                                  if (DateFormat('EEEE').format(now).toString() == widget.dataItem.partnerDetails![0].partnerWorkingTime![i].day) {
                                    showDialog(
                                        context: context,
                                        builder: (_) =>
                                            RestaurantCloseDialog(hours: check.hour.toString(), minute: check.minute.toString(), status: true));
                                  }
                                }
                              } else {
                                showDialog(context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                              }
                            },
                            child: /* Container(
                                alignment: Alignment.center,
                                width: widget.width! / 3.1,
                                height: widget.height! / 22,
                                decoration:
                                    DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, Theme.of(context).colorScheme.onSurface, 5.0),
                                child: Text(UiUtils.getTranslatedLabel(context, addLabel),
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14.0),
                                    textAlign: TextAlign.left)) */const SizedBox.shrink()),
                  ),
                  SizedBox(height: widget.height! / 40.0)
                ],
              )),
        );
      }),
    );
  }
}

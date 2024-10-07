import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/order/reOrderCubit.dart';
import 'package:project1/data/model/addOnsDataModel.dart';
import 'package:project1/cubit/order/orderCubit.dart';
import 'package:project1/cubit/order/updateOrderStatusCubit.dart';
import 'package:project1/data/model/orderModel.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/data/repositories/order/orderRepository.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/styles/dashLine.dart';
import 'package:project1/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/smallButtomContainer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

import 'package:project1/utils/internetConnectivity.dart';
import 'package:intl/intl.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  MyOrderScreenState createState() => MyOrderScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => const MyOrderScreen());
  }
}

class MyOrderScreenState extends State<MyOrderScreen> {
  double? width, height;
  ScrollController orderController = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  bool enableList = false;
  int? _selectedIndex;
  String? reason = "";
  var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  

  var outputFormat = DateFormat('dd,MMMM yyyy hh:mm a');
  

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
    orderController.addListener(orderScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), "", "");
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  orderScrollListener() {
    if (orderController.position.maxScrollExtent == orderController.offset) {
      if (context.read<OrderCubit>().hasMoreData()) {
        context.read<OrderCubit>().fetchMoreOrderData(perPage, context.read<AuthCubit>().getId(), "", "");
      }
    }
  }

  onChanged(int position, StateSetter setState) {
    setState(() {
      _selectedIndex = position;
      enableList = !enableList;
    });
  }

  /*onTap(StateSetter setState) {
    setState(() {
      enableList = !enableList;
    });
  }*/

  Widget selectType(StateSetter setState) {
    return Container(
      decoration: DesignConfig.boxDecorationContainerCardShadow(Theme.of(context).colorScheme.onSurface, shadow, 10.0, 0.0, 0.0, 10.0, 0.0),
      margin: EdgeInsetsDirectional.only(top: height! / 99.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                enableList = !enableList;
              });
            },
            child: Container(
              decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
              padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    _selectedIndex != null ? reasonList[_selectedIndex!] : UiUtils.getTranslatedLabel(context, selectReasonLabel),
                    style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                  )),
                  Icon(enableList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: Theme.of(context).colorScheme.onSecondary),
                ],
              ),
            ),
          ),
          enableList
              ? Column(children :List.generate(reasonList.length,(position) {
                    return InkWell(
                      onTap: () {
                        onChanged(position, setState);
                        reason = reasonList[position];
                      },
                      child: Container(
                          padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reasonList[position],
                                style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0),
                                child: Divider(
                                  color: lightFont.withOpacity(0.10),
                                  height: 1.0,
                                ),
                              ),
                            ],
                          )),
                    );
                  }))
              : Container(),
        ],
      ),
    );
  }

  Future cancel(BuildContext context, String? status, String? orderId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: DesignConfig.setRoundedBorder(Theme.of(context).colorScheme.onSurface, 25.0, false),
            //title: Text('Not in stock'),
            content: SizedBox(
              height: enableList ? height! / 1.32 : height! / 1.62,
              child: Column(
                children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("order_cancel")),
                  Text(UiUtils.getTranslatedLabel(context, heyWaitLabel),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
                    child: Text(UiUtils.getTranslatedLabel(context, cancelDialogSubTitleLabel),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: height! / 40.0),
                  selectType(setState),
                  (reason == "" || reason!.isEmpty)
                      ? Padding(
                          padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
                          child: Text(UiUtils.getTranslatedLabel(context, pleaseSelectReasonLabel),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12, fontWeight: FontWeight.w500)),
                        )
                      : const SizedBox(),
                  BlocConsumer<UpdateOrderStatusCubit, UpdateOrderStatusState>(
                      bloc: context.read<UpdateOrderStatusCubit>(),
                      listener: (context, state) {
                        if (state is UpdateOrderStatusSuccess) {
                          //UiUtils.setSnackBar(StringsRes.order, StringsRes.cancelOrder, context, false);
                          context.read<OrderCubit>().updateOrderRateData(state.orderModel);
                          Navigator.of(context, rootNavigator: true).pop(true);
                        }
                      },
                      builder: (context, state) {
                        print(state.toString());
                        if (state is UpdateOrderStatusFailure) {
                          return Column(
                            children: [
                              Text(state.errorMessage,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12, fontWeight: FontWeight.w500)),
                              Row(
                                children: [
                                  Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.of(context, rootNavigator: true).pop(true);
                                          },
                                          child: Container(
                                              margin: EdgeInsetsDirectional.only(top: height! / 99.0, end: width! / 99.0),
                                              width: width!,
                                              padding: EdgeInsetsDirectional.only(
                                                top: height! / 65.0,
                                                bottom: height! / 65.0,
                                              ),
                                              decoration: DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.onSecondary, Theme.of(context).colorScheme.onSurface, 100.0),
                                              child: Text(UiUtils.getTranslatedLabel(context, cancelLabel),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style:
                                                      TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500))))),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.of(context, rootNavigator: true).pop(true);
                                      },
                                      child: Container(
                                          margin: EdgeInsetsDirectional.only(top: height! / 99.0, end: width! / 99.0),
                                          width: width!,
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 65.0,
                                            bottom: height! / 65.0,
                                          ),
                                          decoration: DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.onSurface, 100.0),
                                          child: Text(UiUtils.getTranslatedLabel(context, noLabel),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500))))),
                              Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: () {
                                        if (reason == "" || reason!.isEmpty) {
                                        } else {
                                          context.read<UpdateOrderStatusCubit>().getUpdateOrderStatus(status: status, orderId: orderId, reason: reason);
                                        }
                                      },
                                      child: Container(
                                          margin: EdgeInsetsDirectional.only(top: height! / 99.0),
                                          width: width!,
                                          padding: EdgeInsetsDirectional.only(top: height! / 65.0, bottom: height! / 65.0),
                                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.error, 100.0),
                                          child: Text(UiUtils.getTranslatedLabel(context, cancelOrderLabel),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500)))))
                            ],
                          );
                        }
                      })
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future paymentFailed(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: DesignConfig.setRounded(25.0),
            //title: Text('Not in stock'),
            content: SizedBox(
              height: height! / 2.0,
              child: Column(
                children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("payment_failed")),
                  Text(UiUtils.getTranslatedLabel(context, paymentFailedLabel),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5.0),
                  Text(UiUtils.getTranslatedLabel(context, paymentFailedSubTitleLabel),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                  SizedBox(height: height! / 40.0),
                  InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      },
                      child: Container(
                          margin: EdgeInsetsDirectional.only(top: height! / 99.0, end: width! / 99.0),
                          width: width!,
                          padding: EdgeInsetsDirectional.only(
                            top: height! / 65.0,
                            bottom: height! / 65.0,
                          ),
                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 100.0),
                          child: Text(UiUtils.getTranslatedLabel(context, tryAgainLabel),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500))))
                ],
              ),
            ));
      },
    );
  }

  bool isStatusAfter(String currentStatus, String compareStatus) {
    // Define the order of the statuses
    List<String> statusOrder = [
      pendingKey, 
      confirmedKey,
      preparingKey,
      readyForPickupKey,
      outForDeliveryKey
    ];

    int currentIndex = statusOrder.indexOf(currentStatus);
    int compareIndex = statusOrder.indexOf(compareStatus);

    // Return true if currentStatus comes after compareStatus in the list
    return compareIndex > currentIndex;
  }

  Widget noOrder() {
    return NoDataContainer(
        image: "empty_order",
        title: UiUtils.getTranslatedLabel(context, noOrderYetLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noOrderYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget myOrder() {
    return BlocConsumer<OrderCubit, OrderState>(
        bloc: context.read<OrderCubit>(),
        listener: (context, state) {
          if (state is OrderFailure) {
            if(state.errorStatusCode.toString() == "102"){
              reLogin(context);
            }
          }
        },
        builder: (context, state) {
          if (state is OrderProgress || state is OrderInitial) {
            return MyOrderSimmer(length: 5, width: width!, height: height!);
          }
          if (state is OrderFailure) {
            return (state.errorMessage.toString() == "No Order(s) Found !" || state.errorStatusCode.toString() == "102")
                ?  noOrder()
                : Center(
                    child: Text(
                    state.errorMessage.toString(),
                    textAlign: TextAlign.center,
                  ));
          }
          final orderList = (state as OrderSuccess).orderList;
          final hasMore = state.hasMore;
          return orderList.isEmpty
              ? noOrder() 
              : SizedBox(height: height!/1.1,
                child: ListView.builder(
                    shrinkWrap: true,
                    controller: orderController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: orderList.length,
                    itemBuilder: (BuildContext context, index) {
                      List<bool> cancelStatus = [];
                      List<String> cancelStatusType = [];
                      int k = 0;
                      for (int j = 0; j < orderList[index].orderItems!.length; j++) {
                        if (orderList[index].orderItems![j].isCancelable == "1") {
                          cancelStatus.add(true);
                          cancelStatusType.add(orderList[index].orderItems![j].cancelableTill!);
                        } else {
                          cancelStatus.add(false);
                          cancelStatusType.add(orderList[index].orderItems![j].cancelableTill!);
                        }
                      }
                      var status = "";
                      if (orderList[index].activeStatus == deliveredKey) {
                        status = UiUtils.getTranslatedLabel(context, deliveredLabel);
                      } else if (orderList[index].activeStatus == pendingKey) {
                        status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                      } else if (orderList[index].activeStatus == waitingKey) {
                        status = UiUtils.getTranslatedLabel(context, awaitingLbLabel);
                      } else if (orderList[index].activeStatus == receivedKey) {
                        status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                      } else if (orderList[index].activeStatus == outForDeliveryKey) {
                        status = UiUtils.getTranslatedLabel(context, outForDeliveryLbLabel);
                      } else if (orderList[index].activeStatus == confirmedKey) {
                        status = UiUtils.getTranslatedLabel(context, confirmedLbLabel);
                      } else if (orderList[index].activeStatus == cancelledKey) {
                        status = UiUtils.getTranslatedLabel(context, cancelLabel);
                      } else if (orderList[index].activeStatus == preparingKey) {
                        status = UiUtils.getTranslatedLabel(context, preparingLbLabel);
                      } else if (orderList[index].activeStatus == readyForPickupKey) {
                        status = UiUtils.getTranslatedLabel(context, pickupLabel);
                      }  else if (orderList[index].activeStatus == draftKey) {
                          status = UiUtils.getTranslatedLabel(context, draftLabel);
                        } else {
                        status = "";
                      }
                      var inputDate = inputFormat.parse(orderList[index].dateAdded!); // <-- dd/MM 24H format
                      var outputDate = outputFormat.format(inputDate);
                      return hasMore && index == (orderList.length - 1)
                          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                          : BlocProvider(
                              create: (context) => ReOrderCubit(OrderRepository()),
                              child: Builder(builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    print(orderList[index].activeStatus);
                                    Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
                                      'id': orderList[index].id!,
                                      'riderId': orderList[index].riderId!,
                                      'riderName': orderList[index].riderName!,
                                      'riderRating': orderList[index].riderRating!,
                                      'riderImage': orderList[index].riderImage!,
                                      'riderMobile': orderList[index].riderMobile!,
                                      'riderNoOfRating': orderList[index].riderNoOfRatings!,
                                      'isSelfPickup': orderList[index].isSelfPickUp!,
                                      'from': orderList[index].activeStatus=="delivered"?'orderDeliverd':'orderDetail'
                                    });
                                  },
                                  child: Container(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 0.0, top: 0, end: 0, bottom: height! / 80.0),
                                      //height: height!/4.7,
                                      width: width!,
                                      margin: EdgeInsetsDirectional.only(
                                        top: index==0?0.0:height! / 70.0,
                                        start: width! / 20.0,
                                        end: width! / 20.0,
                                      ),
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                      child: Column(
                                        children: [
                                          Container(decoration: DesignConfig.boxDecorationContainerHalf(
                                           Theme.of(context).colorScheme.onSurface), padding: EdgeInsetsDirectional.only(
                                          start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                                        child: DesignConfig.imageWidgets(orderList[index].orderItems![0].partnerDetails![0].partnerProfile!, 50.0, 50.0,"2")),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsetsDirectional.only(bottom: 0.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    orderList[index].orderItems![0].partnerDetails![0].partnerName!,
                                                                    textAlign: TextAlign.start,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                                        fontSize: 14,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        fontWeight: FontWeight.w500),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                SizedBox(width: width! / 50.0),
                                                                FittedBox(
                                                            fit: BoxFit.fitWidth,
                                                            child: Container(
                                                              alignment: Alignment.topLeft,
                                                              padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5, start: 4.5, end: 4.5),
                                                              //width: width!/3.0,
                                                              decoration: DesignConfig.boxDecorationContainerBorder(orderList[index].activeStatus == deliveredKey
                                                                      ? Theme.of(context).colorScheme.onPrimary
                                                                      : orderList[index].activeStatus == cancelledKey
                                                                          ? Theme.of(context).colorScheme.error
                                                                          : blueColor,
                                                                  orderList[index].activeStatus == deliveredKey
                                                                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.10)
                                                                      : orderList[index].activeStatus == cancelledKey
                                                                          ? Theme.of(context).colorScheme.error.withOpacity(0.10)
                                                                          : blueColor.withOpacity(0.10),
                                                                  4.0),
                                                              child: Text(
                                                                status,
                                                                style: TextStyle(fontSize: 12, color: orderList[index].activeStatus == deliveredKey
                                                                      ? Theme.of(context).colorScheme.onPrimary
                                                                      : orderList[index].activeStatus == cancelledKey
                                                                          ? Theme.of(context).colorScheme.error
                                                                          : blueColor,),
                                                              ),
                                                            ),
                                                          ),
                                                                /* orderList[index].orderItems![0].partnerDetails![0].partnerIndicator == "1"
                                                                    ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                                    : orderList[index].orderItems![0].partnerDetails![0].partnerIndicator == "2"
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
                                                                          ), */
                                                              ],
                                                            ),
                                                            /*Expanded(flex: 4,
                                                                child: Align(
                                                                  alignment: Alignment.topRight,
                                                                  child: Container(alignment: Alignment.center,
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 4.5, bottom: 4.5),
                                                                    width: 55,
                                                                    decoration: DesignConfig
                                                                        .boxDecorationContainer(
                                                                        orderList[index].activeStatus ==
                                                                            deliveredKey
                                                                            ? green
                                                                            :orderList[index].activeStatus ==
                                                                            cancelledKey
                                                                            ? red
                                                                            : blueColor,
                                                                        4.0),
                                                                    child: Text(
                                                                      status,
                                                                      style: const TextStyle(
                                                                          fontSize: 12,
                                                                          color: ColorsRes
                                                                              .white),
                                                                    ),
                                                                  ),),
                                                              ),*/
                                                          ),
                                                          /* Text(orderList[index].orderItems![0].partnerDetails![0].tags!.join(', ').toString(),
                                                            textAlign: TextAlign.start,
                                                            style: const TextStyle(
                                                              color: lightFont,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight
                                                                  .normal,)),*/
                                                                  Text(orderList[index].orderItems![0].partnerDetails![0].partnerAddress.toString(),
                                                            textAlign: TextAlign.start,
                                                            style: const TextStyle(
                                                              color: lightFont,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight
                                                                  .normal,)),
                                                          const SizedBox(height: 2.0),        
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SvgPicture.asset(DesignConfig.setSvgPath("delivery_time"), colorFilter: const ColorFilter.mode(lightFont, BlendMode.srcIn),
                                                                  fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                orderList[index]
                                                                    .orderItems![0]
                                                                    .partnerDetails![0]
                                                                    .partnerCookTime!
                                                                    .toString()
                                                                    .replaceAll(regex, ''),
                                                                textAlign: TextAlign.center,
                                                                style: const TextStyle(
                                                                    color: lightFont,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.normal,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: height! / 99.0),
                                                          /* FittedBox(
                                                            fit: BoxFit.fitWidth,
                                                            child: Container(
                                                              alignment: Alignment.topLeft,
                                                              padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5, start: 4.5, end: 4.5),
                                                              //width: width!/3.0,
                                                              decoration: DesignConfig.boxDecorationContainer(
                                                                  orderList[index].activeStatus == deliveredKey
                                                                      ? green
                                                                      : orderList[index].activeStatus == cancelledKey
                                                                          ? red
                                                                          : blueColor,
                                                                  4.0),
                                                              child: Text(
                                                                status,
                                                                style: const TextStyle(fontSize: 12, color: white),
                                                              ),
                                                            ),
                                                          ), */
                                                        ]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          /* Container(
                                        height: height! / 7.3, color: white,
                                        child: ListView.builder(shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: orderList[index].orderItems!
                                                .length,
                                            itemBuilder: (BuildContext context, index) {
                                              return Container(
                                                  padding: EdgeInsetsDirectional.only(
                                                      bottom: height! / 99.0),
                                                  //height: height!/4.7,
                                                  width: width!,
                                                  margin: EdgeInsetsDirectional.only(
                                                      top: height! / 60.0,
                                                      start: width! / 60.0,
                                                      end: width! / 60.0),
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(orderList[index]
                                                            .orderItems![index].name! +
                                                            " x " + orderList[index]
                                                            .orderItems![index]
                                                            .quantity!,
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                                color: ColorsRes
                                                                    .backgroundDark,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight
                                                                    .w500)),
                                                        Text(context.read<SystemConfigCubit>().getCurrency() +
                                                            " " + orderList[index]
                                                            .orderItems![index].price!,
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                                color: red,
                                                                fontSize: 13,
                                                                fontWeight: FontWeight
                                                                    .w700)),
                                                      ]
                                                  ));
                                            }
                                        )),*/
                                          Column(
                                              children: List.generate(orderList[index].orderItems!.length, (i) {
                                            k = i;
                                            OrderItems data = orderList[index].orderItems![i];
                                            return InkWell(
                                                onTap: () {
                                                  /*if(offerCouponsList[index].status=="1") {
                                                              coupons(context, offerCouponsList[index].couponsCode!, offerCouponsList[index].price!);
                                                            }*/
                                                },
                                                child: Container(
                                                  padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                                  //height: height!/4.7,
                                                  width: width!,
                                                  margin: EdgeInsetsDirectional.only(top: height! / 99.0, start: width! / 40.0, end: width! / 60.0),
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            data.indicator == "1"
                                                            ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                            : data.indicator == "2"
                                                                ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                                : const SizedBox(height: 15, width: 15.0),
                                                                const SizedBox(width: 5.0),
                                                                Text(
                                                                "${data.quantity!} x ",
                                                                textAlign: Directionality.of(context) == ui.TextDirection.rtl
                                                                    ? TextAlign.right
                                                                    : TextAlign.left,
                                                                style: const TextStyle(
                                                                    color: lightFont,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 1,
                                                              ),
                                                            Expanded(
                                                              child: Text(
                                                                data.name!,
                                                                textAlign: Directionality.of(context) == ui.TextDirection.rtl
                                                                    ? TextAlign.right
                                                                    : TextAlign.left,
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    overflow: TextOverflow.ellipsis),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            //const Spacer(),
                                                            /* orderList[index].activeStatus == deliveredKey
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      Navigator.of(context).pushNamed(Routes.productRating,
                                                                          arguments: {'orderId': orderList[index].id!});
                                                                    },
                                                                    child: Align(
                                                                      alignment: Alignment.topRight,
                                                                      child: Container(
                                                                        alignment: Alignment.center,
                                                                        padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                                                                        width: 55,
                                                                        decoration:
                                                                            DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSecondary, 4.0),
                                                                        child: Text(
                                                                          StringsRes.rate,
                                                                          style: const TextStyle(fontSize: 12, color: white),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(), */
                                                          ],
                                                        ),
                                                        orderList[index].orderItems![i].attrName != ""
                                                            ? Padding(
                                                              padding: EdgeInsetsDirectional.only(start: width!/20.0),
                                                              child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text("${orderList[index].orderItems![i].attrName!} : ",
                                                                        textAlign: TextAlign.left,
                                                                        style: const TextStyle(
                                                                            color: lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
                                                                    Text(orderList[index].orderItems![i].variantValues!,
                                                                        textAlign: TextAlign.left,
                                                                        style: const TextStyle(
                                                                          color: lightFont,
                                                                          fontSize: 10,
                                                                        )),
                                                                  ],
                                                                ),
                                                            )
                                                            : Container(),
                                                        /* const SizedBox(height: 5.0),
                                                        Text("${context.read<SystemConfigCubit>().getCurrency()}${data.price!}",
                                                            textAlign: TextAlign.center,
                                                            style:
                                                                const TextStyle(color: red, fontSize: 13, fontWeight: FontWeight.w700)),
                                                        orderList[index].orderItems![i].addOns!.isNotEmpty
                                                            ? Padding(
                                                                padding: const EdgeInsetsDirectional.only(top: 8.0),
                                                                child: Text(StringsRes.extraAddOn,
                                                                    textAlign: TextAlign.center,
                                                                    style: const TextStyle(
                                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight.w500)),
                                                              )
                                                            : Container(), */
                                                            Padding(
                                                              padding: EdgeInsetsDirectional.only(start: width!/20.0, end: width!/99.0),
                                                              child: Wrap( 
                                                              spacing: 5.0,
                                                              runSpacing: 2.0, 
                                                              direction: Axis.horizontal,
                                                              children:  List.generate(orderList[index].orderItems![i].addOns!.length, (j) {
                                                                AddOnsDataModel addOnData = orderList[index].orderItems![i].addOns![j];
                                                                return Text("${addOnData.qty!} x ${addOnData.title!}, ",
                                                                        textAlign: TextAlign.center,
                                                                        style: const TextStyle(color: lightFontColor, fontSize: 10, overflow: TextOverflow.ellipsis),
                                                                        maxLines: 2,
                                                                      );
                                                                })
                                                              ),
                                                            ),
                                                        /* Column(
                                                            children: List.generate(orderList[index].orderItems![i].addOns!.length, (j) {
                                                          AddOnsDataModel addOnData = orderList[index].orderItems![i].addOns![j];
                                                          return InkWell(
                                                              onTap: () {
                                                                /*if(offerCouponsList[index].status=="1") {
                                                          coupons(context, offerCouponsList[index].couponsCode!, offerCouponsList[index].price!);
                                                        }*/
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                                                //height: height!/4.7,
                                                                width: width!,
                                                                margin: EdgeInsetsDirectional.only(top: height! / 60.0, end: width! / 60.0),
                                                                child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text("${addOnData.title!} x ${addOnData.qty!}",
                                                                          textAlign: TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: lightFontColor,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500)),
                                                                      Text("${context.read<SystemConfigCubit>().getCurrency()}${addOnData.price!}",
                                                                          textAlign: TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: red, fontSize: 14, fontWeight: FontWeight.w700)),
                                                                    ]),
                                                              ));
                                                        })), */
                                                      ]),
                                                ));
                                          })),
                                          /* Padding(
                                            padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 70.0),
                                            child: Divider(
                                              color: lightFont.withOpacity(0.50),
                                              height: 1.0,
                                            ),
                                          ), */
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 80.0, start: width!/40.0, end: width!/40.0),
                                            child: const DashLineView(
                                              fillRate: 0.7,
                                              direction: Axis.horizontal,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(start: width!/40.0, end: width!/40.0),
                                            child: Row(children: [
                                              Text(outputDate.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(color: lightFont, fontSize: 10, fontWeight: FontWeight.normal)),
                                              const Spacer(),
                                              Text(context.read<SystemConfigCubit>().getCurrency() + orderList[index].finalTotal!,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.96)),
                                                      Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSecondary, size: 12.0)
                                            ]),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 70.0, start: width!/40.0, end: width!/40.0),
                                            child: const DashLineView(
                                              fillRate: 0.7,
                                              direction: Axis.horizontal,
                                            ),
                                          ),
                                          Row(mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              (orderList[index].activeStatus == preparingKey || orderList[index].activeStatus == cancelledKey)
                                                    ? const SizedBox()
                                                    : (orderList[index].activeStatus == deliveredKey && orderList[index].orderProductRating!="")?Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                  Text("${UiUtils.getTranslatedLabel(context, youRatedLabel)} :",
                                                                      style: TextStyle(
                                                                          color: Theme.of(context).colorScheme.secondary,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w700)),
                                                                  Container(
                                                                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width!/40.0),
                                                                      padding: EdgeInsetsDirectional.only(
                                                                          start: width! / 60.0, end: width! / 60.0, top: 5.0, bottom: 5.0),
                                                                      decoration: DesignConfig.boxDecorationContainer(
                                                                          yellowColor, 4.0),
                                                                      child: Row(children: [
                                                                        Text("${double.parse(orderList[index].orderProductRating??"0.0").toStringAsFixed(2).replaceAll(regex, '')} ",
                                                                            style: TextStyle(
                                                                                color: Theme.of(context).colorScheme.secondary,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w700)),
                                                                        Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 15.0)
                                                                      ])),
                                                                ]):SmallButtonContainer(
                                                        color: Theme.of(context).colorScheme.onSurface,
                                                        height: height,
                                                        width: width,
                                                        text: orderList[index].activeStatus == deliveredKey
                                                            ? UiUtils.getTranslatedLabel(context, rateLabel)
                                                            : (cancelStatus[k] == true && ((cancelStatusType[k] == "")||(isStatusAfter(orderList[index].activeStatus!, cancelStatusType[k]))))
                                                                ? UiUtils.getTranslatedLabel(context, cancelLabel)
                                                                : "",
                                                        start: width! / 40.0,
                                                        end: width! / 99.0,
                                                        bottom: 0,
                                                        top: 0,
                                                        radius: 5.0,
                                                        status: false,
                                                        borderColor: orderList[index].activeStatus == deliveredKey || (cancelStatus[k] == true  &&
                                                                        ((cancelStatusType[k] == "") ||
                                                                            (isStatusAfter(orderList[index].activeStatus!, cancelStatusType[k]))))
                                                            ? Theme.of(context).colorScheme.secondary
                                                            : Theme.of(context).colorScheme.onSurface,
                                                        textColor: Theme.of(context).colorScheme.onSecondary,
                                                        onTap: () {
                                                          if (mounted) {
                                                            print(orderList[index].activeStatus);
                                                            if (orderList[index].activeStatus == deliveredKey) {
                                                              Navigator.of(context)
                                                                  .pushNamed(Routes.productRating, arguments: {'orderId': orderList[index].id!});
                                                            } else if (cancelStatus[k] == true  && ((cancelStatusType[k] == "") || (isStatusAfter(orderList[index].activeStatus!, cancelStatusType[k])))) {
                                                              print(cancelStatus[k]);
                                                              if (orderList[index].activeStatus == cancelledKey) {
                                                                UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, orderLabel),
                                                                    StringsRes.orderCantCancel, context, false,
                                                                    type: "2");
                                                              } else {
                                                                context.read<UpdateOrderStatusCubit>().clearOrderStatus();
                                                                cancel(context, cancelledKey, orderList[index].id!);
                                                              }
                                                            } else {
                                                              //UiUtils.setSnackBar(StringsRes.order, StringsRes.orderCantCancel, context, false);
                                                            }
                                                          }
                                                        },
                                                      ),
                                              BlocConsumer<ReOrderCubit, ReOrderState>(
                                                  bloc: context.read<ReOrderCubit>(),
                                                  listener: (context, state) {
                                                    if (state is ReOrderSuccess) {
                                                      //UiUtils.setSnackBar(StringsRes.addToCart, StringsRes.updateSuccessFully, context, false);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => const CartScreen(),
                                                        ),
                                                      );
                                                    } else if (state is ReOrderFailure) {
                                                      //Navigator.pop(context);
                                                      //showMessage = state.errorMessage.toString();
                                                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addToCartLabel), state.errorMessage, context, false, type: "2");
                                                    }
                                                  },
                                                  builder: (context, state) {
                                                    print("state: $state");
                                                    return SmallButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: orderList[index].activeStatus == outForDeliveryKey
                                                                    ? UiUtils.getTranslatedLabel(context, trackOrderLabel)
                                                                    : UiUtils.getTranslatedLabel(context, reOrderLabel), start: width! / 99.0, end: width! / 40.0, bottom: 0, top: 0, radius: 5.0, status: (state is ReOrderProgress)?true:false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onTap: (){
                                                        if (orderList[index].activeStatus == outForDeliveryKey) {
                                                            //print(orderList[index].activeStatus);
                                                            Navigator.of(context).pushNamed(Routes.orderTracking, arguments: {
                                                              'id': orderList[index].id!,
                                                              'riderId': orderList[index].riderId!,
                                                              'riderName': orderList[index].riderName!,
                                                              'riderRating': orderList[index].riderRating!,
                                                              'riderImage': orderList[index].riderImage!,
                                                              'riderMobile': orderList[index].riderMobile!,
                                                              'riderNoOfRating': orderList[index].riderNoOfRatings!,
                                                              'latitude': double.parse(orderList[index].latitude!),
                                                              'longitude': double.parse(orderList[index].longitude!),
                                                              'latitudeRes':
                                                                  double.parse(orderList[index].orderItems![0].partnerDetails![0].latitude!),
                                                              'longitudeRes':
                                                                  double.parse(orderList[index].orderItems![0].partnerDetails![0].longitude!),
                                                              'orderAddress': orderList[index].address,
                                                              'partnerAddress':
                                                                  orderList[index].orderItems![0].partnerDetails![0].partnerAddress!
                                                            });
                                                          } else {
                                                            //if (orderList[index].activeStatus == deliveredKey) {
                                                            /* List<String> addOnId = [];
                                                            List<String> addOnQty = [];
                                                            for (int i = 0; i < orderList[index].orderItems!.length; i++) {
                                                              addOnId.clear();
                                                              addOnQty.clear();
                                                              for (int j = 0; j < orderList[index].orderItems![i].addOns!.length; j++) {
                                                                addOnId.add(orderList[index].orderItems![i].addOns![j].id!);
                                                                addOnQty.add(orderList[index].orderItems![i].addOns![j].qty!);
                                                              }
                                                              context.read<ManageCartCubit>().manageCartUser(
                                                                  userId: context.read<AuthCubit>().getId(),
                                                                  productVariantId: orderList[index].orderItems![i].productVariantId!,
                                                                  isSavedForLater: "0",
                                                                  qty: orderList[index].orderItems![i].quantity!,
                                                                  addOnId: addOnId.join(","),
                                                                  addOnQty: addOnQty.join(",")); 
                                                            }*/
                                                                  context.read<ReOrderCubit>().reOrder(orderId: orderList[index].id);
                                                          }
                  },);
                                                  })
                                            ],
                                          ),
                                        ],
                                      )),
                                );
                              }),
                            );
                    }),
              );
        });
  }

  Future<void> refreshList() async {
    context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), "", "");
  }

  @override
  void dispose() {
    orderController.dispose();
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, myOrderLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: Container(height: height,
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                width: width,
                child: RefreshIndicator(
                  onRefresh: refreshList,
                  color: Theme.of(context).colorScheme.primary,
                  child: myOrder(),
                ),
              ),
            ),
    );
  }
}

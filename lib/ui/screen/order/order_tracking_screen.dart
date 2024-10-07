import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/order/orderCubit.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/widgets/buttomWithImageContainer.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/internetConnectivity.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating, orderAddress, partnerAddress;
  final double? latitude, longitude, latitudeRes, longitudeRes;
  const OrderTrackingScreen(
      {Key? key,
      this.id,
      this.riderId,
      this.riderName,
      this.riderRating,
      this.riderImage,
      this.riderMobile,
      this.riderNoOfRating,
      this.latitude,
      this.longitude,
      this.orderAddress,
      this.partnerAddress,
      this.latitudeRes,
      this.longitudeRes})
      : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: OrderTrackingScreen(
                  id: arguments['id'] as String,
                  riderName: arguments['riderName'] as String,
                  riderRating: arguments['riderRating'] as String,
                  riderImage: arguments['riderImage'] as String,
                  riderMobile: arguments['riderMobile'] as String,
                  riderNoOfRating: arguments['riderNoOfRating'] as String,
                  latitude: arguments['latitude'] as double,
                  longitude: arguments['longitude'] as double,
                  latitudeRes: arguments['latitudeRes'] as double,
                  longitudeRes: arguments['longitudeRes'] as double,
                  orderAddress: arguments['orderAddress'] as String,
                  partnerAddress: arguments['partnerAddress'] as String),
            ));
  }
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? orderStatus = "";
  var inputFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
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
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), widget.id!, "");
    });
    print(
        "Data:${widget.id}${widget.riderName}${widget.riderRating}${widget.riderImage}${widget.riderMobile}${widget.riderNoOfRating}${widget.latitude}${widget.longitude}${widget.latitudeRes}${widget.longitudeRes}${widget.orderAddress}${widget.partnerAddress}");
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
            appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, orderTrackingLabel),
                const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
            bottomNavigationBar: SizedBox(
              width: width,
              child: ButtonImageContainer(
                  color: Theme.of(context).colorScheme.secondary,
                  height: height,
                  width: width,
                  text: UiUtils.getTranslatedLabel(context, trackMyOrderLabel),
                  bottom: height! / 40.0,
                  start: width! / 30.0,
                  end: height! / 50.0,
                  top: 0.0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.secondary,
                  textColor: white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.orderTrackingDetail, arguments: {
                      'id': widget.id!,
                      //'riderId': widget.riderId!,
                      'riderName': widget.riderName!,
                      'riderRating': widget.riderRating!,
                      'riderImage': widget.riderImage!,
                      'riderMobile': widget.riderMobile!,
                      'riderNoOfRating': widget.riderNoOfRating!,
                      'latitude': widget.latitude!,
                      'longitude': widget.longitude!,
                      'latitudeRes': widget.latitudeRes!,
                      'longitudeRes': widget.longitude!,
                      'orderAddress': widget.orderAddress,
                      'partnerAddress': widget.partnerAddress!
                    });
                  },
                  widget: Icon(Icons.my_location_outlined, color: Theme.of(context).colorScheme.onSurface)),
            ),
            body: BlocConsumer<OrderCubit, OrderState>(
                bloc: context.read<OrderCubit>(),
                listener: (context, state) {
                  if (state is OrderFailure) {
                    if (state.errorStatusCode.toString() == "102") {
                      reLogin(context);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is OrderProgress || state is OrderInitial) {
                    return Center(
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    );
                  }
                  if (state is OrderFailure) {
                    return Center(
                        child: Text(
                      state.errorMessage.toString(),
                      textAlign: TextAlign.center,
                    ));
                  }
                  final orderList = (state as OrderSuccess).orderList;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: width!,
                        padding: EdgeInsetsDirectional.only(start: width! / 35.0, top: height! / 80.0, end: width! / 35.0, bottom: height! / 80.0),
                        margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 40.0, end: width! / 40.0, bottom: height! / 52.0),
                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                        child: Row(
                          children: [
                            Text(UiUtils.getTranslatedLabel(context, orderIdLabel),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14.0)),
                            const Spacer(),
                            Text("#${orderList[0].id!}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12.0)),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Container(
                        width: width!,
                        decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                        padding: EdgeInsetsDirectional.only(start: width! / 40.0 /*, bottom: height!/50.0*/, end: width! / 40.0, top: height! / 40.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(orderList[0].status!.length, (index) {
                                  var status = "";
                                  if (orderList[0].status![index][0] == deliveredKey) {
                                    status = UiUtils.getTranslatedLabel(context, deliveredLabel);
                                  } else if (orderList[0].status![index][0] == pendingKey) {
                                    status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                                  } else if (orderList[0].status![index][0] == waitingKey) {
                                    status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                                  } else if (orderList[0].status![index][0] == receivedKey) {
                                    status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                                  } else if (orderList[0].status![index][0] == outForDeliveryKey) {
                                    status = UiUtils.getTranslatedLabel(context, outForDeliveryLbLabel);
                                  } else if (orderList[0].status![index][0] == confirmedKey) {
                                    status = UiUtils.getTranslatedLabel(context, confirmedLbLabel);
                                  } else if (orderList[0].status![index][0] == cancelledKey) {
                                    status = UiUtils.getTranslatedLabel(context, cancelLabel);
                                  } else if (orderList[0].status![index][0] == preparingKey) {
                                    status = UiUtils.getTranslatedLabel(context, preparingLbLabel);
                                  } else {
                                    status = "";
                                  }
                                  var inputDate = inputFormat.parse(orderList[0].status![index][1]);
                                  var outputDate = outputFormat.format(inputDate);
                                  print("${orderList[0].status![index][1]}-----$outputDate");
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: width! / 4.0,
                                              child: Text(
                                                outputDate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 12.0),
                                                maxLines: 2,
                                              ),
                                            ),
                                            Column(mainAxisSize: MainAxisSize.min, children: [
                                              Container(
                                                  width: width! / 30.0,
                                                  height: height! / 5.5,
                                                  margin: EdgeInsetsDirectional.only(start: width! / 80.0, end: width! / 30.0),
                                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 10.0)),
                                              Container(
                                                  width: 10.0,
                                                  height: 10.0,
                                                  margin: EdgeInsetsDirectional.only(start: width! / 80.0, end: width! / 30.0),
                                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 5.0)),
                                            ]),
                                            Flexible(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                      margin: EdgeInsetsDirectional.only(end: width! / 50.0),
                                                      alignment: Alignment.center,
                                                      height: 36.0,
                                                      width: 36,
                                                      decoration: DesignConfig.boxDecorationContainer(
                                                          orderList[0].status![index][0] == pendingKey
                                                              ? orderTrackingCardYellowColor.withOpacity(0.30)
                                                              : orderList[0].status![index][0] == confirmedKey
                                                                  ? orderTrackingCardGreenColor.withOpacity(0.30)
                                                                  : orderList[0].status![index][0] == preparingKey
                                                                      ? orderTrackingCardRedColor.withOpacity(0.30)
                                                                      : orderList[0].status![index][0] == outForDeliveryKey
                                                                          ? orderTrackingCardPeachColor.withOpacity(0.30)
                                                                          : orderTrackingCardYellowColor.withOpacity(0.30),
                                                          5.0),
                                                      child: SvgPicture.asset(
                                                          DesignConfig.setSvgPath(orderList[0].status![index][0] == pendingKey ||
                                                                  orderList[0].status![index][0] == waitingKey
                                                              ? "order_place"
                                                              : orderList[0].status![index][0] == confirmedKey
                                                                  ? "order_confirmed"
                                                                  : orderList[0].status![index][0] == preparingKey
                                                                      ? "order_prepared"
                                                                      : orderList[0].status![index][0] == outForDeliveryKey
                                                                          ? "order_of_for_delivery"
                                                                          : ""),
                                                          width: 24,
                                                          height: 24)),
                                                  const SizedBox(height: 5.0),
                                                  Row(children: [
                                                    Text("${UiUtils.getTranslatedLabel(context, statusLabel)}: ",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                            color: Theme.of(context).colorScheme.onSecondary,
                                                            fontWeight: FontWeight.w600,
                                                            fontStyle: FontStyle.normal,
                                                            fontSize: 12.0)),
                                                    Text("${UiUtils.getTranslatedLabel(context, orderLabel)} $status",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                            color: orderList[0].status![index][0] == pendingKey
                                                                ? yellowColor
                                                                : orderList[0].status![index][0] == confirmedKey
                                                                    ? orderTrackingCardGreenColor
                                                                    : orderList[0].status![index][0] == preparingKey
                                                                        ? orderTrackingCardRedColor
                                                                        : orderList[0].status![index][0] == outForDeliveryKey
                                                                            ? orderTrackingCardOrangeColor
                                                                            : orderTrackingCardYellowColor,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500))
                                                  ]),
                                                  const SizedBox(height: 1.0),
                                                  Text("${UiUtils.getTranslatedLabel(context, yourOrderLabel)} $status",
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSecondary,
                                                          fontWeight: FontWeight.w400,
                                                          fontStyle: FontStyle.normal,
                                                          fontSize: 12.0)),
                                                  const SizedBox(height: 1.0),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: width! / 30.0,
                                        height: height! / 5.5,
                                        margin: EdgeInsetsDirectional.only(start: width! / 3.47, end: width! / 30.0),
                                        decoration: DesignConfig.boxDecorationContainer(timeLineColor, 10.0)),
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              margin: EdgeInsetsDirectional.only(end: width! / 50.0),
                                              alignment: Alignment.center,
                                              height: 36.0,
                                              width: 36,
                                              decoration: DesignConfig.boxDecorationContainer(orderTrackingCardBlueColor, 5.0),
                                              child: SvgPicture.asset(DesignConfig.setSvgPath("order_pickup"), width: 24, height: 24)),
                                          Row(children: [
                                            Text("${UiUtils.getTranslatedLabel(context, statusLabel)}: ",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 12.0)),
                                            Text(
                                                "${UiUtils.getTranslatedLabel(context, orderLabel)} ${UiUtils.getTranslatedLabel(context, deliveryLabel)}",
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(color: facebookColor, fontSize: 12, fontWeight: FontWeight.w500))
                                          ]),
                                          const SizedBox(height: 1.0),
                                          Text(
                                              "${UiUtils.getTranslatedLabel(context, yourOrderLabel)} ${UiUtils.getTranslatedLabel(context, deliveredLabel)}",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSecondary,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 12.0)),
                                          const SizedBox(height: 1.0),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                      )),
                      //SizedBox(height: height! / 20.0),
                    ],
                  );
                }));
  }
}

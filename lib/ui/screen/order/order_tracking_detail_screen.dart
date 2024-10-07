import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/order/orderCubit.dart';
import 'package:project1/cubit/order/orderLiveTrackingCubit.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:project1/utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class OrderTrackingDetailScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating, orderAddress, partnerAddress;
  final double? latitude, longitude, latitudeRes, longitudeRes;
  const OrderTrackingDetailScreen(
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
  _OrderTrackingDetailScreenState createState() => _OrderTrackingDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: OrderTrackingDetailScreen(
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

class _OrderTrackingDetailScreenState extends State<OrderTrackingDetailScreen> {
  LatLng? latlong;
  TextEditingController locationController = TextEditingController();
  double? width, height;
  late Position position;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? orderStatus = "";
  Timer? timer;
  late GoogleMapController mapController;
  double? _originLatitude, _originLongitude;
  double? _destLatitude, _destLongitude;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late LatLng deliveryBoyLocation = const LatLng(0, 0);
  late PolylineId polylineId;
  ScrollController orderController = ScrollController();
  BitmapDescriptor? driverIcon, restaurantsIcon, destinationIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    //DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, 'marker');
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    // You can draw the picture to a canvas:
    //canvas.drawPicture(pictureInfo.picture);

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    //double width = 50 * devicePixelRatio;
    //double height = 50 * devicePixelRatio;
    double width = 32 * devicePixelRatio;
    double height = 32 * devicePixelRatio;

    // Convert to ui.Picture
    //ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));


    //final ui.Image image = await pictureInfo.picture.toImage(width.toInt(), height.toInt());

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    canvas.scale(width / pictureInfo.size.width, height / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);
    final ui.Picture scaledPicture = recorder.endRecording();

    final image = await scaledPicture.toImage(width.toInt(), height.toInt());

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    
    //ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

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
    print(
        "Data:${widget.id}${widget.riderName}${widget.riderRating}${widget.riderImage}${widget.riderMobile}${widget.riderNoOfRating}${widget.latitude}${widget.longitude}${widget.latitudeRes}${widget.longitudeRes}${widget.orderAddress}${widget.partnerAddress}");
    orderLiveTracking();
    _destLatitude = widget.latitude!;
    _destLongitude = widget.longitude!;
    orderController.addListener(orderScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), widget.id!, "");
    });

    /// destination marker
    _addMarker(LatLng(_destLatitude!, _destLongitude!), "destination", 1);

    /// Current restaurant
    _addMarker(LatLng(widget.latitudeRes!, widget.longitudeRes!), "restaurant", 2);

    _getPolylineBetweenRestaurantToCustomer();
  }

  void orderLiveTracking() {
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      context.read<OrderLiveTrackingCubit>().getOrderLiveTracking(orderId: widget.id!);
      _getPolylineBetweenRestaurantToDeliveryBoy();
    });
  }

  orderScrollListener() {
    if (orderController.position.maxScrollExtent == orderController.offset) {
      if (context.read<OrderCubit>().hasMoreData()) {
        context.read<OrderCubit>().fetchMoreOrderData(perPage, context.read<AuthCubit>().getId(), widget.id!, "");
      }
    }
  }

  Widget noTrackingData() {
    return Container(
      height: height,
      margin: EdgeInsetsDirectional.only(top: height! / 80.0),
      width: width,
      child: NoDataContainer(
          image: "delivery_boy_tracking",
          title: UiUtils.getTranslatedLabel(context, orderTrackingLabel),
          subTitle: UiUtils.getTranslatedLabel(context, notStartYetRideLabel),
          width: width!,
          height: height!),
    );
  }

  @override
  void dispose() {
    timer!.cancel();
    locationController.dispose();
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
          appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, orderTrackingLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
            body: BlocConsumer<OrderLiveTrackingCubit, OrderLiveTrackingState>(
                bloc: context.read<OrderLiveTrackingCubit>(),
                listener: (context, state) {
                  if (state is OrderLiveTrackingSuccess) {
                    _originLatitude = double.parse(state.orderLiveTracking.latitude!);
                    _originLongitude = double.parse(state.orderLiveTracking.longitude!);
                    orderStatus = state.orderLiveTracking.orderStatus;
                    if (orderStatus == deliveredKey) {
                      Future.delayed(Duration.zero, () {
                        Navigator.of(context).pushReplacementNamed(Routes.home/* , arguments: {'id': 0} */);
                      });
                    }
                    print("OderStatus:$orderStatus");
                    _addMarker(LatLng(_originLatitude!, _originLongitude!), "origin", 0);
                    updateMarker(LatLng(_originLatitude!, _originLongitude!), "origin");
                  }
                },
                builder: (context, state) {
                  if (state is OrderLiveTrackingProgress || state is OrderLiveTrackingInitial) {
                    return /* Center(
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    ) */noTrackingData();
                  }
                  if (state is OrderLiveTrackingFailure) {
                    if(state.errorStatusCode.toString() == "102"){
                            reLogin(context);
                    }
                    return noTrackingData();
                  }
                  //final orderLiveTracingList = (state as OrderLiveTrackingSuccess).orderLiveTracking;
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
                          return Center(
                            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                          );
                        }
                        if (state is OrderFailure) {
                          return NoDataContainer(
                            image: "delivery_boy_tracking",
                            title: UiUtils.getTranslatedLabel(context, orderTrackingLabel),
                            subTitle: UiUtils.getTranslatedLabel(context, notStartYetRideLabel),
                            width: width!,
                            height: height!);
                        }
                        final orderList = (state as OrderSuccess).orderList;
                        return Stack(
                          children: [
                            Container(
                              height: height!,
                              padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).padding.top),
                              child: _originLatitude != null && _originLongitude != null
                                  ? GoogleMap(
                                      initialCameraPosition: CameraPosition(target: LatLng(_originLatitude!, _originLongitude!), zoom: 14.0),
                                      myLocationEnabled: true,
                                      tiltGesturesEnabled: true,
                                      compassEnabled: true,
                                      scrollGesturesEnabled: true,
                                      zoomGesturesEnabled: true,
                                      onMapCreated: _onMapCreated,
                                      mapType: MapType.normal,
                                      markers: Set<Marker>.of(markers.values),
                                      polylines: Set<Polyline>.of(polylines.values),
                                    )
                                  : Container(),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(padding: EdgeInsetsDirectional.only(start: width! / 25.0, top: height! / 99.0, end: width! / 25.0),
                                margin: EdgeInsetsDirectional.only(top: height! / 1.95, start: width!/20.0, end: width!/20.0, bottom: height!/40.0),
                                decoration: DesignConfig.boxDecorationContainerCardShadow(
                                                      Theme.of(context).colorScheme.onSurface, shadowCard, 10.0, 0, 3, 6, 0),
                                width: width,
                                height: height!/3,
                                child: SingleChildScrollView(
                                  child: Stack(
                                    children: [
                                      Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                        Text(UiUtils.getTranslatedLabel(context, orderTrackingLabel),
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSecondary, fontSize: 14.0, fontWeight: FontWeight.w500,fontStyle:  FontStyle.normal)),
                                                          Padding(padding: EdgeInsetsDirectional.only(bottom: height!/80.0, top: height!/80.0), child: DesignConfig.divider()),
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsetsDirectional.only(end: width! / 50.0),
                                              alignment: Alignment.center,
                                              height: 36.0,
                                              width: 36,
                                              decoration: DesignConfig.boxDecorationContainer(orderTrackingCardRedColor.withOpacity(0.30), 5.0),
                                              child: SvgPicture.asset(
                                                DesignConfig.setSvgPath("order_pickup"),
                                                width: 24,
                                                height: 24, colorFilter: const ColorFilter.mode(orderTrackingCardRedColor, BlendMode.srcIn))),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(UiUtils.getTranslatedLabel(context, deliveryFromLabel),
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w600,fontStyle:  FontStyle.normal)),
                                                SizedBox(
                                                    width: width! / 1.6,
                                                    child: Text(widget.partnerAddress!,
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w400, fontStyle:  FontStyle.normal))),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: height! / 17.0,
                                          width: 2.0,
                                          margin: EdgeInsetsDirectional.only(start: width! / 24.0),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: 20,
                                              itemBuilder: (BuildContext context, index) {
                                                return Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 2.0),
                                                  height: 5.0,
                                                  width: 2.0,
                                                  color: Theme.of(context).colorScheme.primary,
                                                );
                                              }),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsetsDirectional.only(end: width! / 50.0),
                                              alignment: Alignment.center,
                                              height: 36.0,
                                              width: 36,
                                              decoration: DesignConfig.boxDecorationContainer(orderTrackingCardRedColor.withOpacity(0.30), 5.0),
                                              child: SvgPicture.asset(
                                                DesignConfig.setSvgPath("order_pickup"),
                                                width: 24,
                                                height: 24, colorFilter: const ColorFilter.mode(orderTrackingCardRedColor, BlendMode.srcIn))),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(UiUtils.getTranslatedLabel(context, deliveryLocationLabel),
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w600,fontStyle:  FontStyle.normal)),
                                                SizedBox(
                                                    width: width! / 1.6,
                                                    child: Text(
                                                      widget.orderAddress!,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w400, fontStyle:  FontStyle.normal),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(padding: EdgeInsetsDirectional.only(bottom: height!/40.0, top: height!/40.0), child: DesignConfig.divider()),
                                      Row(mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                alignment: Alignment.center,
                                                height: 39.0,
                                                width: 39.0,
                                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 39.1),
                                                child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface)),
                                                Padding(
                                          padding: EdgeInsetsDirectional.only(end: width! / 60.0, start: width!/60.0),
                                          child: Column(mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(orderList[0].riderName ?? "",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 5.0),
                                              Text("${UiUtils.getTranslatedLabel(context, deliveryBoyIdLabel)}${orderList[0].riderId!}",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                                              // SvgPicture.asset(DesignConfig.setSvgPath(restaurantList[index].status=="1"?"veg_icon" : "non_veg_icon"), width: 15, height: 15),
                                            ],
                                          ),
                                        ),
                                          ],
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                        onTap: () async {
                                          //launch("tel:${Uri.encodeComponent(orderList[0].riderMobile!)}");
                                          final Uri launchUri = Uri(
                                            scheme: 'tel',
                                            path: orderList[0].riderMobile!,
                                          );
                                          await launchUrl(launchUri);
                                        },
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 30.0,
                                                    width: 30.0,
                                            margin:
                                                EdgeInsetsDirectional.only(top: height! / 80.0),
                                            padding: const EdgeInsets.all(3.1),
                                            decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 8.0),
                                            child: Icon(Icons.call, color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                      ),
                                      ],
                                      ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                }));
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _addPolyLine();
  }

  _addMarker(LatLng position, String id, int status) async {
    MarkerId markerId = MarkerId(id);
    BitmapDescriptor? icon, defaultIcon;
    if (status == 0) {
      //print("Status:"+status.toString());
      driverIcon = await bitmapDescriptorFromSvgAsset(context, DesignConfig.setSvgPath('delivery_boy'));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      icon = driverIcon;
    } else if (status == 1) {
      //print("Status:"+status.toString());
      restaurantsIcon = await bitmapDescriptorFromSvgAsset(context, DesignConfig.setSvgPath('map_pin'));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      icon = restaurantsIcon;
    } else {
      //print("Status:"+status.toString());
      destinationIcon = await bitmapDescriptorFromSvgAsset(context, DesignConfig.setSvgPath('address_icon'));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      icon = destinationIcon;
    }
    setState(() {});
    Marker marker = Marker(markerId: markerId, icon: icon ?? defaultIcon, position: position);
    markers[markerId] = marker;
  }

  updateMarker(LatLng latLng, String id) async {
    BitmapDescriptor? icon, defaultIcon;
    MarkerId markerId = const MarkerId("origin");
    driverIcon = await bitmapDescriptorFromSvgAsset(context, "assets/images/svg/delivery_boy.svg");
    defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    icon = driverIcon;
    Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      icon: icon ?? defaultIcon,
    );
    if (mounted) {
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId(widget.id!);
    Polyline polyline = Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());

      poly.add(p);
    }
    return poly;
  }

  Future<List<LatLng>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    List<LatLng> latlnglist = [];
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": 'driving',
      "key": Platform.isIOS ? googleAPiKeyIos : googleAPiKeyAndroid
    };

    Uri uri = Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    // print('GOOGLE MAPS URL: ' + url);
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);

      if (parsedJson["status"]?.toLowerCase() == 'ok' && parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
        latlnglist = decodeEncodedPolyline(parsedJson["routes"][0]["overview_polyline"]["points"]);
      }
    }
    return latlnglist;
  }

  _getPolylineBetweenRestaurantToDeliveryBoy() async {
    try {
      if (orderStatus == deliveredKey) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.home, arguments: {'id': 0});
        });
      }
      List<LatLng> mainroute = [];
      mainroute = await getRouteBetweenCoordinates(LatLng(widget.latitude!, widget.longitude!), LatLng(_originLatitude!, _originLongitude!));

      if (mainroute.isEmpty) {
        mainroute = [];
        mainroute.add(LatLng(widget.latitude!, widget.longitude!));
        mainroute.add(LatLng(_originLatitude!, _originLongitude!));
      }
      polylineId = PolylineId(widget.id!);
      Polyline polyline = Polyline(
          polylineId: polylineId,
          visible: true,
          points: mainroute,
          color: Colors.red,
          //patterns: [PatternItem.dot, PatternItem.gap(10)],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          width: 8);
      polylines[polylineId] = polyline;
      //print(data);
      _addMarker(LatLng(_originLatitude!, _originLongitude!), "origin", 0);
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  _getPolylineBetweenRestaurantToCustomer() async {
    List<LatLng> mainroute = [];
    mainroute = await getRouteBetweenCoordinates(LatLng(widget.latitudeRes!, widget.longitudeRes!), LatLng(widget.latitude!, widget.longitude!));

    if (mainroute.isEmpty) {
      mainroute = [];
      mainroute.add(LatLng(widget.latitudeRes!, widget.longitudeRes!));
      mainroute.add(LatLng(widget.latitude!, widget.longitude!));
    }

    PolylineId polylineId = PolylineId(widget.orderAddress!); //init when order id get that time
    Polyline polyline = Polyline(
        polylineId: polylineId,
        visible: true,
        points: mainroute,
        color: Colors.green,
        //patterns: [PatternItem.dot, PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        width: 8);
    polylines[polylineId] = polyline;

    //
    setState(() {});
  }
}

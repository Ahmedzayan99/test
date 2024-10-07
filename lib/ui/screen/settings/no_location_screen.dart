import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/data/model/addressModel.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/locationDialog.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:project1/utils/internetConnectivity.dart';

class NoLocationScreen extends StatefulWidget {
  const NoLocationScreen({Key? key}) : super(key: key);

  @override
  NoLocationScreenState createState() => NoLocationScreenState();
}

class NoLocationScreenState extends State<NoLocationScreen> {
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  double? width, height;
  //final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: placeSearchApiKey);
  TextEditingController locationSearchController = TextEditingController(text: "");
  String? currentAddress = "";
  late LocatitonGeocoder geocoder = LocatitonGeocoder(placeSearchApiKey);
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    locationSearchController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  locationEnableDialog() async {
    if (context.read<SettingsCubit>().state.settingsModel!.city.toString() == "" &&
        context.read<SettingsCubit>().state.settingsModel!.city.toString() == "null") {
      // Use location.
      getUserLocation();
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return LocationDialog(width: width, height: height);
          });
    }
  }

  getUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if(Platform.isAndroid){
        getUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        locationEnableDialog();
        //getUserLocation();
      } else {
        getUserLocation();
      }
    } else {
      try {
        if (context.read<SystemConfigCubit>().getDemoMode() == "0") {
          demoModeAddressDefault(context, "0");
          context.read<SettingsCubit>().changeShowSkip();
          Navigator.of(context).pushReplacementNamed(Routes.home /* , arguments: {'id': 0} */);
        } else {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       /*  List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: "en"); */
       final placemarks = await geocoder.findAddressesFromCoordinates(Coordinates(position.latitude, position.longitude));
        String? location = "${placemarks.first.addressLine},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.postalCode},${placemarks.first.countryName}";
        //final placemarks = await GeocodingPlatform.instance.placemarkFromCoordinates(position.latitude, position.longitude);
        //String? location = "${placemarks.first.name},${placemarks.first.subLocality},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.country}";//"${placemarks.first.addressLine},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.postalCode},${placemarks.first.countryName}";
        if (await Permission.location.serviceStatus.isEnabled) {
          if (mounted) {
            setState(() async {
              if(context.read<SystemConfigCubit>().getDemoMode()=="0"){
                demoModeAddressDefault(context, "0");
              }else{
              setAddressForDisplayData(context, "0",placemarks.first.locality ?? placemarks.first.subAdminArea!.toString(),position.latitude.toString(),position.longitude.toString(),location.toString().replaceAll(",,", ","));}
              if (context.read<SettingsCubit>().state.settingsModel!.city.toString() != "" &&
                  context.read<SettingsCubit>().state.settingsModel!.city.toString() != "null") {
                if (await Permission.location.serviceStatus.isEnabled) {
                  context.read<SettingsCubit>().changeShowSkip();
                  Navigator.of(context).pushReplacementNamed(Routes.home/* , arguments: {'id': 0} */);
                } else {
                  getUserLocation();
                }
              } else {
                getUserLocation();
              }
            });
          }
        } else {
          getUserLocation();
        }
        }
      } catch (e) {
        getUserLocation();
      }
    }
  }

  getCurrentUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if(Platform.isAndroid){
        getCurrentUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        locationEnableDialog();
        //getUserLocation();
      } else {
        getCurrentUserLocation();
      }
    } else {
      try {
        if (await Permission.location.serviceStatus.isEnabled) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(Routes.address, arguments: {'from': 'location', 'addressModel': AddressModel()});
          }
        } else {
          getCurrentUserLocation();
        }
      } catch (e) {
        getCurrentUserLocation();
      }
    }
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
              body: Container(
                alignment: Alignment.center,
                margin: EdgeInsetsDirectional.only(start: width! / 10.0, end: width! / 10.0),
                width: width,
                child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    SvgPicture.asset(
                      DesignConfig.setSvgPath("location"),
                      height: height! / 3.0,
                      width: height! / 3.0,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(height: height! / 20.0),
                    Text(
                      UiUtils.getTranslatedLabel(context, whoopsLabel),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 26, fontWeight: FontWeight.w700),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 5.0),
                    Text(UiUtils.getTranslatedLabel(context, noLocationSubTitleLabel),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () {
                        //Navigator.of(context).pop();
                        getUserLocation();
                      },
                      child: Container(
                        margin: EdgeInsetsDirectional.only(top: height! / 10.0),
                        padding: EdgeInsetsDirectional.only(top: height! / 70.0, bottom: 10.0, start: width! / 20.0, end: width! / 20.0),
                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed, color: Theme.of(context).colorScheme.onSurface),
                            SizedBox(width: width! / 99.0),
                            Text(UiUtils.getTranslatedLabel(context, enableDeviceLocationLabel),
                                style: const TextStyle(fontSize: 14.0, color: white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        bottomModelSheetShowLocation();
                      },
                      child: Container(
                        margin: EdgeInsetsDirectional.only(top: height! / 40.0),
                        padding: EdgeInsetsDirectional.only(top: height! / 70.0, bottom: 10.0, start: width! / 20.0, end: width! / 20.0),
                        decoration: DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.primary, white, 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(UiUtils.getTranslatedLabel(context, enterLocationAreaCityEtcLabel),
                                style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              )),
    );
  }

  bottomModelSheetShowLocation() {
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                  height: (MediaQuery.of(context).size.height) / 1.14,
                  padding: EdgeInsets.only(top: height! / 15.0),
                  child: Container(
                    decoration: DesignConfig.boxDecorationContainerRoundHalf(white, 25, 0, 25, 0),
                    child: Container(
                      padding: EdgeInsets.only(left: width! / 15.0, right: width! / 15.0, top: height! / 25.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              UiUtils.getTranslatedLabel(context, selectALocationLabel),
                              style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.onSecondary),
                            ),
                            //locationSearchBar(),
                            placesAutoCompleteTextField(),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              minLeadingWidth: 0,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.gps_fixed, color: Theme.of(context).colorScheme.primary),
                              trailing: Icon(Icons.arrow_forward_ios_outlined, color: Theme.of(context).colorScheme.onSecondary, size: 18.0),
                              title: Text(UiUtils.getTranslatedLabel(context, useCurrentLocationLabel),
                                  style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                              subtitle: Padding(
                                padding: const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  currentAddress.toString(),
                                  style: const TextStyle(fontSize: 12, color: lightFontColor),
                                ),
                              ),
                              onTap: () async {
                                getCurrentUserLocation();
                              },
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                              child: const Divider(
                                color: textFieldBorder,
                                height: 0.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
            ],
          );
        });
  }

  placesAutoCompleteTextField() {
    return Container(
      margin: EdgeInsets.only(top: height! / 25.0, bottom: height! / 45.0),
      decoration: DesignConfig.boxDecorationContainerBorder(lightFont, textFieldBackground, 10.0),
      child: GooglePlaceAutoCompleteTextField(
          textEditingController: locationSearchController,
          googleAPIKey: placeSearchApiKey,
          inputDecoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: height! / 62.0),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              hintText: UiUtils.getTranslatedLabel(context, enterLocationAreaCityEtcLabel),
              hintStyle: const TextStyle(fontSize: 12.0, color: lightFont)),
          debounceTime: 600,
          //countries: ["in", "fr"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (p) async {
  /*          // PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
            // if (mounted) {
            //   setState(() {
            //
            //     String infoAddress = "";
            //     for (var info in detail.result.addressComponents) {
            //       List types = info.types;
            //       if (infoAddress.trim().isEmpty && types.contains('locality') && info.longName.trim().isNotEmpty) {
            //         infoAddress = info.longName.trim();
            //         break;
            //       }
            //       if (infoAddress.trim().isEmpty && types.contains('administrative_area_level_1') && info.longName.trim().isNotEmpty) {
            //         infoAddress = info.longName.trim();
            //         break;
            //       }
            //       if (infoAddress.trim().isEmpty && types.contains('administrative_area_level_2') && info.longName.trim().isNotEmpty) {
            //         infoAddress = info.longName.trim();
            //         break;
            //       }
            //     }
            //         if(context.read<SystemConfigCubit>().getDemoMode()=="0"){
            //         demoModeAddressDefault(context, "1");
            //   }else{
            //     setAddressForDisplayData(context, "1", infoAddress.toString(),detail.result.geometry!.location.lat.toString(),detail.result.geometry!.location.lng.toString(),detail.result.formattedAddress!.toString());}
            //   });
            // }*/
          },
          itemClick: (p) async {
       /*     locationSearchController.text = p.description!;
            PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
            if (mounted) {
              setState(() {
                
                String infoAddress = "";
                for (var info in detail.result.addressComponents) {
                  List types = info.types;
                  if (infoAddress.trim().isEmpty && types.contains('locality') && info.longName.trim().isNotEmpty) {
                    infoAddress = info.longName.trim();
                    break;
                  }
                  if (infoAddress.trim().isEmpty && types.contains('administrative_area_level_1') && info.longName.trim().isNotEmpty) {
                    infoAddress = info.longName.trim();
                    break;
                  }
                  if (infoAddress.trim().isEmpty && types.contains('administrative_area_level_2') && info.longName.trim().isNotEmpty) {
                    infoAddress = info.longName.trim();
                    break;
                  }
                }
                    if(context.read<SystemConfigCubit>().getDemoMode()=="0"){
                    demoModeAddressDefault(context, "1");
              }else{
                setAddressForDisplayData(context, "1", infoAddress.toString(),detail.result.geometry!.location.lat.toString(),detail.result.geometry!.location.lng.toString(),detail.result.formattedAddress!.toString());}
                Navigator.pop(context);
                context.read<SettingsCubit>().changeShowSkip();
                Future.delayed(Duration.zero, () {
                  Navigator.of(context).pushReplacementNamed(Routes.home*//* , arguments: {'id': 0} *//*);
                });
              });
            }
            locationSearchController.selection = TextSelection.fromPosition(TextPosition(offset: p.description!.length));
       */   },
          textStyle: const TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w400)),
    );
  }
}

/*
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_svg/svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  MaintenanceScreenState createState() => MaintenanceScreenState();
}

class MaintenanceScreenState extends State<MaintenanceScreen> {
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
*/
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*//*

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: */
/*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*//*
 Scaffold(
              body: Container(
                margin: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0 */
/*, top: height/5.0*//*
),
                width: width,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    UiUtils.getTranslatedLabel(context, maintenanceLabel),
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 30, fontWeight: FontWeight.w700),
                    maxLines: 2,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0, top: 8.0, bottom: height / 14.0),
                    child: Text(UiUtils.getTranslatedLabel(context, maintenanceSubTitleLabel),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  SvgPicture.asset(DesignConfig.setSvgPath("maintainance")),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: width / 10.0, end: width / 10.0, top: height / 14.0),
                    child: Text(UiUtils.getTranslatedLabel(context, weAreStillWorkingOnThisLabel),
                        textAlign: TextAlign.center, style: const TextStyle(color: black, fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: width / 10.0, end: width / 10.0, top: 11.0),
                    child: Text(UiUtils.getTranslatedLabel(context, thankYouForYourUnderstandingLabel),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ]),
              )),
    );
  }
}
*/

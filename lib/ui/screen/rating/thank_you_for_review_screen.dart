import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class ThankYouForReviewScreen extends StatefulWidget {
  const ThankYouForReviewScreen({Key? key}) : super(key: key);

  @override
  ThankYouForReviewScreenState createState() => ThankYouForReviewScreenState();
}

class ThankYouForReviewScreenState extends State<ThankYouForReviewScreen> {
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    navigationPage();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  navigationPage() async {
    await Future.delayed(const Duration(seconds: 2), () { Navigator.pop(context); Navigator.pop(context);});
    // await Future.delayed(const Duration(seconds: 2), () => Navigator.of(context).popUntil((route) => route.isFirst));
    //await Future.delayed(const Duration(seconds: 2), () => Navigator.of(context).pushReplacementNamed(Routes.home, arguments: {'id': 0}));
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
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
              body: Container(
                alignment: Alignment.center,
                margin: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0),
                width: width,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("review_msg")),
                  SizedBox(height: height / 20.0),
                  Text(UiUtils.getTranslatedLabel(context, thankYouLabel),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                  const SizedBox(height: 5.0),
                  Text(UiUtils.getTranslatedLabel(context, forYourReviewLabel),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                ]),
              )),
    );
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/systemConfig/appSettingsCubit.dart';
import 'package:project1/data/repositories/systemConfig/systemConfigRepository.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/dom.dart' as dom;

import 'package:project1/utils/internetConnectivity.dart';
import 'no_internet_screen.dart';

class ServiceScreen extends StatefulWidget {
  final String? title;
  const ServiceScreen({Key? key, required this.title}) : super(key: key);

  @override
  ServiceScreenState createState() => ServiceScreenState();
  static Route<ServiceScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<AppSettingsCubit>(
              create: (_) => AppSettingsCubit(
                SystemConfigRepository(),
              ),
              child: ServiceScreen(title: routeSettings.arguments as String),
            ));
  }
}

class ServiceScreenState extends State<ServiceScreen> {
  late WebViewController webViewController;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String getType() {
    if (widget.title == aboutUsKey) {
      return "about_us";
    }
    if (widget.title == privacyPolicyKey) {
      return "privacy_policy";
    }
    if (widget.title == termsAndConditionsKey) {
      return "terms_conditions";
    }
    if (widget.title == contactUsKey) {
      return "contact_us";
    }

    print(widget.title);
    return "";
  }

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
    getAppSetting();
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  void getAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(getType());
    });
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
              appBar: DesignConfig.appBar(context, width, widget.title!, const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: Container(
                  margin: EdgeInsetsDirectional.only(top: height / 80.0),
                  decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                  width: width,
                  child: Container(height: height,
                      margin: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0, top: height / 20.0),
                      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
                        bloc: context.read<AppSettingsCubit>(),
                        builder: (context, state) {
                          if (state is AppSettingsFetchInProgress || state is AppSettingsIntial) {
                            return Center(
                              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                            );
                          }
                          if (state is AppSettingsFetchFailure) {
                            Container(
                              alignment: Alignment.center,
                              child: Center(
                                  child: Text(
                                state.errorCode.toString(),
                                textAlign: TextAlign.center,
                              )),
                            );
                          }
                          return SingleChildScrollView(
                            child: Container()/*Html(
                              data: (state as AppSettingsFetchSuccess).settingsData,
                              onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) async {
                                if (await canLaunchUrlString(url!)) {
                                  await launchUrlString(
                                    url,mode: LaunchMode.externalApplication
                                    *//*forceSafariVC: false,
                                    forceWebView: false,*//*
                                  );
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            ),*/
                          );
                        },
                      )))),
    );
  }
}

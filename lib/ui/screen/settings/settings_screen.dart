import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/screen/settings/refer_and_earn_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/LanguageDialog.dart';
import 'package:project1/ui/widgets/customDialog.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';

import 'package:project1/utils/internetConnectivity.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool notificationSwitch = true, appNotificationSwitch = false, tLogin = true, fLogin = false, gLogin = true;
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
 /*   _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Widget line() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: height! / 80.0, bottom: height! / 80.0),
      child: Divider(
        color: lightFont.withOpacity(0.50),
        height: 1.0,
      ),
    );
  }

  Widget aboutUsData() {
    return arrowTile(
        image: "pro_aboutus",
        name: UiUtils.getTranslatedLabel(context, aboutUsLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: aboutUsKey);
        });
  }

  Widget contactUsData() {
    return arrowTile(
        image: "pro_contact_us",
        name: UiUtils.getTranslatedLabel(context, contactUsLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: contactUsKey);
        });
  }

  Widget helpAndSupport() {
    return arrowTile(
        image: "pro_customersupport",
        name: UiUtils.getTranslatedLabel(context, helpAndSupportLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.ticket);
        });
  }

  Widget termAndCondition() {
    return arrowTile(
        image: "pro_tc",
        name: UiUtils.getTranslatedLabel(context, termAndConditionLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditionsKey);
        });
  }

  Widget privacyPolicyData() {
    return arrowTile(
        image: "pro_pp",
        name: UiUtils.getTranslatedLabel(context, privacyPolicyLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
        });
  }

  Widget transactionData(AuthState state) {
    return arrowTile(
        image: "pro_th",
        name: UiUtils.getTranslatedLabel(context, transactionLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'transaction'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            Navigator.of(context).pushNamed(Routes.transaction);
          }
        });
  }

  Widget walletData(AuthState state) {
    return arrowTile(
        image: "pro_wh",
        name: UiUtils.getTranslatedLabel(context, walletLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'wallet'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            Navigator.of(context).pushNamed(Routes.wallet);
          }
        });
  }

  Widget faqs() {
    return arrowTile(
        image: "pro_faq",
        name: UiUtils.getTranslatedLabel(context, faqsLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.faqs);
        });
  }

  Widget referAndEarn(AuthState state) {
    return arrowTile(
        image: "pro_earn",
        name: UiUtils.getTranslatedLabel(context, referralAndEarnCodeLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'referAndEarn'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const ReferAndEarnScreen(),
              ),
            );
          }
        });
  }

  Widget deleteYourAccount(AuthState state) {
    return arrowTile(
        image: "pro_delete",
        name: UiUtils.getTranslatedLabel(context, deleteYourAccountLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'deleteYourAccount'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                      title: UiUtils.getTranslatedLabel(context, deleteYourAccountLabel),
                      subtitle: UiUtils.getTranslatedLabel(context, deleteYourAccountSubTitleLabel),
                      width: width!,
                      height: height!,
                      from: UiUtils.getTranslatedLabel(context, deleteLabel));
                });
          }
        });
  }

  Widget rateUs() {
    return arrowTile(
        image: "pro_rateus",
        name: UiUtils.getTranslatedLabel(context, rateUsLabel),
        onPressed: () {
      /*    LaunchReview.launch(
            androidAppId: packageName,
            iOSAppId: "585027354",
          );*/
        });
  }

 Widget languageChange() {
    return arrowTile(
        image: "pro_translate",
        name: UiUtils.getTranslatedLabel(context, languageChangeLabel),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return LanguageChangeDialog(
                    title: UiUtils.getTranslatedLabel(context, languageChangeLabel),
                    subtitle: UiUtils.getTranslatedLabel(context, areYouSureYouWantToLogoutLabel),
                    width: width!,
                    height: height!,
                    from: UiUtils.getTranslatedLabel(context, logoutLabel));
              });
        });
  }



  Widget share() {
    return arrowTile(
        image: "pro_share",
        name: UiUtils.getTranslatedLabel(context, shareLabel),
        onPressed: () {
          try {
            Share.share("$appName\n${context.read<SystemConfigCubit>().getAppLink()}\n");
          } catch (e) {
            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, shareLabel), e.toString(), context, false, type: "2");
          }
        });
  }

  Widget switchTile(String name, bool switchData) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14, color: lightFont, fontWeight: FontWeight.w600),
      ),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.7,
        child: CupertinoSwitch(
          activeColor: Theme.of(context).colorScheme.onSecondary,
          value: context.read<SettingsCubit>().getSettings().notification,
          onChanged: (value) {
            setState(() {
              context.read<SettingsCubit>().changeNotification(value);
            });
          },
        ),
      ),
    );
  }

  Widget titleName(String image, String name) {
    return Container(
      padding: EdgeInsetsDirectional.only(top: height! / 90.0),
      child: Row(
        children: [
          SvgPicture.asset(image),
          const SizedBox(
            width: 5,
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget arrowTile({String? name, VoidCallback? onPressed, String? image}) {
    return GestureDetector(
      onTap: onPressed,
      child:  Container(decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0), padding: const EdgeInsetsDirectional.all(10.0),margin: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0, start: width!/60.0, end: width!/60.0),
        child: ListTile(
            leading: CircleAvatar(
              radius: 18.0,
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              child: SvgPicture.asset(DesignConfig.setSvgPath(image!), width: 16.0, height: 16.0),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            title: Text(
              name!,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
                onPressed: onPressed,
                padding: EdgeInsetsDirectional.only(start: height! / 40.0),
                icon: Icon(Icons.arrow_forward_ios, size: 15, color: Theme.of(context).colorScheme.onSecondary))),
      ),
    );
  }

  @override
  void dispose() {
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, settingsLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              /* bottomNavigationBar: Container(
                color: Colors.transparent,
                height: (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                    ? height! / 40.0
                    : height! / 8.0,
                child: Column(
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                      return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                          ? const SizedBox()
                          : TextButton(
                              style: ButtonStyle(
                                overlayColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                          title: StringsRes.logout,
                                          subtitle: StringsRes.areYouSureYouWantToLogout,
                                          width: width!,
                                          height: height!,
                                          from: StringsRes.logout);
                                    });
                              },
                              child: Container(
                                  margin: EdgeInsetsDirectional.only(/*start: width! / 4.0, end: width! / 4.0, */ bottom: height! / 99.0),
                                  width: width! / 2.0,
                                  padding: EdgeInsetsDirectional.only(
                                      top: height! / 99.0, bottom: height! / 99.0, start: width! / 20.0, end: width! / 20.0),
                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSecondary, 100.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.power_settings_new, color: ColorsRes.white),
                                      SizedBox(width: width! / 60.0),
                                      Text(StringsRes.logout,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)),
                                    ],
                                  )));
                    }),
                    Platform.isIOS
                        ? Text("${StringsRes.appVersion} ${context.read<SystemConfigCubit>().getCurrentVersionIos()}",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(color: ColorsRes.darkGrey, fontSize: 10, fontWeight: FontWeight.w500))
                        : Text(StringsRes.appVersion + context.read<SystemConfigCubit>().getCurrentVersionAndroid(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(color: ColorsRes.darkGrey, fontSize: 10, fontWeight: FontWeight.w500)),
                  ],
                ),
              ), */
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                width: width,
                child: Container(
                  margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
                  child: SingleChildScrollView(
                    child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                      return Column(
                        children: [
                          languageChange(),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              : deleteYourAccount(state),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              :const SizedBox(),
                              //: line(),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              : transactionData(state),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              :const SizedBox(),
                              //: line(),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              : walletData(state),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              :const SizedBox(),
                              //: line(),
                          aboutUsData(),
                          //line(),
                          contactUsData(),
                          //line(),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              : helpAndSupport(),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              :const SizedBox(),
                              //: line(),
                          termAndCondition(),
                          //line(),
                          privacyPolicyData(),
                          //line(),
                          faqs(),
                          //line(),
                          rateUs(),
                          //line(),
                          share(),
                          //line(),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              : referAndEarn(state),
                          (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                              ? const SizedBox()
                              :const SizedBox(),
                              //: line(),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/auth/referAndEarnCubit.dart';
import 'package:project1/cubit/auth/socialSignUpCubit.dart';
import 'package:project1/cubit/auth/verifyUserCubit.dart';
import 'package:project1/cubit/cart/manageCartCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/screen/auth/otp_verify_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/screen/settings/no_location_screen.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/buttomWithImageContainer.dart';
import 'package:project1/ui/widgets/keyboardOverlay.dart';
import 'package:project1/ui/widgets/locationDialog.dart';
import 'package:project1/utils/SqliteData.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';

import 'package:geolocator/geolocator.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:project1/utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class LoginScreen extends StatefulWidget {
  final String? from;
  const LoginScreen({Key? key, this.from}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
  static Route<LoginScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => LoginScreen(
        from: arguments['from'] as String,
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  late double width, height;
  TextEditingController phoneNumberController = TextEditingController(text: "9999999999");
  TextEditingController passwordController = TextEditingController(text: "");
  String? countryCode = defaulCountryCode;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  bool obscure = true, status = false, iAccept = Platform.isAndroid ? false : true, skipStatus = false, loginStatus = false;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  var db = DatabaseHelper();
  Random rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  String referCode = "", socialLoginType = "";
  late LocatitonGeocoder geocoder = LocatitonGeocoder(placeSearchApiKey);
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
    referCode = getRandomString(8);
    print("from:${widget.from}");
    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    numberFocusNode.dispose();
    numberFocusNodeAndroid.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  locationEnableDialog() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return LocationDialog(width: width, height: height, from: "skip");
        });
  }

  getUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        getUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        locationEnableDialog();
        setState((){skipStatus = false;});
        
        //getUserLocation();
      } else {
        getUserLocation();
      }
    } else {
      try {
        if (context.read<SystemConfigCubit>().getDemoMode() == "0") {
          demoModeAddressDefault(context, "0");
          skipStatus = true;
          context.read<SettingsCubit>().changeShowSkip();
          await Future.delayed(Duration.zero,
              () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false /* , arguments: {'id': 0} */));
        } else {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          /* List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude,
            localeIdentifier: "en"); */
          final placemarks = await geocoder.findAddressesFromCoordinates(Coordinates(position.latitude, position.longitude));
          String? location =
              "${placemarks.first.addressLine},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.postalCode},${placemarks.first.countryName}";
          //final placemarks = await GeocodingPlatform.instance.placemarkFromCoordinates(position.latitude, position.longitude);
          //String? location = "${placemarks.first.name},${placemarks.first.subLocality},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.country}";
          if (await Permission.location.serviceStatus.isEnabled) {
            if (mounted) {
              setState(() async {
                if (context.read<SystemConfigCubit>().getDemoMode() == "0") {
                  demoModeAddressDefault(context, "0");
                } else {
                  setAddressForDisplayData(context, "0", placemarks.first.locality ?? placemarks.first.subAdminArea!.toString(),
                      position.latitude.toString(), position.longitude.toString(), location.toString().replaceAll(",,", ","));
                }
                if (context.read<SettingsCubit>().state.settingsModel!.city.toString() != "" &&
                    context.read<SettingsCubit>().state.settingsModel!.city.toString() != "null") {
                  if (await Permission.location.serviceStatus.isEnabled) {
                    skipStatus = true;
                    context.read<SettingsCubit>().changeShowSkip();
                    await Future.delayed(
                        Duration.zero,
                        () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false /* , arguments: {'id': 0} */));
                  } else {
                    getUserLocation();
                    skipStatus = false;
                  }
                } else {
                  getUserLocation();
                  skipStatus = false;
                }
              });
            }
          } else {
            if (widget.from == "splash") {
              getUserLocation();
              skipStatus = false;
            } else {}
          }
        }
      } catch (e) {
        if (widget.from == "splash") {
          getUserLocation();
          setState(() {
            skipStatus = false;
          });
        } else {
          setState(() {
            skipStatus = true;
          });
          context.read<SettingsCubit>().changeShowSkip();
          await Future.delayed(Duration.zero,
              () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false /* , arguments: {'id': 0} */));
        }
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();

    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        if (!mounted) return;
        context.read<ManageCartCubit>().manageCartUser(
            userId: context.read<AuthCubit>().getId(),
            productVariantId: cartOffList[i]["VID"],
            isSavedForLater: "0",
            qty: cartOffList[i]["QTY"],
            addOnId: cartOffList[i]["ADDONID"].isNotEmpty ? cartOffList[i]["ADDONID"] : "",
            addOnQty: cartOffList[i]["ADDONQTY"].isNotEmpty ? cartOffList[i]["ADDONQTY"] : "");
      }
    }
  }

  navigationPageHome() async {
    if (widget.from == "splash") {
      if (context.read<SettingsCubit>().state.settingsModel!.city.toString() != "" &&
          context.read<SettingsCubit>().state.settingsModel!.city.toString() != "null") {
        await Future.delayed(Duration.zero, () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false));
      } else {
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => const NoLocationScreen(),
            ),
            (Route<dynamic> route) => false);
      }
    } else if (widget.from == "logout" || widget.from == "delete") {
      await Future.delayed(Duration.zero, () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false));
    } else {
      await Future.delayed(
        const Duration(seconds: 1),
      );
      if (!mounted) return;

      Navigator.of(context).pop();
    }
  }

  Widget socialLogin() {
    return BlocConsumer<ReferAndEarnCubit, ReferAndEarnState>(
        bloc: context.read<ReferAndEarnCubit>(),
        listener: (context, state) async {
          //Exceuting only if authProvider is email
          if (state is ReferAndEarnFailure) {
            print(state.errorCode);
            UiUtils.setSnackBar(StringsRes.singleRestaurantAddMessage, state.errorCode, context, false, type: "2");
          }
          if (state is ReferAndEarnSuccess) {
            print("success");
            if (socialLoginType == "apple") {
              // context.read<SocialSignUpCubit>().socialSocialSignUpUser(authProvider: AuthProviders.apple, friendCode: "", referCode: referCode);
            } else if (socialLoginType == "facebook") {
              // context.read<SocialSignUpCubit>().socialSocialSignUpUser(authProvider: AuthProviders.facebook, friendCode: "", referCode: referCode);
            } else if (socialLoginType == "google") {
              // context.read<SocialSignUpCubit>().socialSocialSignUpUser(authProvider: AuthProviders.google, friendCode: "", referCode: referCode);
            }
          }
        },
        builder: (context, state) {
          return BlocConsumer<SocialSignUpCubit, SocialSignUpState>(
            bloc: context.read<SocialSignUpCubit>(),
            listener: (context, state) async {
              //Exceuting only if authProvider is email
              if (state is SocialSignUpFailure) {
                //print(state.errorMessage);
                if (state.errorMessage == defaultErrorMessage) {
                } else {
                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, loginLabel), state.errorMessage, context, false, type: "2");
                }
              }
              if (state is SocialSignUpSuccess) {
                context.read<AuthCubit>().statusUpdateAuth(state.authModel);
                offCartAdd().then((value) {
                  db.clearCart();
                  navigationPageHome();
                });
              }
            },
            builder: (context, state) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Platform.isIOS
                    ? SizedBox(
                        width: width,
                        child: ButtonImageContainer(
                            color: Theme.of(context).colorScheme.onSecondary,
                            height: height,
                            width: width,
                            text: UiUtils.getTranslatedLabel(context, continueWithAppleLabel),
                            bottom: 0,
                            start: width / 30.0,
                            end: height / 50.0,
                            top: height / 40.0,
                            status: status,
                            borderColor: Theme.of(context).colorScheme.onSecondary,
                            textColor: white,
                            onPressed: () {
                              if (iAccept == true) {
                                context.read<ReferAndEarnCubit>().fetchReferAndEarn(referCode);
                                status = false;
                                socialLoginType = "apple";
                              } else {
                                UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, acceptTermConditionLabel),
                                    StringsRes.pleaseAcceptTermCondition, context, false,
                                    type: "2");
                              }
                            },
                            widget: SvgPicture.asset(DesignConfig.setSvgPath("apple"))),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: width,
                  child: ButtonImageContainer(
                      color: facebookColor,
                      height: height,
                      width: width,
                      text: UiUtils.getTranslatedLabel(context, continueWithFacebookLabel),
                      bottom: 0,
                      start: width / 30.0,
                      end: height / 50.0,
                      top: height / 40.0,
                      status: status,
                      borderColor: facebookColor,
                      textColor: white,
                      onPressed: () {
                        if (iAccept == true) {
                          context.read<ReferAndEarnCubit>().fetchReferAndEarn(referCode);
                          status = false;
                          setState(() {
                            socialLoginType = "facebook";
                          });
                        } else {
                          UiUtils.setSnackBar(
                              UiUtils.getTranslatedLabel(context, acceptTermConditionLabel), StringsRes.pleaseAcceptTermCondition, context, false,
                              type: "2");
                        }
                      },
                      widget: SvgPicture.asset(DesignConfig.setSvgPath("facebook"))),
                ),
                SizedBox(
                  width: width,
                  child: ButtonImageContainer(
                      color: Theme.of(context).colorScheme.error,
                      height: height,
                      width: width,
                      text: UiUtils.getTranslatedLabel(context, continueWithGoogleLabel),
                      bottom: 0,
                      start: width / 30.0,
                      end: height / 50.0,
                      top: height / 40.0,
                      status: status,
                      borderColor: Theme.of(context).colorScheme.error,
                      textColor: white,
                      onPressed: () {
                        if (iAccept == true) {
                          context.read<ReferAndEarnCubit>().fetchReferAndEarn(referCode);
                          status = false;
                          setState(() {
                            socialLoginType = "google";
                          });
                        } else {
                          UiUtils.setSnackBar(
                              UiUtils.getTranslatedLabel(context, acceptTermConditionLabel), StringsRes.pleaseAcceptTermCondition, context, false,
                              type: "2");
                        }
                      },
                      widget: SvgPicture.asset(DesignConfig.setSvgPath("google"))),
                ),
              ]);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: /*/*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/*/ Scaffold(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              key: scaffoldKey,
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: greayLightColor,
                      ),
                      child: Checkbox(
                          value: iAccept,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) {
                            setState(() {
                              iAccept = val!;
                            });
                          },
                          checkColor: Theme.of(context).colorScheme.onSurface,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4)),
                    ),
                    Text(
                      UiUtils.getTranslatedLabel(context, byClickingYouAgreeToOurLabel),
                      style: const TextStyle(color: greayLightColor, fontSize: 12.0),
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditionsKey);
                      },
                      child: Text(
                        "  ${UiUtils.getTranslatedLabel(context, termAndConditionLabel)}",
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      " ${UiUtils.getTranslatedLabel(context, andLabel)} ",
                      style: const TextStyle(color: greayLightColor, fontSize: 12.0, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
                      },
                      child: Text(
                        UiUtils.getTranslatedLabel(context, privacyPolicyLabel),
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              body: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                slivers: [
                  SliverAppBar(
                      expandedHeight: height / 3.2,
                      shadowColor: Colors.transparent,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      automaticallyImplyLeading: false,
                      iconTheme: IconThemeData(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      floating: false,
                      pinned: true,
                      title: Text(UiUtils.getTranslatedLabel(context, loginLabel),
                          style: const TextStyle(fontSize: 18.0, color: white, fontWeight: FontWeight.w500)),
                      actions: [
                        skipStatus == true
                            ? Padding(
                              padding: EdgeInsetsDirectional.only(end: width / 40.0, top: height / 99.0, bottom: height / 99.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    // margin: EdgeInsetsDirectional.only(end: width/40.0, top: height/99.0, bottom: height/99.0),
                                    padding: const EdgeInsets.all(2.5),
                                    //width: 42,
                                    //height: 10,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(5)), color: const Color(0xff000000).withOpacity(0.50)),
                                    child: Center(
                                      child: ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          white,
                                          BlendMode.srcIn,
                                        ),
                                        child: Lottie.asset(DesignConfig.setLottiePath("addressProgress"))),
                                  ),
                                ),
                              )
                              ),
                            ): Padding(
                          padding: EdgeInsetsDirectional.only(end: width / 20.0, bottom: height / 80.0, top: height / 80.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                      skipStatus = true;
                              });
                              getUserLocation();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  padding: const EdgeInsets.all(2.5),
                                  width: 42,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(5)), color: const Color(0xff000000).withOpacity(0.50)),
                                  child: Center(
                                    child: Text(
                                      UiUtils.getTranslatedLabel(context, skipLabel),
                                      style: const TextStyle(color: white, fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                      //automaticallyImplyLeading: _isVisible,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: false,
                        background: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [shaderColor, black],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.darken,
                              child: DesignConfig.imageWidgets('login_banner', height / 3.2, width, "1")),
                        ),
                      )),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      //SvgPicture.asset(DesignConfig.setSvgPath("logo_white")),
                      SizedBox(height: height / 20.0),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width / 20.0, end: height / 40.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            UiUtils.getTranslatedLabel(context, weWillSendAVerificationCodeToThisNumberLabel),
                            style: const TextStyle(
                                decoration: TextDecoration.none, color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(height: height / 40.0),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width / 20.0, end: height / 40.0),
                        child: IntlPhoneField(
                          controller: phoneNumberController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textInputAction: TextInputAction.done,
                          dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
                            focusedBorder: DesignConfig.outlineInputBorder(Theme.of(context).colorScheme.onSurface, 10.0),
                            focusedErrorBorder: DesignConfig.outlineInputBorder(Theme.of(context).colorScheme.onSurface, 10.0),
                            errorBorder: DesignConfig.outlineInputBorder(Theme.of(context).colorScheme.onSurface, 10.0),
                            enabledBorder: DesignConfig.outlineInputBorder(Theme.of(context).colorScheme.onSurface, 10.0),
                            focusColor: white,
                            counterStyle: const TextStyle(color: white, fontSize: 0),
                            border: InputBorder.none,
                            hintText: UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
                            labelStyle: const TextStyle(
                              color: lightFont,
                              fontSize: 17.0,
                            ),
                            hintStyle: const TextStyle(
                              color: black,
                              fontSize: 17.0,
                            ),
                            //contentPadding: EdgeInsets.zero,
                          ),
                          flagsButtonMargin: EdgeInsets.all(width / 40.0),
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
                          dropdownIconPosition: IconPosition.trailing,
                          initialCountryCode: defaulIsoCountryCode,
                          style: const TextStyle(
                            color: black,
                            fontSize: 17.0,
                          ),
                          textAlign: Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
                          onChanged: (phone) {
                            setState(() {
                              //print(phone.completeNumber);
                              countryCode = phone.countryCode;
                            });
                          },
                        ),
                      ),
                      BlocListener<VerifyUserCubit, VerifyUserState>(
                        listener: (context, state) {
                          if(state is VerifyUserSuccess){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => OtpVerifyScreen(
                                        mobileNumber: phoneNumberController.text,
                                        countryCode: countryCode,
                                        from: widget.from,
                                        type: "sms"
                                      ),
                                    ),
                                  ).then((value) {
                                    setState((){
                                      loginStatus = false;
                                    });
                                  });
                                  status = false;}
                                  if(state is VerifyUserFailure){
                                    UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, phoneNumberLabel),
                                      state.errorMessage, context, false,
                                      type: "2");
                                  }
                        },
                        child: SizedBox(
                          width: width,
                          child: ButtonContainer(
                            color: Theme.of(context).colorScheme.primary,
                            height: height,
                            width: width,
                            text: UiUtils.getTranslatedLabel(context, loginLabel),
                            bottom: height / 40.0,
                            start: width / 30.0,
                            end: height / 50.0,
                            top: height / 80.0,
                            status: loginStatus,
                            borderColor: Theme.of(context).colorScheme.primary,
                            textColor: white,
                            onPressed: () {
                              if (iAccept == true) {
                                /*if (phoneNumberController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                                              context.read<SignInCubit>().signInUser(mobile: phoneNumberController.text, password: passwordController.text);
                                                              status = true;
                                                            } else {*/
                                if (phoneNumberController.text.isEmpty) {
                                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, phoneNumberLabel),
                                      UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel), context, false,
                                      type: "2");
                                  status = false;
                                } else {
                                  if(loginStatus==false) {
                                  if(context.read<SystemConfigCubit>().getAuthenticationMethod() == "0"){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => OtpVerifyScreen(
                                        mobileNumber: phoneNumberController.text,
                                        countryCode: countryCode,
                                        from: widget.from,
                                        type: "firebase"
                                      ),
                                    ),
                                  ).then((value) {
                                    setState((){
                                      loginStatus = false;
                                    });
                                  });
                                  status = false;
                                  }else{
                                    context.read<VerifyUserCubit>().verifyUser(mobile: phoneNumberController.text);
                                  }
                                  setState(() {
                                      loginStatus = true;
                                  });
                                  }
                                }
                                /*}*/
                              } else {
                                UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, acceptTermConditionLabel),
                                    StringsRes.pleaseAcceptTermCondition, context, false,
                                    type: "2");
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0),
                        child: Row(children: [
                          Expanded(child: DesignConfig.divider()),
                          SizedBox(width: width / 40.0),
                          Text(
                            UiUtils.getTranslatedLabel(context, orLabel),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(width: width / 40.0),
                          Expanded(child: DesignConfig.divider()),
                        ]),
                      ),
                      socialLogin(),
                    ]),
                  ),
                ],
              )),
    );
  }
}

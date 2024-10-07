import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/resendOtpCubit.dart';
import 'package:project1/cubit/auth/verifyOtpCubit.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/auth/signInCubit.dart';
import 'package:project1/cubit/auth/signUpCubit.dart';
import 'package:project1/data/model/cartModel.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/cart/manageCartCubit.dart';
import 'package:project1/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/utils/SqliteData.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/screen/auth/resendOtpTimerContainer.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/screen/settings/no_location_screen.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:project1/utils/internetConnectivity.dart';

const int otpTimeOutSeconds = 60;

class OtpVerifyScreen extends StatefulWidget {
  final String? countryCode, mobileNumber, from, type;
  const OtpVerifyScreen({Key? key, this.countryCode, this.mobileNumber, this.from, this.type}) : super(key: key);

  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SignUpCubit>(
              create: (_) => SignUpCubit(AuthRepository()),
              child: OtpVerifyScreen(
                  mobileNumber: arguments['mobileNumber'] as String,
                  countryCode: arguments['countryCode'] as String,
                  from: arguments['from'] as String,
                  type: arguments['type'] as String),
            ));
  }
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> with SingleTickerProviderStateMixin {
  double? width, height;
  String mobile = "", _verificationId = "", otp = "", signature = "";
  bool _isClickable = false, isCodeSent = false, isloading = false, isErrorOtp = false;
  late TextEditingController controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late AnimationController buttonController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool enableResendOtpButton = false;
  bool codeSent = false;
  final GlobalKey<ResendOtpTimerContainerState> resendOtpTimerContainerKey = GlobalKey<ResendOtpTimerContainerState>();
  String? _message = '';
  var db = DatabaseHelper();
  int forceResendingToken = 0;

  void signInWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        timeout: const Duration(seconds: otpTimeOutSeconds),
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        verificationCompleted: (PhoneAuthCredential credential) {
          print("Phone number verified");
          _message = credential.smsCode ?? "";
          controller.text = _message!;
          otp = _message!;
          if (controller.text.isEmpty) {
            otpMobile(controller.text);
          } else {
            _onFormSubmitted();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          //if otp code does not verify
          print("Firebase Auth error------------");
          print(e.message);
          print("---------------------");
          UiUtils.setSnackBar("", e.toString(), context, false, type: "2");

          setState(() {
            isloading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          if (resendToken != null) {
            forceResendingToken = resendToken;
          }
          print("Code sent successfully");
          setState(() {
            codeSent = true;
            _verificationId = verificationId;
            isloading = false;
          });

          Future.delayed(const Duration(milliseconds: 75)).then((value) {
            resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("verificationId:$verificationId");
        },
        forceResendingToken: forceResendingToken);
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();
    //String? partnerId;
    if (!mounted) return;
    CartModel cartList = context.read<GetCartCubit>().getCartModel();
    print(cartList.toString());
    /* if (cartList.data != null) {
      partnerId = cartList.data![0].productDetails![0].partnerId!;
    } */
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        /*print(partnerId!.toString() +
            "-" +
            cartOffList[i]["VID"].toString() +
            "-" +
            cartOffList[i]["RESTAURANTID"].toString() +
            "-" +
            cartOffList[i]["QTY"].toString());*/
        //if (partnerId == cartOffList[i]["RESTAURANTID"] || cartList.data != null) {
        context.read<ManageCartCubit>().manageCartUser(
            userId: context.read<AuthCubit>().getId(),
            productVariantId: cartOffList[i]["VID"],
            isSavedForLater: "0",
            qty: cartOffList[i]["QTY"],
            addOnId: cartOffList[i]["ADDONID"].isNotEmpty ? cartOffList[i]["ADDONID"] : "",
            addOnQty: cartOffList[i]["ADDONQTY"].isNotEmpty ? cartOffList[i]["ADDONQTY"] : "");
        //} else {}
      }
    }
  }

  Widget _buildResendText() {
    return BlocListener<ResendOtpCubit, ResendOtpState>(
      listener: (context, state) {
        if(state is ResendOtpFailure){
          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, resendOtpLabel), state.errorMessage, context, false, type: '2');
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResendOtpTimerContainer(
              key: resendOtpTimerContainerKey,
              enableResendOtpButton: () {
                setState(() {
                  enableResendOtpButton = true;
                });
              }),
          enableResendOtpButton
              ? TextButton(
                  style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                  onPressed: enableResendOtpButton
                      ? () async {
                          print("Resend otp ");
                          setState(() {
                            isloading = false;
                            enableResendOtpButton = false;
                          });
                          resendOtpTimerContainerKey.currentState?.cancelOtpTimer();
                          if (widget.type == "firebase") {
                            signInWithPhoneNumber();
                          } else {
                            context.read<ResendOtpCubit>().resentOtp(mobile: widget.mobileNumber);

                            Future.delayed(const Duration(milliseconds: 75)).then((value) {
                              resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
                            });
                          }
                        }
                      : null,
                  child: Text(
                    UiUtils.getTranslatedLabel(context, resendOtpLabel),
                    style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  bool otpMobile(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        isErrorOtp = true;
      });
      return false;
    }
    return false;
  }

  static Future<bool> checkNet() async {
    bool check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      check = true;
    }
    return check;
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
    print("type: ${widget.type}");
    if (widget.type == "firebase") {
      if (widget.mobileNumber == "9999999999") {
        controller = TextEditingController(text: "123456");
        otp = "123456";
      }
      print("widget${widget.mobileNumber}");
      getSignature();
      signInWithPhoneNumber();
    } else {
      codeSent = true;

      Future.delayed(const Duration(milliseconds: 75)).then((value) {
        resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
      });
    }
    Future.delayed(const Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    buttonController.dispose();
    controller.dispose();
    SmsAutoFill().unregisterListener();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getSignature() async {
    SmsAutoFill().getAppSignature.then((sign) {
      setState(() {
        signature = sign;
      });
    });
    SmsAutoFill().listenForCode;
  }

  Future<void> checkNetworkOtpResend() async {
    bool checkInternet = await checkNet();
    if (checkInternet) {
      if (_isClickable) {
        signInWithPhoneNumber();
      } else {
        if (!mounted) return;
        UiUtils.setSnackBar("", StringsRes.resendSnackBar, context, false, type: "2");
      }
    } else {
      setState(() {
        checkInternet = false;
      });
      Future.delayed(const Duration(seconds: 60)).then((_) async {
        bool checkInternet = await checkNet();
        if (checkInternet) {
          if (_isClickable) {
            signInWithPhoneNumber();
          } else {
            if (!mounted) return;
            UiUtils.setSnackBar("", StringsRes.resendSnackBar, context, false, type: "2");
          }
        } else {
          await buttonController.reverse();
          if (!mounted) return;
          UiUtils.setSnackBar("", StringsRes.noInterNetSnackBar, context, false, type: "2");
        }
      });
    }
  }

  void _onFormSubmitted() async {
    String code = otp.trim();
    if (code.length == 6) {
      setState(() {
        isloading = true;
      });
      AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);
      _firebaseAuth.signInWithCredential(authCredential).then((UserCredential value) async {
        login();
        //Navigator.of(context).pushNamedAndRemoveUntil(Routes.signUp, (Route<dynamic> route) => false, arguments: {'mobileNumber': widget.mobileNumber, 'countryCode': widget.countryCode});
        //Navigator.of(context).pushReplacementNamed(Routes.signUp, arguments: {'mobileNumber': widget.mobileNumber, 'countryCode': widget.countryCode});
        isloading = false;
        if (value.user != null) {
          await buttonController.reverse();
        } else {
          await buttonController.reverse();
        }
      }).catchError((error) async {
        if (mounted) {
          UiUtils.setSnackBar("", error.toString(), context, false, type: "2");
          isloading = false;
          await buttonController.reverse();
        }
      });
    } else {}
  }

  login() async {
    await Future.delayed(
        Duration.zero, () => context.read<SignInCubit>().signInUser(mobile: widget.mobileNumber /*, password: passwordController.text*/));
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

      Navigator.of(context).pop();
    }
  }

  navigationPageRegistration() async {
    if (widget.from == "splash") {
      await Future.delayed(
          Duration.zero,
          () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.signUp, (Route<dynamic> route) => false,
              arguments: {'mobileNumber': widget.mobileNumber, 'countryCode': widget.countryCode, 'from': widget.from}));
    } else {
      await Future.delayed(
          Duration.zero,
          () => Navigator.of(context)
              .pushNamed(Routes.signUp, arguments: {'mobileNumber': widget.mobileNumber, 'countryCode': widget.countryCode, 'from': widget.from}));
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ BlocProvider<SignUpCubit>(
            create: (_) => SignUpCubit(AuthRepository()),
            child: Builder(
              builder: (context) => Scaffold(
                appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, otpVerificationLabel),
                    const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
                body: Container(
                    margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                    decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                    width: width,
                    child: Container(
                      height: height!,
                      margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 60.0),
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height! / 70.0),
                              Text(
                                UiUtils.getTranslatedLabel(context, enterVerificationCodeLabel),
                                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondary),
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                UiUtils.getTranslatedLabel(context, otpVerificationSubTitleLabel),
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onSecondary),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(height: height! / 50.0),
                              Text(
                                "${widget.countryCode!} - ${widget.mobileNumber!}",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSecondary),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(bottom: 10.0, top: height! / 8.0),
                                child: PinInputTextField(
                                  pinLength: 6,
                                  //decoration: _pinDecoration,
                                  controller: controller,
                                  textInputAction: TextInputAction.done,
                                  //enabled: _enable,
                                  keyboardType: TextInputType.phone,
                                  textCapitalization: TextCapitalization.characters,
                                  onSubmit: (pin) {
                                    debugPrint('submit pin:$pin');
                                    otp = pin;
                                  },
                                  onChanged: (pin) {
                                    debugPrint('onChanged execute. pin:$pin${pin.length}-----${controller.text.length}-----${otp.length}');
                                    isErrorOtp = controller.text.isEmpty;
                                    otp = pin;
                                    isloading = false;
                                    if(controller.text.length==6 || controller.text.length == 5){
                                      setState(() {
                                      });
                                    }
                                  },
                                  decoration: BoxLooseDecoration(
                                      strokeColorBuilder: PinListenColorBuilder(Theme.of(context).colorScheme.onSecondary, lightFont),
                                      textStyle: const TextStyle(color: black, fontSize: 28, fontWeight: FontWeight.w600),
                                      gapSpace: 8.0,
                                      bgColorBuilder: PinListenColorBuilder(textFieldBackground, textFieldBackground)),
                                  enableInteractiveSelection: false,
                                  cursor: Cursor(
                                    width: 0.5,
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    radius: const Radius.circular(8),
                                    //enabled: _cursorEnable,
                                  ),
                                ),
                              ),
                              BlocListener<VerifyOtpCubit, VerifyOtpState>(
                                listener: (context, state) {
                                  if (state is VerifyOtpSuccess) {
                                    login();
                                  }
                                  if (state is VerifyOtpFailure) {
                                    UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, otpLabel), state.errorMessage, context, false,
                                        type: '2');
                                  }
                                },
                                child: BlocConsumer<ManageCartCubit, ManageCartState>(
                                    bloc: context.read<ManageCartCubit>(),
                                    listener: (context, state) {
                                      if (state is ManageCartSuccess) {
                                        final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                        context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(state.data, state.totalQuantity,
                                            state.subTotal, state.taxPercentage, state.taxAmount, state.overallAmount, state.variantId));
                                        context.read<ValidatePromoCodeCubit>().getValidatePromoCode(promoCode, context.read<AuthCubit>().getId(),
                                            state.overallAmount!.toStringAsFixed(2), walletBalanceUsed.toString(), context.read<GetCartCubit>().cartPartnerId());
                                      } else if (state is ManageCartFailure) {
                                        print(state.errorMessage);
                                        db.clearCart();
                                      }
                                    },
                                    builder: (context, state) {
                                      return BlocConsumer<SignInCubit, SignInState>(
                                          bloc: context.read<SignInCubit>(),
                                          listener: (context, state) async {
                                            if (state is SignInFailure) {
                                              print(state.errorMessage.toString());
                                              //UiUtils.setSnackBar(StringsRes.login, state.errorMessage, context, false);
                                              navigationPageRegistration();
                                              isloading = false;
                                              context.read<SettingsCubit>().changeShowSkip();
                                            } else if (state is SignInSuccess) {
                                              context.read<AuthCubit>().updateDetails(authModel: state.authModel);
                                              offCartAdd().then((value) {
                                                db.clearCart();
                                                navigationPageHome();
                                              });
                                              isloading = false;
                                              context.read<SettingsCubit>().changeShowSkip();
                                            }
                                          },
                                          builder: (context, state) {
                                            return codeSent
                                                ? SizedBox(
                                                    width: width!,
                                                    child: ButtonContainer(
                                                      color: controller.text.length == 6
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Theme.of(context).colorScheme.onSurface,
                                                      height: height,
                                                      width: width,
                                                      text: UiUtils.getTranslatedLabel(context, enterOtpLabel),
                                                      bottom: height! / 20.0,
                                                      start: 0,
                                                      end: 0,
                                                      top: height! / 20.0,
                                                      status: isloading,
                                                      borderColor:
                                                          controller.text.length == 6 ? Theme.of(context).colorScheme.primary : commentBoxBorderColor,
                                                      textColor: controller.text.length == 6 ? white : commentBoxBorderColor,
                                                      onPressed: () {
                                                        if (controller.text.isEmpty) {
                                                          otpMobile(controller.text);
                                                        } else {
                                                          if (widget.type == "firebase") {
                                                            _onFormSubmitted();
                                                          } else {
                                                            context
                                                                .read<VerifyOtpCubit>()
                                                                .verifyOtp(mobile: widget.mobileNumber, otp: controller.text);
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  )
                                                : const SizedBox();
                                          });
                                    }),
                              ),
                              enableResendOtpButton
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        UiUtils.getTranslatedLabel(context, didNotGetCodeYetLabel),
                                        style:
                                            TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : const SizedBox(),
                              codeSent ? _buildResendText() : Container(),
                            ]),
                      ),
                    )),
              ),
            ));
  }
}

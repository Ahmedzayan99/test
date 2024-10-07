import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/screen/favourite/favourite_screen.dart';
import 'package:project1/ui/screen/settings/refer_and_earn_screen.dart';
import 'package:project1/ui/widgets/LanguageDialog.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/customDialog.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project1/utils/internetConnectivity.dart';
//import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';

class AccountScreen extends StatefulWidget {
  final Function? bottomStatus;
  const AccountScreen({Key? key, this.bottomStatus}) : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with TickerProviderStateMixin {
  double? width, height;
  var size;
  //final ScrollController _scrollBottomBarController = ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
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
    //getUserLocation();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    //myScroll(_scrollBottomBarController, context);
  }

  bottomStatusUpdate() {
    setState(() {
      widget.bottomStatus!(0);
    });
  }

  profileData(Size size, String? image, state) {
    return Container(
      width: width,
      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
      height: height! / 11,
      margin: EdgeInsetsDirectional.only(top: height! / 50, start: width! / 20.0, end: width! / 20.0),
      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: width! / 40.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: image != "" ? DesignConfig.imageWidgets(image, 57, 57, "2") : DesignConfig.imageWidgets('profile_pic', 57, 57, "1"),
            ),
          ),
          Expanded(
            child: (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)?Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(UiUtils.getTranslatedLabel(context, yourProfileLabel),
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2.0),
                       RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${UiUtils.getTranslatedLabel(context, loginLabel)} ",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                    Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'profile'}).then((value) {
                                  appDataRefresh(context);
                                });
                                    },    
                                ),
                                TextSpan(
                                  text: UiUtils.getTranslatedLabel(context, loginOrSignUpToViewYourCompleteProfileLabel),
                                  style: const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                      
                      ]):Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.authModel.username!,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5.0),
                        Text(state.authModel.email!,
                            textAlign: TextAlign.start, style: const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.normal)),
                      ],
                    )
          ),
          Align(alignment: Alignment.topRight, child: editProfileButton()),
        ],
      ),
    );
  }

  Widget editProfileButton() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.profile, arguments: false);
              },
              child: Container(
                  height: 24,
                  width: 24, margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSecondary, 4),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("pro_edit"),
                      width: 14.0, height: 13.99, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
            );
    });
  }

  Widget arrowTile({String? title, VoidCallback? onPressed, String? image}) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: CircleAvatar(
            radius: 18.0,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            child: SvgPicture.asset(DesignConfig.setSvgPath(image!),
                width: 16.0, height: 16.0, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
        title: Text(title!,
            textAlign: TextAlign.start,
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        trailing: IconButton(
            onPressed: onPressed,
            padding: EdgeInsetsDirectional.only(start: height! / 40.0),
            icon: Icon(Icons.arrow_forward_ios, size: 15, color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }

  Widget topTabData(AuthState state) {
    return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
        ? const SizedBox.shrink()
        : Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const CartScreen(from: "account"),
                      ),
                    );
                  },
                  child: Container(
                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
                      padding: const EdgeInsetsDirectional.all(10.0),
                      margin: EdgeInsetsDirectional.only(bottom: height! / 80.0, start: width! / 20.0, end: width! / 99.0),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Theme.of(context).colorScheme.onSecondary,
                            child: SvgPicture.asset(DesignConfig.setSvgPath("cart_icon"),
                                width: 16.0,
                                height: 16.0,
                                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
                        SizedBox(height: height! / 99.0),
                        Text(UiUtils.getTranslatedLabel(context, cartLabel),
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ])),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.order, arguments: false);
                  },
                  child: Container(
                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
                      padding: const EdgeInsetsDirectional.all(10.0),
                      margin: EdgeInsetsDirectional.only(bottom: height! / 80.0, start: width! / 99.0, end: width! / 99.0),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Theme.of(context).colorScheme.onSecondary,
                            child: SvgPicture.asset(DesignConfig.setSvgPath("my_order_icon"),
                                width: 16.0,
                                height: 16.0,
                                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
                        SizedBox(height: height! / 99.0),
                        Text(UiUtils.getTranslatedLabel(context, myOrderLabel),
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ])),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.deliveryAddress, arguments: false);
                  },
                  child: Container(
                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
                      padding: const EdgeInsetsDirectional.all(10.0),
                      margin: EdgeInsetsDirectional.only(bottom: height! / 80.0, start: width! / 99.0, end: width! / 20.0),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Theme.of(context).colorScheme.onSecondary,
                            child: SvgPicture.asset(DesignConfig.setSvgPath("address_icon"),
                                width: 16.0,
                                height: 16.0,
                                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn))),
                        SizedBox(height: height! / 99.0),
                        Text(UiUtils.getTranslatedLabel(context, addressLabel),
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ])),
                ),
              ),
            ],
          );
  }

  Widget transactionData(AuthState state) {
    return arrowTile(
        image: "pro_th",
        title: UiUtils.getTranslatedLabel(context, transactionLabel),
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
        title: UiUtils.getTranslatedLabel(context, walletLabel),
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

  Widget favouriteData(AuthState state) {
    return arrowTile(
        image: "favourite_icon",
        title: UiUtils.getTranslatedLabel(context, favouriteLabel),
        onPressed: () {
          Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const FavouriteScreen(),
                      ),
                    );
        });
  }

  Widget aboutUsData() {
    return arrowTile(
        image: "pro_aboutus",
        title: UiUtils.getTranslatedLabel(context, aboutUsLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: aboutUsKey);
        });
  }

  Widget contactUsData() {
    return arrowTile(
        image: "pro_contact_us",
        title: UiUtils.getTranslatedLabel(context, contactUsLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: contactUsKey);
        });
  }

  Widget helpAndSupport() {
    return arrowTile(
        image: "pro_customersupport",
        title: UiUtils.getTranslatedLabel(context, helpAndSupportLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.ticket);
        });
  }

  Widget termAndCondition() {
    return arrowTile(
        image: "pro_tc",
        title: UiUtils.getTranslatedLabel(context, termAndConditionLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditionsKey);
        });
  }

  Widget privacyPolicyData() {
    return arrowTile(
        image: "pro_pp",
        title: UiUtils.getTranslatedLabel(context, privacyPolicyLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
        });
  }

  Widget faqs() {
    return arrowTile(
        image: "pro_faq",
        title: UiUtils.getTranslatedLabel(context, faqsLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.faqs);
        });
  }

  Widget referAndEarn(AuthState state) {
    return arrowTile(
        image: "pro_earn",
        title: UiUtils.getTranslatedLabel(context, referralAndEarnCodeLabel),
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
        title: UiUtils.getTranslatedLabel(context, deleteYourAccountLabel),
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
        title: UiUtils.getTranslatedLabel(context, rateUsLabel),
        onPressed: () {
         /* LaunchReview.launch(
            androidAppId: packageName,
            iOSAppId: "585027354",
          );*/
        });
  }

  Widget languageChange() {
    return arrowTile(
        image: "pro_translate",
        title: UiUtils.getTranslatedLabel(context, languageChangeLabel),
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

  Widget logInAndLogoutButton() {
    return Container(
      width: width,
      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
      child: ButtonContainer(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.11),
        height: height,
        width: width,
        text: UiUtils.getTranslatedLabel(context, logoutLabel),
        top: 0,
        bottom: 0,
        start: width! / 40.0,
        end: width! / 40.0,
        status: false,
        borderColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                    title: UiUtils.getTranslatedLabel(context, logoutLabel),
                    subtitle: UiUtils.getTranslatedLabel(context, areYouSureYouWantToLogoutLabel),
                    width: width!,
                    height: height!,
                    from: UiUtils.getTranslatedLabel(context, logoutLabel));
              });
        },
      ),
    );
  }

  Widget share() {
    return arrowTile(
        image: "pro_share",
        title: UiUtils.getTranslatedLabel(context, shareLabel),
        onPressed: () {
          try {
            Share.share("$appName\n${context.read<SystemConfigCubit>().getAppLink()}\n");
          } catch (e) {
            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, shareLabel), e.toString(), context, false, type: "2");
          }
        });
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

  Widget listHederTitle(String? title) {
    return Padding(
      padding:
          EdgeInsetsDirectional.only(top: height! / 80.0, start: width! / 20.0),
      child: Text(UiUtils.getTranslatedLabel(context, title!),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: greayLightColor,
              fontSize: 14,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget profile(AuthState state) {
    return Container(
        margin: EdgeInsetsDirectional.only(top: height! / 15.0),
        width: width,
        height: height!,
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height! / 18.0),
            topTabData(state),
            //(context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)?const SizedBox.shrink():listHederTitle(profileLabel),
            (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)?const SizedBox.shrink():Container(
              decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
              padding: const EdgeInsetsDirectional.all(10.0),
              margin: EdgeInsetsDirectional.only(top: 2.0, bottom: height! / 80.0, start: width! / 20.0, end: width! / 20.0),
              child: Column(children: [
                favouriteData(state),
                line(),
                walletData(state),
                line(),
                transactionData(state),
              ]),
            ),
            listHederTitle(settingsLabel),
            Container(
                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                padding: const EdgeInsetsDirectional.all(10.0),
                margin: EdgeInsetsDirectional.only(top: height! / 80.0, bottom: height! / 80.0, start: width! / 20.0, end: width! / 20.0),
                child: Column(children: [
                  languageChange(),
                  line(),
                  (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) || (context.read<SystemConfigCubit>().getDemoMode() == "0") || context.read<AuthCubit>().getMobile()=="9999999999" ?const SizedBox.shrink():deleteYourAccount(state),
                  (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated) || (context.read<SystemConfigCubit>().getDemoMode() == "0") || context.read<AuthCubit>().getMobile()=="9999999999" ?const SizedBox.shrink():line(),
                  aboutUsData(),
                  line(),
                  contactUsData(),
                  line(),
                  (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)?const SizedBox.shrink():helpAndSupport(),
                  (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)?const SizedBox.shrink():line(),
                  termAndCondition(),
                  line(),
                  privacyPolicyData(),
                  line(),
                  faqs(),
                  line(),
                  rateUs(),
                  line(),
                  share(),
                  line(),
                  referAndEarn(state),
                ])),
            (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                ? const SizedBox.shrink()
                : logInAndLogoutButton(),
            //SizedBox(height: height! / 10.0),
          ],
        )));
  }

  @override
  void dispose() {
    //_scrollBottomBarController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
              appBar: AppBar(
                leadingWidth: width! / 8.5,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                      padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                      child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.onSurface,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8.0),
                            child: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.primary, size: 15.0),
                          ))),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shadowColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                centerTitle: true,
                title: Text(UiUtils.getTranslatedLabel(context, accountLabel),
                    textAlign: TextAlign.center, style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                      return Stack(
                        children: [
                          Container(color: Theme.of(context).colorScheme.primary, width: width, height: height! / 14.0),
                          profile(state),
                          BlocBuilder<AuthCubit, AuthState>(
                              bloc: context.read<AuthCubit>(),
                              builder: (context, state) {
                                if (state is Authenticated) {
                                  return profileData(size, state.authModel.image!, state);
                                }
                                return profileData(size, "", state);
                              }),
                        ],
                      );
                    }),
            ),
    );
  }
}

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/data/model/introduction_slider_model.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/ui/screen/settings/no_location_screen.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class IntroductionSliderScreen extends StatefulWidget {
  const IntroductionSliderScreen({Key? key}) : super(key: key);

  @override
  IntroductionSliderScreenState createState() => IntroductionSliderScreenState();
}

class IntroductionSliderScreenState extends State<IntroductionSliderScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  double? height, width;
  AnimationController? _animationController;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  double endProgress = 0.05;
  late CircularProgressIndicator progressBar;
  Timer? timer;
  List<IntroductionSliderModel> introductionSliderList = [];

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    _animationController!.value = 0;
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
    if (currentIndex < 2) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }

    print("index:${currentIndex < 2}");
    

/*    _pageController.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );*/
  });
  Future.delayed(const Duration(microseconds: 1000),(){
  introductionData();});
    super.initState();
  }
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _pageController.dispose();
    _connectivitySubscription.cancel();
    timer!.cancel();
    super.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      endProgress = currentIndex / 2;
      if(endProgress==0.0){
        endProgress = 0.05;
      }
      _animationController!.repeat();
    });
  }

  List<T?> map<T>(List list, Function handler) {
    List<T?> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  void onNext(int index) {
    setState(() {
      //currentIndex = index;
      if (currentIndex < 2) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }
      _pageController.nextPage(duration: const Duration(milliseconds: 400),curve: Curves.easeInOut,);
    });
  }

  introductionData(){
    introductionSliderList = [
      IntroductionSliderModel(
        id: 1,
        title: UiUtils.getTranslatedLabel(context, introTitle1Label),
        subTitle: UiUtils.getTranslatedLabel(context, introSubTitle1Label),
        image: "intro_1",
      ),
      IntroductionSliderModel(
        id: 2,
        title: UiUtils.getTranslatedLabel(context, introTitle2Label),
        subTitle: UiUtils.getTranslatedLabel(context, introSubTitle2Label),
        image: "intro_2",
      ),
      IntroductionSliderModel(
        id: 1,
        title: UiUtils.getTranslatedLabel(context, introTitle3Label),
        subTitle: UiUtils.getTranslatedLabel(context, introSubTitle3Label),
        image: "intro_3",
      ),
    ];
  }

  Widget _slider() {
    return PageView.builder(
      itemCount: introductionSliderList.length,
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          color: Theme.of(context).colorScheme.onSurface,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(top: height! / 6.9),
                child: Column(
                  children: [
                    SvgPicture.asset(DesignConfig.setSvgPath(introductionSliderList[index].image!)),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height! / 20.0),
                      child: Text(
                        introductionSliderList[currentIndex].title!,
                        style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height! / 50.0, bottom: height!/ 40.0, start: width!/20.0, end: width!/20.0),
                      child: Text(
                        introductionSliderList[currentIndex].subTitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: greayLightColor, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

   List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6,
        width: isActive ? 15 : 10,
        margin: const EdgeInsetsDirectional.only(end: 5),
        decoration: isActive
            ? DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 3)
            : DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.primary, textFieldBackground, 3));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: /*/*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/*/ Scaffold(
              bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: height! / 12,
                    margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                    child: SizedBox(width: width!,
                      child: ButtonContainer(
                                          color: Theme.of(context).colorScheme.primary,
                                          height: height,
                                          width: width,
                                          text: UiUtils.getTranslatedLabel(context, exploreproject1Label),
                                          top: 0,
                                          bottom: 0,
                                          start: width! / 40.0,
                                          end: width! / 40.0,
                                          status: false,
                                          borderColor: Theme.of(context).colorScheme.primary,
                                          textColor: white,
                                          onPressed: () {
                                            context.read<SettingsCubit>().changeShowIntroSlider();
                           Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => const NoLocationScreen(),
                                  ),
                                  (Route<dynamic> route) => false);
                                          },
                                        ),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: width!,
                    margin: EdgeInsetsDirectional.only(
                        bottom: height! / 50.0, top: height! / 99.0),
                    child: ButtonContainer(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: height,
                      width: width,
                      text: UiUtils.getTranslatedLabel(context, loginOrSignupLabel),
                      top: 0,
                      bottom: 0,
                      start: width! / 40.0,
                      end: width! / 40.0,
                      status: false,
                      borderColor: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        context.read<SettingsCubit>().changeShowIntroSlider();
                        Navigator.of(context).pushReplacementNamed(Routes.login,
                            arguments: {'from': 'splash'});
                      },
                    ),
                  ),
                ],
              ),
              body: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: <Widget>[
                    _slider(),
                    Container(alignment: Alignment.center,
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99, top: height! / 1.5),
                      child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        // margin: EdgeInsets.only(top: 10, bottom: 30),
                        width: 75,
                        height: 75,
                        child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: endProgress),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                            builder: (context, value, _) {
                              return progressBar = CircularProgressIndicator(
                                value: value,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary),
                              );
                            }),
                      ),
                      Positioned(
                        child: GestureDetector(
                            onTap: () => onNext(currentIndex + 1),
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.arrow_forward, color:Theme.of(context).colorScheme.onSurface)
                              ),
                            )),
                    ],
                  ) ,

                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildIndicator(),
                    ) ,
                  ],
                ),
              ),
            ),
    );
  }
}

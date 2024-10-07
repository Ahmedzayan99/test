import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/home/search/searchCubit.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/searchContainer.dart';
import 'package:project1/ui/widgets/simmer/notificationSimmer.dart';
import 'package:project1/ui/widgets/voiceSearchContainer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:project1/utils/internetConnectivity.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../data/model/searchModel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SearchCubit>(
              create: (_) => SearchCubit(),
              child: const SearchScreen(),
            ));
  }
}

class SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  String searchText = '';
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  List<SearchModel> searchList = [];
  final SpeechToText speech = SpeechToText();
    late StateSetter setStater;
  bool _hasSpeech = false,
      isLoading = true,
      freeLoading = true,
      paidLoading = true;
  String lastWords = '';
  String _currentLocaleId = '';
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastStatus = '';
  SpeechListenOptions options = SpeechListenOptions(
    cancelOnError: true, // New way to set cancelOnError
    partialResults: true,
    listenMode: ListenMode.dictation,
  );

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
    controller.addListener(scrollListener);
    searchController.addListener(() {
      String sText = searchController.text;

      if (searchText != sText) {
        searchText = sText;
        //print("====data===$searchText");

        //isloadmore = true;
        //offset = 0;
        Future.delayed(Duration.zero, () {
          searchApi();
        });  
      }
    });

    super.initState();
  }

  searchApi(){
    context.read<SearchCubit>().fetchSearch(
              perPage,
              searchText,
              context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
              context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
              context.read<AuthCubit>().getId(),
              context.read<CityDeliverableCubit>().getCityId());
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<SearchCubit>().hasMoreData()) {
        if (searchList.length > int.parse(perPage)) {
          context.read<SearchCubit>().fetchMoreSearchData(
              perPage,
              searchController.text.trim(),
              context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
              context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
              context.read<AuthCubit>().getId(),
              context.read<CityDeliverableCubit>().getCityId());
        }
      }
    }
  }

  Widget searchDataList() {
    return BlocConsumer<SearchCubit, SearchState>(
        bloc: context.read<SearchCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SearchProgress) {
            return NotificationSimmer(width: width!, height: height!);
          }
          if (state is SearchInitial) {
            return const Center(
                child: Text(
              /*StringsRes.searchFood*/ "",
              textAlign: TextAlign.center,
            ));
          }
          if (state is SearchFailure) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundTitleLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, noSearchFoundSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            );
          }
          searchList = (state as SearchSuccess).searchList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              /* color: ColorsRes.white,*/
              child: searchText == ""
                  ? const SizedBox()
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: searchList.length,
                      itemBuilder: (BuildContext context, index) {
                        //print(searchList[index].partnerDetails![0].balance);
                        return hasMore && searchList.isEmpty && index == (searchList.length - 1)
                            ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                            : SearchContainer(restaurant: searchList[index], height: height!, width: width!, searchText: searchController.text);//RestaurantContainer(restaurant: searchList[index].partnerDetails![0], height: height!, width: width!);
                      }));
        });
  }


    void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      searchText = lastWords.replaceAll(' ', '');
      print(searchText);
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        // clearAll();
        setState(() {
          searchController.text = lastWords;
          searchText = lastWords;
          searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: searchController.text.length));
        });
        searchApi();
        //onItemChanged(searchText);
        Navigator.of(context).pop();
      });
    }
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        // partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        // cancelOnError: true,
        // listenMode: ListenMode.confirmation
        listenOptions: options
        );
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: (val) => print("onError:$val"),
        onStatus: (val) => print('onState: $val'),
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));

    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
      print("_currentLocaleId$_currentLocaleId");
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) bottoSheetVoiceReconization();
  }

  bottoSheetVoiceReconization() {
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater1) {
              setStater = setStater1;
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      height: (MediaQuery.of(context).size.height) / 2.6,
                      padding: EdgeInsets.only(top: height! / 15.0),
                      child: Container(
                        decoration: DesignConfig.boxDecorationContainerRoundHalf(
                            Theme.of(context).colorScheme.onSurface, 25, 0, 25, 0),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: width! / 15.0,
                              right: width! / 15.0,
                              top: height! / 25.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                speech.isListening
                                ? Text(
                                    UiUtils.getTranslatedLabel(context, listeningLabel),
                                    style: const TextStyle(
                                          fontSize: 16,
                                          color: greayLightColor,
                                          fontWeight: FontWeight.bold),
                                  )
                                : speech.hasRecognized?Text(
                                    UiUtils.getTranslatedLabel(context, successLabel),
                                    style: const TextStyle(
                                          fontSize: 16,
                                          color: greayLightColor,
                                          fontWeight: FontWeight.bold),
                                  ):speech.hasError?Text(
                                    UiUtils.getTranslatedLabel(context, sorryDidnthearthatLabel),
                                    style: const TextStyle(
                                          fontSize: 16,
                                          color: greayLightColor,
                                          fontWeight: FontWeight.bold),
                                  ):const SizedBox(),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(top: height!/30.0),
                                  child: GestureDetector(onTap:(){
                                    if (!_hasSpeech) {
                              initSpeechState();
                            } else {
                              !_hasSpeech || speech.isListening
                                    ? null
                                    : startListening();
                            }
                                  },child: CircleAvatar(radius: 35,backgroundColor: Theme.of(context).colorScheme.primary, child: SvgPicture.asset(DesignConfig.setSvgPath("voice_search_icon"), fit: BoxFit.scaleDown))),
                                ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height!/99.0, bottom: height!/99.0),
                          child: lastWords.isEmpty?const SizedBox():Text(
                            lastWords,
                            style: const TextStyle(
                                          fontSize: 14,
                                          color: lightFontColor,
                                          fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          padding: EdgeInsetsDirectional.only(top: width!/30),
                          //color: Theme.of(context).colorScheme.surface,
                          child: Center(
                            child: speech.isListening
                                ? const SizedBox()
                                : Text(UiUtils.getTranslatedLabel(context, tapTheMicroPhoneToTryAgainLabel),
                                    style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSecondary,
                                          fontWeight: FontWeight.bold),
                                  )
                                  
                                  
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
                      child: SvgPicture.asset(
                          DesignConfig.setSvgPath("cancel_icon"),
                          width: 32,
                          height: 32)),
                ],
              );
            }
          );
        });
  }
  void errorListener(SpeechRecognitionError error) {
    print("error:${error.errorMsg}");
    if (mounted) {
      setState(() {
        // lastError = '${error.errorMsg} - ${error.permanent}';
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, searchLabel), error.errorMsg, context, false,
                                            type: "2");
      });
    }
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
      print("Status...................:$status");
    });
  }

  /*Widget searchData() {
    return Container(height: height!/25.2, margin: EdgeInsetsDirectional.only(top: height!/40.0, bottom: height!/40.0, start: width!/20.0),
        child: ListView.builder(shrinkWrap: true, //padding: EdgeInsetsDirectional.only(top: height!/40.0),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: searchList.length,scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Container(
                  padding: EdgeInsetsDirectional.only(start: width!/20.0, top: height!/99.0, end: width!/20.0, bottom: height!/99.0),
                  margin: EdgeInsetsDirectional.only(end: width!/20.0),
                  decoration: DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                                    Text(searchList[index].title!, textAlign: TextAlign.center, style: const TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8.0),
                  SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 10, height: 10),
                    ],
                  ));
            }
        ));
  }*/

  Widget searchBar() {
    return Container(
        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.surface, 10.0),
        padding: EdgeInsetsDirectional.only(start: width! / 99.0),
        margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 99.0),
        child: TextField(
          controller: searchController,
          cursorColor: lightFont,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: InkWell(onTap:(){
              },child: const Icon(Icons.search, color: lightFont)),
            suffixIcon: searchController.text.trim().isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onSecondary),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        searchText = searchController.text;
                        searchList.clear();
                      });
                    },
                  ),
            hintText: UiUtils.getTranslatedLabel(context, searchTitleLabel),
            labelStyle: const TextStyle(
              color: lightFont,
              fontSize: 14.0,
            ),
            hintStyle: const TextStyle(
              color: lightFont,
              fontSize: 14.0,
            ),
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: lightFont,
            fontSize: 14.0,
          ),
        ));
  }

  @override
  void dispose() {
    searchController.dispose();
    controller.dispose();
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
              appBar: AppBar(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                        padding: EdgeInsetsDirectional.only(start: width! / 20),
                        child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32,fit: BoxFit.scaleDown,))),
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                shadowColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                centerTitle: true,
                title: Text(UiUtils.getTranslatedLabel(context, searchLabel),
                    textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
                bottom: PreferredSize(
                  preferredSize: Size(width!, /*height!/5.0*/ height! / 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: width!/20.0),
                        child: Row(
                          children: [
                            Expanded(child: searchBar()),
                            GestureDetector(
                              onTap:(){
                                if (!_hasSpeech) {
                                  initSpeechState();
                                } else {
                                  //showSpeechDialog();
                                  if (!_hasSpeech) {
                                    initSpeechState();
                                  } else {
                                    !_hasSpeech || speech.isListening
                                        ? null
                                        : startListening();
                                  }
                                  bottoSheetVoiceReconization();
                                }
                              },
                              child: VoiceSearchContainer(
                                width: width!,
                                height: height!,
                                ),
                            )
                          ],
                        ),
                      ),
                      /*searchData(),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: width!/20.0, end: width!/20.0),
                      child: Text(restaurantsNearbyList.length.toString() + " " + StringsRes.restaurantsNearby, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                    )*/
                    ],
                  ),
                ),
              ),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: Container(
                  //margin: EdgeInsetsDirectional.only(end: width!/40.0, start: width!/40.0),
                  child: searchDataList(),
                ),
              ),
            ),
    );
  }
}

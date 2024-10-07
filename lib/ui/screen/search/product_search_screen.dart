import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/home/search/productSearchCubit.dart';
import 'package:project1/cubit/home/search/searchCubit.dart';
import 'package:project1/data/model/sectionsModel.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/bottomSheetContainer.dart';
import 'package:project1/ui/widgets/productItemContainer.dart';
import 'package:project1/ui/widgets/productUnavailableDialog.dart';
import 'package:project1/ui/widgets/restaurantCloseDialog.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
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

class ProductSearchScreen extends StatefulWidget {
  final String? partnerId, partnerName;
  ProductSearchScreen({Key? key, this.partnerId, this.partnerName}) : super(key: key);

  @override
  ProductSearchScreenState createState() => ProductSearchScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<ProductSearchCubit>(
              create: (_) => ProductSearchCubit(),
              child: ProductSearchScreen(
                partnerId: arguments['partnerId'] as String, partnerName: arguments['partnerName'] as String
              ),
            ));
  }
}

class ProductSearchScreenState extends State<ProductSearchScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  String searchText = '';
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  List<ProductDetails> productSearchList = [];
  String? statusFoodType = "";
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
    context.read<ProductSearchCubit>().fetchProductSearch(
              perPage,
              searchText,
              statusFoodType!,
              context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
              context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
              context.read<AuthCubit>().getId(),
              context.read<CityDeliverableCubit>().getCityId(),
              widget.partnerId);
  }
  

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<SearchCubit>().hasMoreData()) {
        if (productSearchList.length > int.parse(perPage)) {
          context.read<ProductSearchCubit>().fetchMoreProductSearchData(
              perPage,
              searchText,
              statusFoodType!,
              context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
              context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
              context.read<AuthCubit>().getId(),
              context.read<CityDeliverableCubit>().getCityId(),
              widget.partnerId);
        }
      }
    }
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
                                  padding: EdgeInsetsDirectional.only(top: height!/20.0),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            lastWords,
                            style: const TextStyle(
                                          fontSize: 14,
                                          color: lightFontColor,
                                          fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
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

  Widget foodType() {
    return Container(
        margin: EdgeInsetsDirectional.only(top: height! / 50.0, start: width! / 20.0, end: width! / 20.0, bottom: height!/99.0),
        decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
        child: Row(children: [
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "";
                    });
                    context.read<ProductSearchCubit>().fetchProductSearch(
                        perPage,
                        searchText,
                        statusFoodType!,
                        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
                        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
                        context.read<AuthCubit>().getId(),
                        context.read<CityDeliverableCubit>().getCityId(),
                        widget.partnerId);
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0, start: width! / 70.0, end: width! / 70.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 99.0, end: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, 15.0),
                      child: Text(UiUtils.getTranslatedLabel(context, allLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "" ? white : Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "1";
                    });
                    context.read<ProductSearchCubit>().fetchProductSearch(
                        perPage,
                        searchText,
                        statusFoodType!,
                        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
                        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
                        context.read<AuthCubit>().getId(),
                        context.read<CityDeliverableCubit>().getCityId(),
                        widget.partnerId);
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(
                        start: width! / 70.0,
                        end: width! / 99.0,
                        bottom: height! / 99.0,
                        top: height! / 99.0,
                      ),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 99.0, end: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "1" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, 15.0),
                      child: Text(UiUtils.getTranslatedLabel(context, vegLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "1" ? white : Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "2";
                    });
                    context.read<ProductSearchCubit>().fetchProductSearch(
                        perPage,
                        searchText,
                        statusFoodType!,
                        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
                        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
                        context.read<AuthCubit>().getId(),
                        context.read<CityDeliverableCubit>().getCityId(),
                        widget.partnerId);
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0, start: width! / 70.0, end: width! / 70.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 99.0, end: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "2" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, 15.0),
                      child: Text(UiUtils.getTranslatedLabel(context, nonVegLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "2" ? white : Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
        ]));
  }

  bottomModelSheetShow(ProductDetails productList) {
    ProductDetails productDetailsModel = productList;
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![0].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    //print("id:" + productDetailsModel.variants![_currentIndex].addOnsData!.length.toString());
    for (int i = 0; i < productDetailsModel.variants![currentIndex].addOnsData!.length; i++) {
      //print("id:" + productDetailsModel.variants![_currentIndex].addOnsData![i].id!);
      productAddOnIds.add(productDetailsModel.variants![currentIndex].addOnsData![i].id!);
    }
    if (productDetailsModel.variants![currentIndex].cartCount != "0") {
      qty = int.parse(productDetailsModel.variants![currentIndex].cartCount!);
    } else {
      qty = int.parse(productDetailsModel.minimumOrderQuantity!);
    }
    qtyData[productVariantId!] = qty;
    bool descTextShowFlag = false;

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return BottomSheetContainer(
              productDetailsModel: productDetailsModel,
              isChecked: isChecked,
              height: height!,
              width: width!,
              productVariantId: productVariantId,
              addOnIds: addOnIds,
              addOnPrice: addOnPrice,
              addOnQty: addOnQty,
              productAddOnIds: productAddOnIds,
              qtyData: qtyData,
              currentIndex: currentIndex,
              descTextShowFlag: descTextShowFlag,
              qty: qty,
              from: "productSearch");
        });
  }

  Widget searchDataList() {
    return BlocConsumer<ProductSearchCubit, ProductSearchState>(
        bloc: context.read<ProductSearchCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ProductSearchProgress) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is ProductSearchInitial) {
            return const Center(
                child: Text(
              /*StringsRes.searchFood*/ "",
              textAlign: TextAlign.center,
            ));
          }
          if (state is ProductSearchFailure) {
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
          productSearchList = (state as ProductSearchSuccess).productSearchList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              /* color: white,*/
              child: searchText == ""
                  ? const SizedBox()
                  : Container(
                      //decoration: DesignConfig.boxDecorationContainerCardShadow(white, shadowContainer, 15.0, 0, 3, 16, 0),
                      // padding: EdgeInsetsDirectional.only(start: width!/40.0, end: width!/40.0, bottom: height!/99.0),
                      //height: height!/4.7,
                      width: width!,
                      margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 50.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: productSearchList.length,
                          itemBuilder: (BuildContext context, i) {
                            ProductDetails dataItem = productSearchList[i];
                            double price = double.parse(dataItem.variants![0].specialPrice!);
                            if (price == 0) {
                              price = double.parse(dataItem.variants![0].price!);
                            }
                            double off = 0;
                            if (dataItem.variants![0].specialPrice! != "0") {
                              off = (double.parse(dataItem.variants![0].price!) - double.parse(dataItem.variants![0].specialPrice!)).toDouble();
                              off = off * 100 / double.parse(dataItem.variants![0].price!).toDouble();
                            }
                            return hasMore && productSearchList.isEmpty && i == (productSearchList.length - 1)
                                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                                : InkWell(
                                    onTap: () {
                                      if (dataItem.partnerDetails![0].isRestroOpen == "1") {
                                        bool check = getStoreOpenStatus(dataItem.startTime!, dataItem.endTime!);
                                        if(dataItem.availableTime=="1"){
                                          if(check==true){
                                            bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                                productSearchList[i].id!,
                                                productSearchList[i])[0] /* productSearchList, i */);
                                          }else{
                                            showDialog(
                                              context: context,
                                              builder: (_) => ProductUnavailableDialog(startTime: dataItem.startTime, endTime: dataItem.endTime));
                                          }
                                        }else{
                                          bottomModelSheetShow(context.read<GetCartCubit>().getProductDetailsData(
                                              productSearchList[i].id!,
                                              productSearchList[i])[0] /* productSearchList, i */);
                                        }
                                      } else {
                                        showDialog(
                                            context: context, builder: (_) => const RestaurantCloseDialog(hours: "", minute: "", status: false));
                                      }
                                    },
                                    child: ProductItemContainer(
                                        dataItem: dataItem,
                                        i: i,
                                        width: width!,
                                        height: height!,
                                        price: price,
                                        off: off,
                                        dataMainList: productSearchList),
                                  );
                          }),
                    ));
        });
  }

  /*Widget searchData() {
    return Container(height: height!/25.2, margin: EdgeInsetsDirectional.only(top: height!/40.0, bottom: height!/40.0, start: width!/20.0),
        child: ListView.builder(shrinkWrap: true, //padding: EdgeInsetsDirectional.only(top: height!/40.0),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: productSearchListlength,scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Container(
                  padding: EdgeInsetsDirectional.only(start: width!/20.0, top: height!/99.0, end: width!/20.0, bottom: height!/99.0),
                  margin: EdgeInsetsDirectional.only(end: width!/20.0),
                  decoration: DesignConfig.boxDecorationContainerBorder(lightFont, white, 5.0),
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
        child: TextField(
          controller: searchController,
          cursorColor: lightFont,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: lightFont),
            suffixIcon: searchController.text.trim().isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onSecondary),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        searchText = searchController.text;
                        productSearchList.clear();
                      });
                    },
                  ),
            hintText: UiUtils.getTranslatedLabel(context, searchDishLabel),
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
              appBar: DesignConfig.appBar(context, width!, widget.partnerName,PreferredSize(
                  preferredSize: Size(width!, /*height!/5.0*/ height! / 6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width!/20.0, end: width!/20.0),
                        child: Row(
                          children: [
                            Expanded(child: searchBar()),
                            GestureDetector(
                                onTap:(){
                                  if (!_hasSpeech) {
                                    initSpeechState();
                                  } else {
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
                      foodType(),
                      /*searchData(),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: width!/20.0, end: width!/20.0),
                      child: Text(restaurantsNearbyList.length.toString() + " " + StringsRes.restaurantsNearby, textAlign: TextAlign.center, style: const TextStyle(color: lightFont, fontSize: 12)),
                    )*/
                    ],
                  ),
                )),
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

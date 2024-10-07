import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/order/orderCubit.dart';
import 'package:project1/cubit/order/orderDetailCubit.dart';
import 'package:project1/cubit/rating/setOrderRatingCubit.dart';
import 'package:project1/cubit/rating/setProductRatingCubit.dart';
import 'package:project1/data/model/orderModel.dart';
import 'package:project1/data/model/rattingModel.dart';
import 'package:project1/data/repositories/rating/ratingRepository.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/styles/dotted_border.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/ratingConatiner.dart';
import 'package:project1/ui/widgets/simmer/orderDetailSimmer.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/screen/rating/thank_you_for_review_screen.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/internetConnectivity.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/svg.dart';

List<Map> commentList = [];

class ProductRatingScreen extends StatefulWidget {
  final String? orderId;
  const ProductRatingScreen({Key? key, this.orderId}) : super(key: key);

  @override
  _ProductRatingScreenState createState() => _ProductRatingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<SetProductRatingCubit>(
                create: (_) => SetProductRatingCubit(
                  RatingRepository(),
                ),
              ),
              BlocProvider<SetOrderRatingCubit>(
                create: (_) => SetOrderRatingCubit(
                  RatingRepository(),
                ),
              ),
              BlocProvider<OrderDetailCubit>(
                create: (_) => OrderDetailCubit(),
              )
            ], child: ProductRatingScreen(orderId: arguments['orderId'] as String)));
  }
}

class _ProductRatingScreenState extends State<ProductRatingScreen> {
  double? width, height;
  TextEditingController commentController = TextEditingController(text: "");
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  List<File> reviewPhotos = [];
  List<RatingModel> ratingList = [];
  int? selectedIndex = 4;
  bool? status = false;

  @override
  void initState() {
    super.initState();
    commentList.clear();
    //commentList = [{'comment':"", 'id':""}];
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    Future.delayed(Duration.zero, () {
      context.read<OrderDetailCubit>().fetchOrderDetail(perPage, context.read<AuthCubit>().getId(), widget.orderId!, "");
    });
    Future.delayed(const Duration(microseconds: 1000), () {
      ratingData();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  ratingData() {
    ratingList = [
      RatingModel(id: 1, title: UiUtils.getTranslatedLabel(context, veryPoorLabel), image: "very_poor", rating: "1.0", status: "0"),
      RatingModel(id: 2, title: UiUtils.getTranslatedLabel(context, poorLabel), image: "poor", rating: "2.0", status: "0"),
      RatingModel(id: 3, title: UiUtils.getTranslatedLabel(context, averageLabel), image: "average", rating: "3.0", status: "0"),
      RatingModel(id: 4, title: UiUtils.getTranslatedLabel(context, goodLabel), image: "good", rating: "4.0", status: "0"),
      RatingModel(id: 5, title: UiUtils.getTranslatedLabel(context, excellentLabel), image: "excellent", rating: "5.0", status: "1"),
    ];
  }

  @override
  void dispose() {
    commentController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget orderData() {
    return BlocConsumer<OrderDetailCubit, OrderDetailState>(
        bloc: context.read<OrderDetailCubit>(),
        listener: (context, state) {
          if (state is OrderDetailFailure) {
            if (state.errorStatusCode.toString() == "102") {
              reLogin(context);
            }
          }
          if (state is OrderDetailSuccess) {
            final orderList = state.orderList;
            print("length:${orderList.length}");
            for (int j = 0; j < orderList[0].orderItems!.length; j++) {
              print('----in for loop---${orderList[0].orderItems!.length}');
              commentList.add({'product_id': orderList[0].orderItems![j].productId, 'rating': "5.0", 'comment': "", 'images': []});
              print('---$commentList');
              print("index:$j");
            }
          }
        },
        builder: (context, state) {
          if (state is OrderDetailProgress || state is OrderDetailInitial) {
            return OrderSimmer(width: width!, height: height!);
          }
          if (state is OrderDetailFailure) {
            return Center(
                child: Text(
              state.errorMessage.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final orderList = (state as OrderDetailSuccess).orderList;

          return Container(
              padding: EdgeInsetsDirectional.only(start: width! / 60.0, end: width! / 60.0, bottom: height! / 99.0),
              //height: height!/4.7,
              width: width!,
              margin: EdgeInsetsDirectional.only(
                top: height! / 70.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(orderList[0].orderItems!.length, (i) {
                  OrderItems data = orderList[0].orderItems![i];
                  print("test-orderlen-$i===${0}==${orderList[0].orderItems!.length}");
                  if (i == 0) {
                    //commentList.clear();
                  }
                  return Container(
                      padding: EdgeInsetsDirectional.only(bottom: height! / 50.0, top: height! / 50.0, start: width! / 20.0, end: width! / 20.0),
                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                      //height: height!/4.7,
                      width: width!,
                      margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        i == 0
                            ? Text(UiUtils.getTranslatedLabel(context, howWasYourLabel),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w600))
                            : const SizedBox(),
                        i == 0 ? const SizedBox(height: 5.0) : const SizedBox(),
                        i == 0
                            ? Text(UiUtils.getTranslatedLabel(context, kindlyRateYourExperienceLabel),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w600))
                            : const SizedBox(),
                        i == 0 ? const SizedBox(height: 30.9) : const SizedBox(),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(data.name!,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                              maxLines: 1),
                        ),
                        const SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(UiUtils.getTranslatedLabel(context, didYouLikeTheTasteLabel),
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                              maxLines: 1),
                        ),
                        SizedBox(height: height! / 80.0),
                        //rating(),
                        RatingConatiner(index: i, productId: data.productId, height: height!, width: width!),
                      ]));
                }),
              ));
        });
  }

  Widget getImageField() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding: const EdgeInsetsDirectional.only(top: 5),
        margin: EdgeInsetsDirectional.only(top: height! / 60.0),
        height: height! / 10.0,
        child: Row(
          children: [
            InkWell(
                onTap: () {
                  _reviewImgFromGallery(setModalState);
                },
                child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: reviewPhotos.isEmpty ? width! / 1.12 : width! / 4.0,
                      height: height! / 10.0,
                      child: DottedBorder(
                          dashPattern: const [8, 4],
                          strokeWidth: 1,
                          strokeCap: StrokeCap.round,
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10.0),
                          child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.onSecondary),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(top: 2.9),
                                    child: Text(UiUtils.getTranslatedLabel(context, addPhotosLabel),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: greayLightColor,
                                          fontSize: 12,
                                        )),
                                  )
                                ]),
                          )),
                    ))),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: reviewPhotos.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return InkWell(
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width! / 40.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: Image.file(
                            reviewPhotos[i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary),
                          padding: const EdgeInsetsDirectional.all(5.0),
                          child: Icon(Icons.delete, size: 15, color: Theme.of(context).colorScheme.onSurface))
                    ],
                  ),
                  onTap: () {
                    if (mounted) {
                      setModalState(() {
                        reviewPhotos.removeAt(i);
                      });
                    }
                  },
                );
              },
            )),
          ],
        ),
      );
    });
  }

  void _reviewImgFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      reviewPhotos = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
    } else {
      // User canceled the picker
    }
  }

  Widget rating() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(ratingList.length, (m) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 10.0),
            child: InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  if (selectedIndex == m) {
                    setState(() {
                      ratingList[m].status = "0";
                      selectedIndex = 4;
                    });
                  } else {
                    setState(() {
                      ratingList[m].status = "1";
                      selectedIndex = m;
                    });
                  }
                },
                child: /* Image.asset(DesignConfig.setPngPath(ratingList[m].image!), height: selectedIndex == m ? 60.0 : 40) */
                    SvgPicture.asset(DesignConfig.setSvgPath(ratingList[m].image!), height: selectedIndex == m ? 60.0 : 40)),
          );
        }));
  }

  Widget comment() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
      margin: EdgeInsetsDirectional.only(top: height! / 40.0),
      child: TextField(
        controller: commentController,
        cursorColor: Theme.of(context).colorScheme.onSecondary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: UiUtils.getTranslatedLabel(context, doYouHaveAnyCommentsLabel),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
            appBar: DesignConfig.appBar(context, width, UiUtils.getTranslatedLabel(context, giveFeedbackLabel),
                const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
            bottomNavigationBar: BlocConsumer<SetOrderRatingCubit, SetOrderRatingState>(
                bloc: context.read<SetOrderRatingCubit>(),
                listener: (context, state) {
                  if (state is SetOrderRatingFailure) {
                    status = false;
                    if (state.errorStatusCode.toString() == "102") {
                      reLogin(context);
                    }
                  }
                  if (state is SetOrderRatingSuccess) {
                    //UiUtils.setSnackBar(StringsRes.rating, StringsRes.updateSuccessFully, context, false);
                    status = false;
                    context.read<SetProductRatingCubit>().setProductRating(context.read<AuthCubit>().getId(), commentList, widget.orderId!);
                  } else if (state is SetOrderRatingFailure) {
                    print(state.errorCode.toString());
                  }
                },
                builder: (context, state) {
                  return BlocConsumer<SetProductRatingCubit, SetProductRatingState>(
                      bloc: context.read<SetProductRatingCubit>(),
                      listener: (context, state) {
                        status = false;
                        if (state is SetProductRatingFailure) {
                          print("status:${state.errorStatusCode}--${state.errorCode}");
                          if (state.errorStatusCode.toString() == "102") {
                            reLogin(context);
                          }
                        }
                        if (state is SetProductRatingSuccess) {
                          context.read<OrderCubit>().updateOrderRateData(state.orderModel);
                          //UiUtils.setSnackBar(StringsRes.rating, StringsRes.updateSuccessFully, context, false);
                          status = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const ThankYouForReviewScreen(),
                            ),
                          );
                        } else if (state is SetProductRatingFailure) {
                          print(state.errorCode.toString());
                        }
                      },
                      builder: (context, state) {
                        return ButtonContainer(
                          color: Theme.of(context).colorScheme.secondary,
                          height: height,
                          width: width,
                          text: UiUtils.getTranslatedLabel(context, doneLabel),
                          start: width! / 40.0,
                          end: width! / 40.0,
                          bottom: height! / 55.0,
                          top: 0,
                          status: status,
                          borderColor: Theme.of(context).colorScheme.secondary,
                          textColor: white,
                          onPressed: () {
                            setState(() {
                              status = true;
                            });
                            context.read<SetOrderRatingCubit>().setOrderRating(context.read<AuthCubit>().getId(), widget.orderId,
                                ratingList[selectedIndex!].rating, commentController.text, reviewPhotos);
                          },
                        );
                      });
                }),
            body: Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0, start: width! / 20.0, end: width! / 20.0),
                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                          //height: height!/4.7,
                          width: width!,
                          margin: EdgeInsetsDirectional.only(bottom: height! / 99.0, top: height! / 99.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Text(UiUtils.getTranslatedLabel(context, howWasYourLabel),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 5.0),
                            Text(UiUtils.getTranslatedLabel(context, kindlyRateYourExperienceLabel),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 30.9),
                            const SizedBox(height: 8.0),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(UiUtils.getTranslatedLabel(context, didYouLikeTheTasteLabel),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                                  maxLines: 1),
                            ),
                            SizedBox(height: height! / 80.0),
                            rating(),
                            const SizedBox(height: 30.1),
                            ratingList.isEmpty
                                ? const SizedBox.shrink()
                                : Text(ratingList[selectedIndex!].title!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w600)),
                            comment(),
                            getImageField(),
                          ])),
                      orderData(),
                    ],
                  ),
                )));
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/order/orderDetailCubit.dart';
import 'package:project1/cubit/rating/setRiderRatingCubit.dart';
import 'package:project1/data/repositories/rating/ratingRepository.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/screen/rating/thank_you_for_review_screen.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:project1/utils/internetConnectivity.dart';

class RiderRatingScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating;
  const RiderRatingScreen(
      {Key? key, this.id, this.riderId, this.riderName, this.riderRating, this.riderImage, this.riderMobile, this.riderNoOfRating})
      : super(key: key);

  @override
  _RiderRatingScreenState createState() => _RiderRatingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SetRiderRatingCubit>(
              create: (_) => SetRiderRatingCubit(RatingRepository()),
              child: RiderRatingScreen(
                  id: arguments['id'] as String,
                  riderId: arguments['riderId'] as String,
                  riderName: arguments['riderName'] as String,
                  riderRating: arguments['riderRating'] as String,
                  riderImage: arguments['riderImage'] as String,
                  riderMobile: arguments['riderMobile'] as String,
                  riderNoOfRating: arguments['riderNoOfRating'] as String),
            ));
  }
}

class _RiderRatingScreenState extends State<RiderRatingScreen> {
  double? width, height;
  String? statusTipDeliveryPartner = "10";
  double? rating = 5.0;
  TextEditingController commentController = TextEditingController(text: "");
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
    print(
        "riderData:${widget.id}${widget.riderId}${widget.riderImage}${widget.riderRating}${widget.riderNoOfRating}${widget.riderName}${widget.riderMobile}");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    commentController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
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
          hintText: UiUtils.getTranslatedLabel(context, writeCommentLabel),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
                appBar: DesignConfig.appBar(context, width, UiUtils.getTranslatedLabel(context, reviewLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
                bottomNavigationBar: BlocConsumer<SetRiderRatingCubit, SetRiderRatingState>(
                    bloc: context.read<SetRiderRatingCubit>(),
                    listener: (context, state) {
                      if (state is SetRiderRatingFailure) {
                        if(state.errorStatusCode.toString() == "102"){
                          reLogin(context);
                        }
                      }
                      if (state is SetRiderRatingSuccess) {
                        context.read<OrderDetailCubit>().updateOrderRiderRateData(widget.id!, rating.toString());
                        //UiUtils.setSnackBar(StringsRes.rating, StringsRes.updateSuccessFully, context, false);
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const ThankYouForReviewScreen()));
                      } else if (state is SetRiderRatingFailure) {
                        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, ratingLabel), state.errorCode, context, false, type: "2");
                      }
                    },
                    builder: (context, state) {
                      /*if (state is SetRiderRatingFailure) {
                        UiUtils.setSnackBar(StringsRes.rating, state.errorCode, context, false, type: "2");
                      }*/
                      return ButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, submitLabel), start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0, top: 0, status: (state is SetRiderRatingProgress)?true:false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onPressed: () async {
                      context
                                .read<SetRiderRatingCubit>()
                                .setRiderRating(context.read<AuthCubit>().getId(), widget.riderId, rating.toString(), commentController.text, widget.id!);
                    },);
                    }),
                body: Container(
                    margin: EdgeInsetsDirectional.only(top: height! / 80.0), padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 40.0),
                    decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                    width: width, height: height!,
                    child: SingleChildScrollView(
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          children: [
                            Text(UiUtils.getTranslatedLabel(context, helpingYourDeliverPartnerByRatingLabel),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(Routes.riderRatingDetail, arguments: {'riderId': widget.riderId!});
                                },
                                child: Text(UiUtils.getTranslatedLabel(context, viewLabel),
                                    style: const TextStyle(fontSize: 12.0, color: lightFont, fontWeight: FontWeight.w500))),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(bottom: height! / 40.0, top: height! / 40.0),
                          child: Divider(
                            color: textFieldBorder.withOpacity(0.50),
                            height: 0.0,
                          ),
                        ),
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                child: DesignConfig.imageWidgets(widget.riderImage ?? "", 50, 50,"2")),
                            Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.riderName ?? "",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                          maxLines: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 15.0),
                                          Text(widget.riderRating ?? "" " ( ${widget.riderNoOfRating ?? ""} Review )",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      SizedBox(width: width! / 50.0),
                                      // SvgPicture.asset(DesignConfig.setSvgPath(restaurantList[index].status=="1"?"veg_icon" : "non_veg_icon"), width: 15, height: 15),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(bottom: height! / 40.0, top: height! / 40.0),
                          child: Divider(
                            color: textFieldBorder.withOpacity(0.50),
                            height: 0.0,
                          ),
                        ),
                        Center(
                            child: Text(UiUtils.getTranslatedLabel(context, howWasYourDeliveryPartnerLabel),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500))),
                        SizedBox(height: height! / 29.9),
                        Center(
                          child: RatingBar.builder(
                            glowColor: Theme.of(context).colorScheme.onSurface,
                            initialRating: rating!,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onRatingUpdate: (ratings) {
                              print(ratings);
                              setState(() {
                                rating = ratings; 
                              });
                            },
                            tapOnlyMode: true,
                          ),
                        ),
                        SizedBox(height: height! / 29.9),
                        Center(
                            child: Text(UiUtils.getTranslatedLabel(context, helpUsImproveOurServicesAndYourExperienceByRatingThisLabel),
                                textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12))),
                        /*Padding(
                        padding: EdgeInsetsDirectional.only(bottom: height !/ 40.0, top: height !/40.0),
                        child: Divider(color: textFieldBorder.withOpacity(0.50),
                          height: 0.0,),
                      ),*/
                        //Text(StringsRes.tipDeliveryPartner, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                        //SizedBox(height: height!/75.0),
                        //tipDeliveryPartner(),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height! / 40.0),
                          child: Divider(
                            color: textFieldBorder.withOpacity(0.50),
                            height: 0.0,
                          ),
                        ),
                        comment(),
                      ]),
                    ))));
  }
}

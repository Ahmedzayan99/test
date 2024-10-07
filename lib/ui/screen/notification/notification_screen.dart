import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/notificatiion/notificationCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/simmer/notificationSimmer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<NotificationCubit>(
              create: (_) => NotificationCubit(),
              child: const NotificationScreen(),
            ));
  }
}

class NotificationScreenState extends State<NotificationScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    Future.delayed(Duration.zero, () {
      context.read<NotificationCubit>().fetchNotification(perPage);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMoreData()) {
        context.read<NotificationCubit>().fetchMoreNotificationData(perPage);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget noNotificationData(){
    return NoDataContainer(
                  image: "no_notification",
                  title: UiUtils.getTranslatedLabel(context, noNotificationFoundLabel),
                  subTitle: UiUtils.getTranslatedLabel(context, noNotificationFoundSubTitleLabel),
                  width: width!,
                  height: height!);
  }

  Widget notificationData() {
    return BlocConsumer<NotificationCubit, NotificationState>(
        bloc: context.read<NotificationCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is NotificationProgress || state is NotificationInitial) {
            return NotificationSimmer(width: width, height: height);
          }
          if (state is NotificationFailure) {
            return noNotificationData(); //Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center));
          }
          final notificationList = (state as NotificationSuccess).notificationList;
          final hasMore = state.hasMore;
          return notificationList.isEmpty
              ? noNotificationData() 
              : ListView.builder(
                controller: controller,
                itemCount: notificationList.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return hasMore && index == (notificationList.length - 1)
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                      : GestureDetector(
                          onTap: () {
                            if (notificationList[index].type == "categories") {
                              Navigator.of(context).pushNamed(Routes.cuisineDetail,
                                  arguments: {'categoryId': notificationList[index].typeId!, 'name': UiUtils.getTranslatedLabel(context, deliciousCuisineLabel)});
                            } else {
                              UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, notificationLabel), StringsRes.normalNotification, context, false, type: "1");
                            }
                          },
                          child: Container(
                              margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, bottom: height! / 50.0),
                              decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                              width: width,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                    top: width! / 32.0, bottom: width! / 32.0, start: width! / 32.0, end: width! / 32.0),
                                child: Row(
                                  children: [
                                    Container(
                                        height: 39.0,
                                        width: 39.0,
                                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                        margin: EdgeInsetsDirectional.only(end: width! / 32.0),
                                        child: SvgPicture.asset(
                                                DesignConfig.setSvgPath("notification_thumb"),
                                                width: 10.0,
                                                height: 10.0,
                                              )),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notificationList[index].title!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                                            maxLines: 2,
                                          ),
                                          //const SizedBox(height: 7),
                                          Text(notificationList[index].message!,
                                              textAlign: TextAlign.start,
                                              maxLines: 2,
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        );
                },
              );
        });
  }

  Future<void> refreshList() async {
    context.read<NotificationCubit>().fetchNotification(perPage);
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, notificationLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  //decoration: DesignConfig.boxCurveShadow(ColorsRes.white),
                  width: width, height: height! / 1.1,
                  child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: notificationData())),
            ),
    );
  }
}

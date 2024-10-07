import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/faq/faqsCubit.dart';
import 'package:project1/data/repositories/faq/faqsRepository.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project1/utils/internetConnectivity.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({Key? key}) : super(key: key);

  @override
  FaqsScreenState createState() => FaqsScreenState();
  static Route<FaqsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FaqsCubit>(
              create: (_) => FaqsCubit(
                FaqsRepository(),
              ),
              child: const FaqsScreen(),
            ));
  }
}

class FaqsScreenState extends State<FaqsScreen> {
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
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    context.read<FaqsCubit>().fetchFaqs();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Widget noFaqsData() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noSectionYetLabel),
        subTitle:UiUtils.getTranslatedLabel(context, noSectionYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget faqs() {
    return BlocConsumer<FaqsCubit, FaqsState>(
        bloc: context.read<FaqsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FaqsProgress || state is FaqsInitial) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }
          if (state is FaqsFailure) {
            return noFaqsData();
          }
          final faqsList = (state as FaqsSuccess).faqsList;
          return faqsList.isEmpty?noFaqsData():ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: faqsList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsetsDirectional.only(top: index==0?0.0:height! / 80.0, start: width!/ 20.0, end: width! / 20.0),
                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                  child: Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      childrenPadding: EdgeInsets.zero,
                      iconColor: lightFont,
                      collapsedIconColor: lightFont,
                      expandedAlignment: Alignment.topLeft,
                      onExpansionChanged: (bool isExpanded) {
                        setState(() {
                          faqsList[index].isExpanded = isExpanded;
                        });
                      },
                      title: Text(
                        faqsList[index].question!,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500
                        ),
                      ),
                      trailing: Icon(
                                  faqsList[index].isExpanded==true?Icons.remove_circle_sharp:Icons.add_circle_sharp,
                                  color: Theme.of(context).colorScheme.primary,
                              ),
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: width! / 24.0, bottom: height! / 40.0),
                          child: Text(faqsList[index].answer!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.normal,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Future<void> refreshList() async {
    context.read<FaqsCubit>().fetchFaqs();
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, faqsLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: Container(height: height!,padding: EdgeInsetsDirectional.only(top: height!/ 80.0),
                width: width,
                child: RefreshIndicator(
                      onRefresh: refreshList,
                      color: Theme.of(context).colorScheme.primary,
                      child: faqs(),
                ),
              )),
    );
  }
}

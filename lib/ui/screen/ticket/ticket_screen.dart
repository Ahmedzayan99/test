import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/helpAndSupport/ticketCubit.dart';
import 'package:project1/ui/screen/ticket/chat_screen.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/simmer/addressSimmer.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/smallButtomContainer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project1/utils/internetConnectivity.dart';
import 'package:intl/intl.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  TicketScreenState createState() => TicketScreenState();
}

class TicketScreenState extends State<TicketScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
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
      context.read<TicketCubit>().fetchTicket(perPage, context.read<AuthCubit>().getId());
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TicketCubit>().hasMoreData()) {
        context.read<TicketCubit>().fetchMoreTicketData(perPage, context.read<AuthCubit>().getId());
      }
    }
  }

  Widget noTransactionData() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noSectionYetLabel),
        subTitle:UiUtils.getTranslatedLabel(context, noSectionYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget ticket() {
    return BlocConsumer<TicketCubit, TicketState>(
        bloc: context.read<TicketCubit>(),
        listener: (context, state) {
          if (state is TicketFailure) {
            print("stateScreen:${state.errorStatusCode.toString()}");
            if(state.errorStatusCode.toString() == "102"){
              reLogin(context);
            }
          }
        },
        builder: (context, state) {
          if (state is TicketProgress || state is TicketInitial) {
            return AddressSimmer(width: width, height: height);
          }
          
          if (state is TicketFailure) {
            print("data:${state.errorMessage}");
            return noTransactionData();
          }
          final ticketList = (state as TicketSuccess).ticketList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.1,
              child: ticketList.isEmpty? noTransactionData():ListView.builder(
                  controller: controller,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: ticketList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (ticketList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsetsDirectional.only(
                                start: width! / 30.0,
                                top: height! / 40.0,
                                end: width! / 30.0,
                              ),
                              //height: height!/4.7,
                              width: width!,
                              margin: EdgeInsetsDirectional.only(top: index==0?0.0:height! / 52.0, start: width! / 20.0, end: width! / 20.0),
                              decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.onSurface, 10.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text("${UiUtils.getTranslatedLabel(context, dateLabel)} :",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontStyle:  FontStyle.normal,
                                        fontSize: 14.0)),
                                  Text(formatter.format(DateTime.parse(ticketList[index].dateCreated!)),
                                      textAlign: TextAlign.center, style: TextStyle(
                                      color:  Theme.of(context).colorScheme.onSecondary,
                                      fontWeight: FontWeight.normal,
                                      fontStyle:  FontStyle.normal,
                                      fontSize: 14.0)),
                                      SizedBox(height: height! / 60.0),
                                  Text("${UiUtils.getTranslatedLabel(context, typeLabel)} : ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0)
                                      ),
                                  Text(ticketList[index].ticketType!,
                                      textAlign: TextAlign.center, style: TextStyle(
                                      color:  Theme.of(context).colorScheme.onSecondary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0)),
                                  SizedBox(height: height! / 60.0),
                                  Text("${UiUtils.getTranslatedLabel(context, subjectLabel)} :",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0)),
                                  Text(ticketList[index].subject!,
                                      textAlign: TextAlign.center, style: TextStyle(
                                      color:  Theme.of(context).colorScheme.onSecondary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0)),
                                  SizedBox(height: height! / 60.0),
                                  Text("${UiUtils.getTranslatedLabel(context, messageLabel)} :",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0)),
                                  Text(ticketList[index].description!,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                      color:  Theme.of(context).colorScheme.onSecondary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0),
                                      maxLines: 2),
                                  SizedBox(height: height! / 60.0),
                                  DesignConfig.divider(),
                                  Row(mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SmallButtonContainer(color: Theme.of(context).colorScheme.onSurface, height: height, width: width, text: UiUtils.getTranslatedLabel(context, editLabel), start: 0, end: width! / 40.0, bottom: height!/80.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: Theme.of(context).colorScheme.onSecondary, onTap: (){
                                              Navigator.of(context).pushNamed(Routes.addTicket, arguments: {
                                              'id': int.parse(ticketList[index].id!),
                                              'typeId': int.parse(ticketList[index].ticketTypeId!),
                                              'email': ticketList[index].email!,
                                              'subject': ticketList[index].subject!,
                                              'message': ticketList[index].description!,
                                              'status': ticketList[index].status!,
                                              'from': 'editTicket'
                                            });
                                            print("${int.parse(ticketList[index].ticketTypeId!)}-${ticketList[index].status!}");
                                    },),
                                    SmallButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, chatLabel), start: width! / 99.0, end: width! / 40.0, bottom: height!/80.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onTap: (){
                                              Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChatScreen(id: ticketList[index].id!, status: ticketList[index].status!)),
                                            );
                                    },)  
                                  ],
                                ),
                                  SizedBox(height: height! / 99.0),
                                ]),
                              ),
                            ),
                          );
                  }));
        });
  }

  Future<void> refreshList() async {
    context.read<TicketCubit>().fetchTicket(perPage, context.read<AuthCubit>().getId());
  }

  @override
  void dispose() {
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, helpAndSupportLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              bottomNavigationBar: ButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, askQuestionLabel), start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0, top:0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onPressed: (){
                        Navigator.of(context).pushNamed(Routes.addTicket, arguments: {'id': 0,
                        'typeId': 0,
                        'email': "",
                        'subject': "",
                        'message': "",
                        'status': "",
                        'from': "addTicket"});
                        }),                
              body: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: ticket())),
            ),
    );
  }
}

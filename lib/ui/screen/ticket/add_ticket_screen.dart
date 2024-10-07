import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/helpAndSupport/addTicketCubit.dart';
import 'package:project1/cubit/helpAndSupport/editTicketCubit.dart';
import 'package:project1/cubit/helpAndSupport/helpAndSupportCubit.dart';
import 'package:project1/cubit/helpAndSupport/ticketCubit.dart';
import 'package:project1/data/model/ticketStatusType.dart';
import 'package:project1/data/repositories/helpAndSupport/helpAndSupportRepository.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/utils/internetConnectivity.dart';

class AddTicketScreen extends StatefulWidget {
  final int? id, typeId;
  final String? email, subject, message, status, from;
  const AddTicketScreen({Key? key, this.id, this.typeId, this.email, this.subject, this.message, this.status, this.from}) : super(key: key);

  @override
  AddTicketScreenState createState() => AddTicketScreenState();
  static Route<AddTicketScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;  
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<HelpAndSupportCubit>(create: (_) => HelpAndSupportCubit(HelpAndSupportRepository())),
                BlocProvider<AddTicketCubit>(create: (_) => AddTicketCubit(HelpAndSupportRepository())),
                BlocProvider<EditTicketCubit>(create: (_) => EditTicketCubit(HelpAndSupportRepository())),
              ],
              child: AddTicketScreen(
                  id: arguments['id'] as int,
                  typeId: arguments['typeId'] as int,
                  email: arguments['email'] as String,
                  subject: arguments['subject'],
                  message: arguments['message'] as String,
                  status: arguments['status'] as String,
                  from: arguments['from'] as String),
            ));
  }
}

class AddTicketScreenState extends State<AddTicketScreen> {
  double? width, height;
  bool enableList = false, enableTicketStatusTypeList = false;
  int? _selectedIndex, _selectedTicketStatusTypeIndex;
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController subjectController = TextEditingController(text: "");
  TextEditingController messageController = TextEditingController(text: "");
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? ticketTypeId;

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
  /*  _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    context.read<HelpAndSupportCubit>().fetchHelpAndSupport();
    if(widget.from=="editTicket"){
    emailController = TextEditingController(text: widget.email);
    subjectController = TextEditingController(text: widget.subject);
    messageController = TextEditingController(text: widget.message);
    _selectedIndex = widget.typeId;}
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  onChanged(int position) {
    setState(() {
      _selectedIndex = position;
      enableList = !enableList;
    });
  }

  onTap() {
    setState(() {
      enableList = !enableList;
    });
  }

  onChangedTicketTypeStatus(int position) {
    setState(() {
      _selectedTicketStatusTypeIndex = position;
      enableTicketStatusTypeList = !enableTicketStatusTypeList;
    });
  }

  onTapTicketTypeStatus() {
    setState(() {
      enableTicketStatusTypeList = !enableTicketStatusTypeList;
    });
  }

  Widget selectType() {
    return BlocConsumer<HelpAndSupportCubit, HelpAndSupportState>(
        bloc: context.read<HelpAndSupportCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is HelpAndSupportProgress || state is HelpAndSupportInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HelpAndSupportFailure) {
            return const Center(child: Text(""));
          }
          final helpAndSupportList = (state as HelpAndSupportSuccess).helpAndSupportList;
          if(widget.from=="editTicket"){
          _selectedIndex = helpAndSupportList.indexWhere((element) => element.id == widget.typeId.toString());}
          return Container(
            decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
            margin: EdgeInsetsDirectional.only(top: height! / 99.0),
            child: Column(
              children: [
                InkWell(
                  onTap: onTap,
                  child: Container(
                    decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
                    padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          _selectedIndex != null ? helpAndSupportList[_selectedIndex!].title! : UiUtils.getTranslatedLabel(context, selectTypeLabel),
                          style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                        )),
                        Icon(enableList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: Theme.of(context).colorScheme.onSecondary),
                      ],
                    ),
                  ),
                ),
                enableList
                    ? ListView.builder(
                        padding: EdgeInsetsDirectional.only(top: height! / 99.9, bottom: height! / 99.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemCount: helpAndSupportList.length,
                        itemBuilder: (context, position) {
                          return InkWell(
                            onTap: () {
                              onChanged(position);
                              ticketTypeId = helpAndSupportList[position].id!;
                            },
                            child: Container(
                                padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      helpAndSupportList[position].title!,
                                      style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(top: height! / 99.0),
                                      child: DesignConfig.divider(),
                                    ),
                                  ],
                                )),
                          );
                        })
                    : Container(),
              ],
            ),
          );
        });
  }

  Widget selectTicketStatusTypeType() {
    _selectedTicketStatusTypeIndex = ticketStatusList.indexWhere((element) => element.id == widget.status.toString());
    return Container(
      decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
      margin: EdgeInsetsDirectional.only(top: height! / 99.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTapTicketTypeStatus,
            child: Container(
              decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 10.0),
              padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    _selectedTicketStatusTypeIndex != null ? ticketStatusList[_selectedTicketStatusTypeIndex!].title! : UiUtils.getTranslatedLabel(context, selectTypeLabel),
                    style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                  )),
                  Icon(enableTicketStatusTypeList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: Theme.of(context).colorScheme.onSecondary),
                ],
              ),
            ),
          ),
          enableTicketStatusTypeList
              ? ListView.builder(
                  padding: EdgeInsetsDirectional.only(top: height! / 99.9, bottom: height! / 99.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: ticketStatusList.length,
                  itemBuilder: (context, position) {
                    return InkWell(
                      onTap: () {
                        onChangedTicketTypeStatus(position);
                        //ticketTypeId = helpAndSupportList[position].id!;
                      },
                      child: Container(
                          padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticketStatusList[position].title!,
                                style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0),
                                child: DesignConfig.divider(),
                              ),
                            ],
                          )),
                    );
                  })
              : Container(),
        ],
      ),
    );
  }

  Widget email() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
      margin: EdgeInsetsDirectional.only(top: height! / 60.0),
      child: TextField(
        controller: emailController,
        cursorColor: Theme.of(context).colorScheme.onSecondary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: UiUtils.getTranslatedLabel(context, emailLabel),
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
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget subject() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
      margin: EdgeInsetsDirectional.only(top: height! / 60.0),
      child: TextField(
        controller: subjectController,
        cursorColor: Theme.of(context).colorScheme.onSecondary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: UiUtils.getTranslatedLabel(context, subjectLabel),
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
      ),
    );
  }

  Widget message() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
      margin: EdgeInsetsDirectional.only(top: height! / 60.0),
      child: TextField(
        controller: messageController,
        cursorColor: Theme.of(context).colorScheme.onSecondary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: UiUtils.getTranslatedLabel(context, messageLabel),
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
  void dispose() {
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
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
              bottomNavigationBar: widget.from=="editTicket"?BlocConsumer<EditTicketCubit, EditTicketState>(
                bloc: context.read<EditTicketCubit>(),
                listener: (context, state) {
                  if (state is EditTicketFailure) {
                      if(state.errorStatusCode.toString() == "102"){
                        reLogin(context);
                      }
                    }
                  if (state is EditTicketSuccess) {
                    context.read<TicketCubit>().editTicket(state.ticketModel);
                    Navigator.pop(context);
                    //UiUtils.setSnackBar(StringsRes.ticketUpdate, StringsRes.ticketUpdateSuccessfully, context, false, type: "1");
                    emailController.clear();
                    subjectController.clear();
                    messageController.clear();
                  }
                },
                builder: (context, state) {
                  return ButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, sendMessageLabel), start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0, top:0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onPressed: (){
                        if (emailController.text.isEmpty) {
                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, emailLabel), StringsRes.enterEmail, context, false, type: "2");
                        } else if (subjectController.text.isEmpty) {
                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, subjectLabel), StringsRes.enterSubject, context, false, type: "2");
                        } else if (messageController.text.isEmpty) {
                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, messageLabel), StringsRes.enterMessage, context, false, type: "2");
                        } else if (_selectedIndex.toString().isEmpty) {
                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, selectTypeLabel), StringsRes.selectYourQuestion, context, false, type: "2");
                        } else {
                          context.read<EditTicketCubit>().fetchEditTicket(widget.id.toString(), widget.typeId.toString(), subjectController.text,
                              emailController.text, messageController.text, context.read<AuthCubit>().getId(), widget.status);
                          emailController.clear();
                          subjectController.clear();
                          messageController.clear();
                        }
                    },);
                },
              ):BlocConsumer<AddTicketCubit, AddTicketState>(
                  bloc: context.read<AddTicketCubit>(),
                  listener: (context, state) {
                    if (state is AddTicketFailure) {
                      if(state.errorStatusCode.toString() == "102"){
                        reLogin(context);
                      }
                    }
                    if (state is AddTicketSuccess) {
                      //UiUtils.setSnackBar(StringsRes.ticketAdd, StringsRes.ticketAddSuccessfully, context, false, type: "1");
                      context.read<TicketCubit>().addTicket(state.ticketModel);
                      Navigator.pop(context);
                      emailController.clear();
                      subjectController.clear();
                      messageController.clear();
                    }
                  },
                  builder: (context, state) {
                    return ButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, sendMessageLabel), start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0, top:0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onPressed: (){
                          if (emailController.text.isEmpty) {
                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, emailLabel), StringsRes.enterEmail, context, false, type: "2");
                          } else if (subjectController.text.isEmpty) {
                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, subjectLabel), StringsRes.enterSubject, context, false, type: "2");
                          } else if (messageController.text.isEmpty) {
                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, messageLabel), StringsRes.enterMessage, context, false, type: "2");
                          } else if (_selectedIndex.toString().isEmpty) {
                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, selectTypeLabel), StringsRes.selectYourQuestion, context, false, type: "2");
                          } else {
                            print(_selectedIndex);
                            context.read<AddTicketCubit>().fetchAddTicket(ticketTypeId.toString(), subjectController.text, emailController.text,
                                messageController.text, context.read<AuthCubit>().getId());
                          }
                    },);
                  }),
              body: Container(height: height!, padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                width: width,
                child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: EdgeInsetsDirectional.only(start: width! / 30.0, end: width! / 30.0, top: height! / 80.0, bottom: height!/80.0), decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.onSurface, 10.0), child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(StringsRes.selectYourQuestion,
                          style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: 5.0),
                          child: DesignConfig.divider(),
                        ),
                        selectType(),
                      ],
                    )),
                    widget.from=="editTicket"?Container(margin: EdgeInsetsDirectional.only(top: height!/70.0), padding: EdgeInsetsDirectional.only(start: width! / 30.0, end: width! / 30.0, top: height! / 80.0, bottom: height!/80.0), decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.onSurface, 10.0), child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(UiUtils.getTranslatedLabel(context, questionsLabel),
                          style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: 5.0),
                          child: DesignConfig.divider(),
                        ),
                        selectTicketStatusTypeType(),
                      ],
                    )) : const SizedBox(),
                    Container(margin: EdgeInsetsDirectional.only(top: height!/70.0), padding: EdgeInsetsDirectional.only(start: width! / 30.0, end: width! / 30.0, top: height! / 80.0, bottom: height!/80.0), decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.onSurface, 10.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(UiUtils.getTranslatedLabel(context, messageLabel),
                          style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: 2.0),
                          child: DesignConfig.divider(),
                        ),
                        email(),
                        subject(),
                        message(),
                      ],
                    )),
                  ]),
                ),
              )),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/order/orderDetailCubit.dart';
import 'package:project1/data/model/addOnsDataModel.dart';
import 'package:project1/data/model/orderModel.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/styles/dashLine.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/simmer/orderDetailSimmer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:open_file/open_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:project1/utils/internetConnectivity.dart';

class OrderDetailScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating, isSelfPickup, from;
  const OrderDetailScreen(
      {Key? key,
      this.id,
      this.riderId,
      this.riderName,
      this.riderRating,
      this.riderImage,
      this.riderMobile,
      this.riderNoOfRating,
      this.isSelfPickup,
      this.from})
      : super(key: key);

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => OrderDetailScreen(
            id: arguments['id'] as String,
            riderId: arguments['riderId'] as String,
            riderName: arguments['riderName'] as String,
            riderRating: arguments['riderRating'] as String,
            riderImage: arguments['riderImage'] as String,
            riderMobile: arguments['riderMobile'] as String,
            riderNoOfRating: arguments['riderNoOfRating'] as String,
            isSelfPickup: arguments['isSelfPickup'] as String,
            from: arguments['from'] as String));
  }
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  double? width, height, latitude = 0.0, longitude = 0.0;
  int selectedIndex = 0;
  Future<List<Directory>?>? _externalStorageDirectories;
  bool _isProgress = false;
  ScrollController orderController = ScrollController();
  String invoice = "", mobileNumber = "", activeStatusOrder = "";
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
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
    print(widget.from);
    _externalStorageDirectories = getExternalStorageDirectories(type: StorageDirectory.downloads);
    Future.delayed(Duration.zero, () {
      context.read<OrderDetailCubit>().fetchOrderDetail(perPage, context.read<AuthCubit>().getId(), widget.id!, "");
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  downloadInvoice() {
    return FutureBuilder<List<Directory>?>(
        future: _externalStorageDirectories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return /*_isProgress
              ? SizedBox(height: height! / 15.0, child: const Center(child: CircularProgressIndicator(color: red)))
              : */
              ButtonContainer(
            color: Theme.of(context).colorScheme.secondary,
            height: height,
            width: width,
            text: UiUtils.getTranslatedLabel(context, downloadBillLabel),
            start: width! / 40.0,
            end: width! / 40.0,
            bottom: height! / 55.0,
            top: 0,
            status: _isProgress,
            borderColor: Theme.of(context).colorScheme.secondary,
            textColor: white,
            onPressed: () async {
              setState(() {
                _isProgress = true;
              });
              /* final status = await Permission.storage.request();
                    // final per=await  Permission.manageExternalStorage.request();

                    if (status == PermissionStatus.granted) {
                      if (mounted) {
                        setState(() {
                          _isProgress = true;
                        });
                      }
                      /*var targetPath;

                      if (Platform.isIOS) {
                        var target = await getApplicationDocumentsDirectory();
                        targetPath = target.path.toString();
                      } else {
                        if (snapshot.hasData) {
                          targetPath = snapshot.data!.map((Directory d) => d.path).join(', ');

                          print("dir path****$targetPath");
                        }
                      }

                      var targetFileName = "Invoice_${widget.id}";
                      var generatedPdfFile, filePath;
                      try {
                        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath, targetFileName);
                        filePath = generatedPdfFile.path;
                      } on Exception {
                        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath, targetFileName);
                        filePath = generatedPdfFile.path;
                      }*/

                      Object? targetPath;

                      if (Platform.isIOS) {
                        var target = await getApplicationDocumentsDirectory();
                        targetPath = target.path.toString();
                      } else {
                        targetPath = '/storage/emulated/0/Download';
                        if (!await Directory(targetPath.toString()).exists()) {
                          targetPath = await getExternalStorageDirectory();
                        }
                      }

                      var targetFileName = 'Invoice_${widget.id}';
                      var generatedPdfFile, filePath;
                      try {
                        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath.toString(), targetFileName);
                        filePath = generatedPdfFile.path;
                        

                        File fileDef = File(filePath);
                        await fileDef.create(recursive: true);
                        Uint8List bytes = await generatedPdfFile.readAsBytes();
                        await fileDef.writeAsBytes(bytes);
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            _isProgress = false;
                          });
                          //setSnackbar('Something went wrong');
                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, downloadBillLabel), StringsRes.somethingWentWrong, context, false, type: "2");
                        }
                        return;
                      }

                      if (mounted) {
                        setState(() {
                          _isProgress = false;
                        });
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "${UiUtils.getTranslatedLabel(context, invoicePathLabel)} $targetFileName",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: white),
                        ),
                        action: SnackBarAction(
                            label: UiUtils.getTranslatedLabel(context, viewLabel),
                            textColor: white,
                            onPressed: () async {
                              /* final result =  */await OpenFilex.open(filePath);
                            }),
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        elevation: 1.0,
                      ));
                    } */
              bool hasPermission = await checkPermission();
              String target = Platform.isAndroid && hasPermission
                  ? (await ExternalPath.getExternalStoragePublicDirectory(
                      ExternalPath.DIRECTORY_DOWNLOADS,
                    ))
                  : (await getApplicationDocumentsDirectory()).path;

              var targetFileName = 'Invoice_${widget.id}';
              var generatedPdfFile, filePath;
              try {
                // generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, target, targetFileName);
                filePath = generatedPdfFile.path;

                File fileDef = File(filePath);
                await fileDef.create(recursive: true);
                Uint8List bytes = await generatedPdfFile.readAsBytes();
                await fileDef.writeAsBytes(bytes);
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isProgress = false;
                  });
                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, downloadBillLabel), StringsRes.somethingWentWrong, context, false,
                      type: "2");
                }
                return;
              }

              if (mounted) {
                setState(() {
                  _isProgress = false;
                });
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "${UiUtils.getTranslatedLabel(context, invoicePathLabel)} $targetFileName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: white),
                ),
                action: SnackBarAction(
                    label: UiUtils.getTranslatedLabel(context, viewLabel),
                    textColor: white,
                    onPressed: () async {
                      await OpenFilex.open(filePath);
                    }),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 1.0,
              ));
            },
          );
          /* TextButton(
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () async {
                    final status = await Permission.storage.request();
                    // final per=await  Permission.manageExternalStorage.request();

                    if (status == PermissionStatus.granted) {
                      if (mounted) {
                        setState(() {
                          _isProgress = true;
                        });
                      }
                      /*var targetPath;

                      if (Platform.isIOS) {
                        var target = await getApplicationDocumentsDirectory();
                        targetPath = target.path.toString();
                      } else {
                        if (snapshot.hasData) {
                          targetPath = snapshot.data!.map((Directory d) => d.path).join(', ');

                          print("dir path****$targetPath");
                        }
                      }

                      var targetFileName = "Invoice_${widget.id}";
                      var generatedPdfFile, filePath;
                      try {
                        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath, targetFileName);
                        filePath = generatedPdfFile.path;
                      } on Exception {
                        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath, targetFileName);
                        filePath = generatedPdfFile.path;
                      }*/

                      Object? targetPath;

                      if (Platform.isIOS) {
                        var target = await getApplicationDocumentsDirectory();
                        targetPath = target.path.toString();
                      } else {
                        targetPath = '/storage/emulated/0/Download';
                        if (!await Directory(targetPath.toString()).exists()) {
                          targetPath = await getExternalStorageDirectory();
                        }
                      }

                      var targetFileName = 'Invoice_${widget.id}';
                      var generatedPdfFile, filePath;
                      try {
                        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath.toString(), targetFileName);
                        filePath = generatedPdfFile.path;

                        File fileDef = File(filePath);
                        await fileDef.create(recursive: true);
                        Uint8List bytes = await generatedPdfFile.readAsBytes();
                        await fileDef.writeAsBytes(bytes);
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            _isProgress = false;
                          });
                          //setSnackbar('Something went wrong');
                          UiUtils.setSnackBar(StringsRes.downloadBill, StringsRes.somethingWentWrong, context, false, type: "2");
                        }
                        return;
                      }

                      if (mounted) {
                        setState(() {
                          _isProgress = false;
                        });
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "${StringsRes.invoicePath} $targetFileName",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: white),
                        ),
                        action: SnackBarAction(
                            label: StringsRes.view,
                            textColor: white,
                            onPressed: () async {
                              final result = await OpenFile.open(filePath);
                            }),
                        backgroundColor: green,
                        elevation: 1.0,
                      ));
                    }
                  },
                  child: Container(
                      height: height! / 15.0,
                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 20.0, end: width! / 20.0),
                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSecondary, 100.0),
                      child: _isProgress
                          ? const Center(child: CircularProgressIndicator(color: white))
                          : Text(StringsRes.downloadBill,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500)))) */
        });
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
          invoice = orderList[0].invoiceHtml!;
          latitude = double.parse(orderList[0].orderItems![0].partnerDetails![0].latitude!);
          longitude = double.parse(orderList[0].orderItems![0].partnerDetails![0].longitude!);
          mobileNumber = orderList[0].orderItems![0].partnerDetails![0].mobile!;
          activeStatusOrder = orderList[0].activeStatus!;
          return SizedBox(
              height: height! / 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orderList.length,
                  itemBuilder: (BuildContext context, index) {
                    var status = "";
                    if (orderList[index].activeStatus! == deliveredKey) {
                      status = UiUtils.getTranslatedLabel(context, deliveredLabel);
                    } else if (orderList[index].activeStatus! == pendingKey) {
                      status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                    } else if (orderList[index].activeStatus! == waitingKey) {
                      status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                    } else if (orderList[index].activeStatus! == receivedKey) {
                      status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                    } else if (orderList[index].activeStatus! == outForDeliveryKey) {
                      status = UiUtils.getTranslatedLabel(context, outForDeliveryLbLabel);
                    } else if (orderList[index].activeStatus! == confirmedKey) {
                      status = UiUtils.getTranslatedLabel(context, confirmedLbLabel);
                    } else if (orderList[index].activeStatus! == cancelledKey) {
                      status = UiUtils.getTranslatedLabel(context, cancelLabel);
                    } else if (orderList[index].activeStatus! == preparingKey) {
                      status = UiUtils.getTranslatedLabel(context, preparingLbLabel);
                    } else {
                      status = "";
                    }
                    return Container(
                        padding: EdgeInsetsDirectional.only(start: width! / 60.0, end: width! / 60.0, bottom: height! / 99.0),
                        width: width!,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            orderList[index].activeStatus == cancelledKey
                                ? const SizedBox()
                                : orderList[index].isSelfPickUp == "1"
                                    ? const SizedBox()
                                    : Container(
                                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 80.0,
                                          bottom: height! / 80.0,
                                          start: width! / 40.0,
                                          end: width! / 40.0,
                                        ),
                                        margin: EdgeInsetsDirectional.only(bottom: height! / 80.0),
                                        child: Row(children: [
                                          Text(UiUtils.getTranslatedLabel(context, otpLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              )),
                                          const Spacer(),
                                          Text(orderList[index].otp!,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.8,
                                                  fontStyle: FontStyle.normal)),
                                        ]),
                                      ),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                padding:
                                    EdgeInsetsDirectional.only(top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        UiUtils.getTranslatedLabel(context, orderFromLabel),
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 99.0,
                                          bottom: height! / 80.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                      Text(orderList[index].orderItems![0].partnerDetails![0].partnerName!,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSecondary,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal)),
                                      const SizedBox(height: 2.0),
                                      Text(orderList[index].orderItems![0].partnerDetails![0].partnerAddress!,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                          )),
                                    ])),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                                padding:
                                    EdgeInsetsDirectional.only(top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                                          alignment: Alignment.center,
                                          height: 40.0,
                                          width: 40,
                                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 10.0),
                                          child: Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface)),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("${UiUtils.getTranslatedLabel(context, orderLabel)} $status",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal)),
                                            Text("${UiUtils.getTranslatedLabel(context, yourOrderLabel)} $status",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal)),
                                            Text(orderList[index].dateAdded!,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  (orderList[index].reason!.isEmpty || orderList[index].reason == "")
                                      ? const SizedBox()
                                      : Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 80.0,
                                          ),
                                          child: DesignConfig.divider(),
                                        ),
                                  (orderList[index].reason!.isEmpty || orderList[index].reason == "")
                                      ? const SizedBox()
                                      : Text("${UiUtils.getTranslatedLabel(context, orderCancelDueToLabel)} ${orderList[index].reason}",
                                          textAlign: TextAlign.start,
                                          maxLines: 2,
                                          style:
                                              TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
                                ])),
                            orderList[index].isSelfPickUp == "0"
                                ? const SizedBox()
                                : orderList[index].ownerNote!.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                        margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                UiUtils.getTranslatedLabel(context, partnerNoteLabel),
                                                style: TextStyle(
                                                    fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional.only(
                                                  top: height! / 99.0,
                                                  bottom: height! / 80.0,
                                                ),
                                                child: DesignConfig.divider(),
                                              ),
                                              Text(orderList[index].ownerNote!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                            ])),
                            orderList[index].isSelfPickUp == "0"
                                ? const SizedBox()
                                : orderList[index].selfPickupTime!.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                        margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                UiUtils.getTranslatedLabel(context, pickupTimeLabel),
                                                style: TextStyle(
                                                    fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional.only(
                                                  top: height! / 99.0,
                                                  bottom: height! / 80.0,
                                                ),
                                                child: DesignConfig.divider(),
                                              ),
                                              Text(orderList[index].selfPickupTime!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                            ])),
                            Container(
                              decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                              margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                              padding:
                                  EdgeInsetsDirectional.only(top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        UiUtils.getTranslatedLabel(context, orderDetailsLabel),
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "#${orderList[index].id!}",
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      top: height! / 99.0,
                                      bottom: height! / 80.0,
                                    ),
                                    child: DesignConfig.divider(),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(orderList[index].orderItems!.length, (i) {
                                      OrderItems data = orderList[index].orderItems![i];
                                      return InkWell(
                                          onTap: () {},
                                          child: Container(
                                              width: width!,
                                              margin: EdgeInsetsDirectional.only(top: height! / 99.0),
                                              child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(children: [
                                                      data.indicator == "1"
                                                          ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                          : data.indicator == "2"
                                                              ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                              : const SizedBox(height: 15, width: 15.0),
                                                      const SizedBox(width: 5.0),
                                                      Text(
                                                        "${data.quantity!} x ",
                                                        textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                                        style: const TextStyle(
                                                            color: lightFont,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            overflow: TextOverflow.ellipsis),
                                                        maxLines: 1,
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                          data.name!,
                                                          textAlign:
                                                              Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.onSecondary,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                              overflow: TextOverflow.ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text("${context.read<SystemConfigCubit>().getCurrency()}${data.price!}",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.primary,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w700)),
                                                    ]),
                                                    orderList[index].orderItems![i].attrName != ""
                                                        ? Container(
                                                            margin: EdgeInsetsDirectional.only(start: width! / 16.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text("${orderList[index].orderItems![i].attrName!} : ",
                                                                    textAlign: TextAlign.left,
                                                                    style:
                                                                        const TextStyle(color: lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                Text(orderList[index].orderItems![i].variantValues!,
                                                                    textAlign: TextAlign.left,
                                                                    style: const TextStyle(
                                                                        color: lightFont, fontSize: 12, overflow: TextOverflow.ellipsis),
                                                                    maxLines: 1),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                    const SizedBox(height: 5.0),
                                                    Wrap(
                                                        spacing: 5.0,
                                                        runSpacing: 2.0,
                                                        direction: Axis.horizontal,
                                                        children: List.generate(orderList[index].orderItems![i].addOns!.length, (j) {
                                                          AddOnsDataModel addOnData = orderList[index].orderItems![i].addOns![j];
                                                          return Container(
                                                            width: width!,
                                                            margin: EdgeInsetsDirectional.only(start: width! / 16.0),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text("${addOnData.qty!} x ${addOnData.title!}",
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(
                                                                          color: lightFontColor, fontSize: 10, overflow: TextOverflow.ellipsis),
                                                                      maxLines: 2),
                                                                  Text("${context.read<SystemConfigCubit>().getCurrency()}${addOnData.price!}, ",
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                          color: Theme.of(context).colorScheme.primary,
                                                                          fontSize: 10,
                                                                          overflow: TextOverflow.ellipsis)),
                                                                ]),
                                                          );
                                                        }))
                                                  ])));
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                                padding:
                                    EdgeInsetsDirectional.only(top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        UiUtils.getTranslatedLabel(context, deliveryLocationLabel),
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 99.0,
                                          bottom: height! / 80.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                      Text(context.read<AuthCubit>().getName(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSecondary,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal)),
                                      const SizedBox(height: 2.0),
                                      Text(orderList[index].address!,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                          )),
                                    ])),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                                margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                                padding:
                                    EdgeInsetsDirectional.only(top: height! / 80, start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(UiUtils.getTranslatedLabel(context, billDetailLabel),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                          )),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.only(
                                          top: 4.5,
                                          bottom: 4.5,
                                        ),
                                        child: Divider(
                                          color: lightFont.withOpacity(0.50),
                                          height: 1.0,
                                        ),
                                      ),
                                      Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, subTotalLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(
                                            context.read<SystemConfigCubit>().getCurrency() +
                                                (double.parse(orderList[index].total!)).toStringAsFixed(2),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                      const SizedBox(height: 4.0),
                                      Row(children: [
                                        Text(
                                            "${UiUtils.getTranslatedLabel(context, chargesAndTaxesLabel)} (${orderList[index].totalTaxPercent!}${StringsRes.percentSymbol})",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(context.read<SystemConfigCubit>().getCurrency() + orderList[index].totalTaxAmount!,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                      const Padding(
                                        padding: EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                                        child: DashLineView(
                                          fillRate: 0.7,
                                          direction: Axis.horizontal,
                                        ),
                                      ),
                                      Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, totalLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(
                                            "${context.read<SystemConfigCubit>().getCurrency()}${(double.parse(orderList[index].total!) + double.parse(orderList[index].totalTaxAmount!)).toStringAsFixed(2)}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                      const Padding(
                                        padding: EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                                        child: DashLineView(
                                          fillRate: 0.7,
                                          direction: Axis.horizontal,
                                        ),
                                      ),
                                      orderList[index].promoDiscount != "0"
                                          ? Padding(
                                              padding: const EdgeInsetsDirectional.only(bottom: 4.5),
                                              child: Row(children: [
                                                Text(StringsRes.coupons + orderList[index].promoCode!,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400,
                                                        fontStyle: FontStyle.normal)),
                                                const Spacer(),
                                                Text(" - ${context.read<SystemConfigCubit>().getCurrency()}${orderList[index].promoDiscount!}",
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        fontStyle: FontStyle.normal)),
                                              ]),
                                            )
                                          : Container(),
                                      orderList[index].deliveryTip == "0"
                                          ? const SizedBox()
                                          : Row(children: [
                                              Text(UiUtils.getTranslatedLabel(context, deliveryTipLabel),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      fontStyle: FontStyle.normal)),
                                              const Spacer(),
                                              Text("${context.read<SystemConfigCubit>().getCurrency()}${orderList[index].deliveryTip!}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.primary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: FontStyle.normal)),
                                            ]),
                                      orderList[index].walletBalance == "0"
                                          ? const SizedBox()
                                          : Padding(
                                              padding: const EdgeInsetsDirectional.only(
                                                top: 4.5,
                                              ),
                                              child: Row(children: [
                                                Text(UiUtils.getTranslatedLabel(context, useWalletLabel),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400,
                                                        fontStyle: FontStyle.normal)),
                                                const Spacer(),
                                                Text(
                                                    " - ${context.read<SystemConfigCubit>().getCurrency()}${double.parse(orderList[index].walletBalance!).toStringAsFixed(2)}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        fontStyle: FontStyle.normal)),
                                              ]),
                                            ),
                                      orderList[index].isSelfPickUp == "1"
                                          ? const SizedBox()
                                          : Padding(
                                              padding: const EdgeInsetsDirectional.only(
                                                top: 4.5,
                                                bottom: 4.5,
                                              ),
                                              child: Row(children: [
                                                Text(UiUtils.getTranslatedLabel(context, deliveryFeeLabel),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSecondary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400,
                                                        fontStyle: FontStyle.normal)),
                                                const Spacer(),
                                                Text("${context.read<SystemConfigCubit>().getCurrency()}${orderList[index].deliveryCharge!}",
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        fontStyle: FontStyle.normal)),
                                              ]),
                                            ),
                                      const Padding(
                                        padding: EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                                        child: DashLineView(
                                          fillRate: 0.7,
                                          direction: Axis.horizontal,
                                        ),
                                      ),
                                      Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(
                                            "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(orderList[index].totalPayable!).toStringAsFixed(2)}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                      const Padding(
                                        padding: EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                                        child: DashLineView(
                                          fillRate: 0.7,
                                          direction: Axis.horizontal,
                                        ),
                                      ),
                                      Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, paymentLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(orderList[index].paymentMethod!,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                    ])),
                          ],
                        ));
                  }));
        });
  }

  @override
  void dispose() {
    orderController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url = "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launchUrlString(url, mode: LaunchMode.externalApplication);
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
          :*/ PopScope(
              canPop: true,
              onPopInvoked: (value) {
                if (value) {
                  return;
                }
                if (widget.from == "orderSuccess") {
                  Future.delayed(Duration.zero, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
                builder: (context, state) {
                  return Scaffold(
                      appBar: DesignConfig.appBar(
                          context,
                          width!,
                          widget.from == "orderDeliverd"
                              ? UiUtils.getTranslatedLabel(context, orderDeliveredLabel)
                              : UiUtils.getTranslatedLabel(context, orderDetailsLabel),
                          const PreferredSize(preferredSize: Size.zero, child: SizedBox()),
                          status: widget.from == "orderSuccess" ? true : false),
                      bottomNavigationBar: (widget.from == "orderDeliverd" && widget.isSelfPickup == "0")
                          ? Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              (state is OrderDetailSuccess)
                                  ? (state).orderList[0].orderRiderRating != ""
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                            Text("${UiUtils.getTranslatedLabel(context, youRatedYourDeliveryPartnerLabel)}",
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.secondary, fontSize: 14, fontWeight: FontWeight.w600)),
                                            Container(
                                                margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                                                padding: EdgeInsetsDirectional.only(start: width! / 60.0, end: width! / 60.0, top: 5.0, bottom: 5.0),
                                                decoration: DesignConfig.boxDecorationContainer(yellowColor, 4.0),
                                                child: Row(children: [
                                                  Text("${double.parse((state).orderList[0].orderRiderRating ?? "0.0").toStringAsFixed(2).replaceAll(regex, '')}",
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w700)),
                                                  Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 15.0)
                                                ])),
                                          ]),
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                              Text(UiUtils.getTranslatedLabel(context, helpingYourDeliverPartnerByRatingLabel),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                              SizedBox(height: height! / 99.0),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pushNamed(Routes.riderRating, arguments: {
                                                      'id': widget.id!,
                                                      'riderId': widget.riderId,
                                                      'riderName': widget.riderName!,
                                                      'riderRating': widget.riderRating!,
                                                      'riderImage': widget.riderImage!,
                                                      'riderMobile': widget.riderMobile!,
                                                      'riderNoOfRating': widget.riderNoOfRating!
                                                    });
                                                  },
                                                  child: Text(UiUtils.getTranslatedLabel(context, reviewLabel),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w700))),
                                            ])
                                  : const SizedBox.shrink(),
                              SizedBox(height: height! / 80.0),
                              SizedBox(width: width, child: downloadInvoice())
                            ])
                          : Column(mainAxisSize: MainAxisSize.min, children: [
                              widget.isSelfPickup == "1"
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: ButtonContainer(
                                            color: Theme.of(context).colorScheme.secondary,
                                            height: height,
                                            width: width,
                                            text: UiUtils.getTranslatedLabel(context, getDirectionLabel),
                                            start: width! / 40.0,
                                            end: width! / 40.0,
                                            bottom: height! / 99.0,
                                            top: 0,
                                            status: false,
                                            borderColor: Theme.of(context).colorScheme.secondary,
                                            textColor: white,
                                            onPressed: () {
                                              launchMap(latitude, longitude);
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: ButtonContainer(
                                            color: Theme.of(context).colorScheme.secondary,
                                            height: height,
                                            width: width,
                                            text: UiUtils.getTranslatedLabel(context, callToRestaurantsLabel),
                                            start: width! / 40.0,
                                            end: width! / 40.0,
                                            bottom: height! / 99.0,
                                            top: 0,
                                            status: false,
                                            borderColor: Theme.of(context).colorScheme.secondary,
                                            textColor: white,
                                            onPressed: () async {
                                              final Uri launchUri = Uri(
                                                scheme: 'tel',
                                                path: mobileNumber,
                                              );
                                              await launchUrl(launchUri);
                                            },
                                          ),
                                        )
                                      ],
                                    )
                                  : const SizedBox(),
                              SizedBox(width: width, child: downloadInvoice())
                            ]), //TextButton(style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory,),onPressed:(){},child: Container(margin: EdgeInsetsDirectional.only(start: width!/40.0, end: width!/40.0, bottom: height!/55.0), width: width, padding: EdgeInsetsDirectional.only(top: height!/55.0, bottom: height!/55.0, start: width!/20.0, end: width!/20.0), decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSecondary, 100.0), child: Text(StringsRes.downloadBill, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500)))),

                      body: Container(
                        margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                        padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                        width: width,
                        child: orderData(),
                      ));
                },
              ),
            ),
    );
  }
}

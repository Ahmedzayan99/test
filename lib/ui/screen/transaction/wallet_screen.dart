import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/payment/GetWithdrawRequestCubit.dart';
import 'package:project1/cubit/payment/sendWithdrawRequestCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/cubit/transaction/transactionCubit.dart';
import 'package:project1/ui/screen/payment/Stripe_Service.dart';
import 'package:project1/ui/screen/payment/midtransWebView.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/screen/payment/payment_radio.dart';
import 'package:project1/ui/screen/payment/paypal_webview_screen.dart';
import 'package:project1/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/smallButtomContainer.dart';
import 'package:project1/ui/widgets/transactionContainer.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:paytm/paytm.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:project1/utils/internetConnectivity.dart';
import '../cart/cart_screen.dart';
import 'dart:ui' as ui;

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
        BlocProvider<TransactionCubit>(
              create: (_) => TransactionCubit(
              ),
            ),
        BlocProvider<GetWithdrawRequestCubit>(
              create: (_) => GetWithdrawRequestCubit(
              ),
            )
      ], child: const WalletScreen()));
  }
}

class WalletScreenState extends State<WalletScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  ScrollController withdrawWalletController = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  TextEditingController? amountController, messageController, withdrawAmountController, paymentAddressController;
  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    'paypal',
    'rozerpay',
    'paystack',
    'flutterwave',
    'stripe',
    'paytm',
    'midtrans', 'phonepe'
  ];
  List<RadioModel> payModel = [];
  bool? paypal, razorpay, paumoney, paystack, flutterwave, stripe, paytm, midtrans, phonepe;
  String? razorpayId, payStackId, stripeId, stripeSecret, stripeMode = "test", stripeCurCode, paytmMerId, paytmMerKey;

  int? selectedMethod;
  String? payMethod;
  StateSetter? dialogState;
  bool isProgress = false;
  late Razorpay _razorpay;
  int offset = 0;
  int total = 0;
  bool isLoading = true, payTesting = true;
  //final payStackPlugin = PaystackPlugin();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String? walletAmount, filter = "0";
  bool enableList = false;
  int? _selectedIndex = 0;
  List<String> transactionType = [StringsRes.walletTransaction,StringsRes.walletWithdrawTransaction];

  @override
  void initState() {
    super.initState();
    walletAmount = context.read<SystemConfigCubit>().getWallet();
    selectedMethod = null;
    payMethod = null;
    Future.delayed(Duration.zero, () {
      paymentMethodList = [
        UiUtils.getTranslatedLabel(context, payPalLblLabel),
        UiUtils.getTranslatedLabel(context, razorpayLblLabel),
        UiUtils.getTranslatedLabel(context, payStackLblLabel),
        UiUtils.getTranslatedLabel(context, flutterWaveLblLabel),
        UiUtils.getTranslatedLabel(context, stripeLblLabel),
        UiUtils.getTranslatedLabel(context, paytmLblLabel),
        UiUtils.getTranslatedLabel(context, midtransLable),
        UiUtils.getTranslatedLabel(context, phonePeLable),
      ];
      getPaymentMethod();
    });
    amountController = TextEditingController();
    messageController = TextEditingController();
    withdrawAmountController = TextEditingController();
    paymentAddressController = TextEditingController();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
      context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
    });
    withdrawWalletController.addListener(scrollGetWithdrawListener);
    Future.delayed(Duration.zero, () {
      context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
    });
    context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TransactionCubit>().hasMoreData()) {
        context.read<TransactionCubit>().fetchMoreTransactionData(perPage, context.read<AuthCubit>().getId(), walletKey);
      }
    }
  }

  scrollGetWithdrawListener() {
    if (withdrawWalletController.position.maxScrollExtent == withdrawWalletController.offset) {
      if (context.read<GetWithdrawRequestCubit>().hasMoreData()) {
        context.read<GetWithdrawRequestCubit>().fetchMoreGetWithdrawRequestData(perPage, context.read<AuthCubit>().getId());
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    amountController!.dispose();
    messageController!.dispose();
    withdrawAmountController!.dispose();
    paymentAddressController!.dispose();
    controller.dispose();
    withdrawWalletController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
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

    Widget selectTransactionType() {
    return Container(
            decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
            margin: EdgeInsetsDirectional.only(top: height! / 99.0, start: width!/30.0, end: width!/30.0),
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
                            child: Text(transactionType[_selectedIndex!],
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
                        itemCount: transactionType.length,
                        itemBuilder: (context, position) {
                          return InkWell(
                            onTap: () {
                              onChanged(position);
                              filter = transactionType[position];
                              if(position==0){
                                  context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
                                }else{
                                  context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
                                }
                            },
                            child: Container(
                                padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transactionType[position],
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

  Future<void> getPaymentMethod() async {
    try {
      var parameter = {
        typeKey: paymentMethodKey,
      };
      Response response = await post(Uri.parse(Api.getSettingsUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];

        if (!error) {
          var data = getdata["data"];

          var payment = data["payment_method"];

          paypal = payment["paypal_payment_method"] == "1" ? true : false;
          paumoney = payment["payumoney_payment_method"] == "1" ? true : false;
          flutterwave = payment["flutterwave_payment_method"] == "1" ? true : false;
          razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
          paystack = payment["paystack_payment_method"] == "1" ? true : false;
          stripe = payment["stripe_payment_method"] == "1" ? true : false;
          paytm = payment["paytm_payment_method"] == "1" ? true : false;
          midtrans = payment["midtrans_payment_method"] == "1" ? true : false;
          phonepe = payment['phonepe_payment_method'] == '1' ? true : false;

          if (razorpay!) razorpayId = payment["razorpay_key_id"];
          if (paystack!) {
            payStackId = payment["paystack_key_id"];

       //     await payStackPlugin.initialize(publicKey: payStackId!);
          }
          if (stripe!) {
            stripeId = payment['stripe_publishable_key'];
            stripeSecret = payment['stripe_secret_key'];
            stripeCurCode = payment['stripe_currency_code'];
            print("stripCode:$stripeCurCode");
            stripeMode = payment['stripe_mode'] ?? 'test';
            StripeService.secret = stripeSecret;
            StripeService.init(stripeId, stripeMode);
          }
          if (paytm!) {
            paytmMerId = payment['paytm_merchant_id'];
            paytmMerKey = payment['paytm_merchant_key'];
            payTesting = payment['paytm_payment_mode'] == 'sandbox' ? true : false;
          }
          if(midtrans!){
            midTranshMerchandId =payment['midtrans_merchant_id'];
            midtransPaymentMethod = payment['midtrans_payment_method'];
            midtransPaymentMode = payment['midtrans_payment_mode'];
            midtransServerKey = payment['midtrans_server_key'];
            midtrasClientKey = payment['midtrans_client_key'];
          }
          /* if (phonepe!) {
            phonePeMode = payment["phonepe_payment_mode"];
            phonePeMerId = payment["phonepe_marchant_id"];
            phonePeSaltIndex = payment["phonepe_salt_index"];
            phonePeSaltKey = payment["phonepe_salt_key"];
            phonePeEndPointUrl = payment["phonepe_webhook_url"];
          } */

          for (int i = 0; i < paymentMethodList.length; i++) {
            payModel.add(RadioModel(isSelected: i == selectedMethod ? true : false, name: paymentMethodList[i], img: paymentIconList[i]));
          }
        }
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (dialogState != null) dialogState!(() {});
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    sendRequest(response.paymentId!, "RazorPay");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    var getdata = json.decode(response.message!);
    String errorMsg = getdata["error"]["description"];

    UiUtils.setSnackBar(errorMsg, errorMsg, context, false, type: "2");

    if (mounted) {
      isProgress = true;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> sendRequest(String txnId, String payMethod, {String? OrderID, String? status, Map<String, dynamic>? jsonDatas, String? checksums}) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        amountKey: amountController!.text.toString(),
        transactionTypeKey: 'wallet',
        typeKey: 'credit',
        messageKey: (messageController!.text == '' || messageController!.text.isEmpty) ? "Added through wallet" : messageController!.text,
        txnIdKey: txnId,
        orderIdKey: payMethod.toLowerCase() == "phonepe" ? OrderID : orderId,
        statusKey: payMethod.toLowerCase() == "phonepe" ? status : "success",
        paymentMethodKey: payMethod.toLowerCase(),
        
      };

      if (payMethod.toLowerCase() == "stripe" || payMethod.toLowerCase() == "paypal"/*  || payMethod.toLowerCase() == "phonepe" */) {
        parameter[skipVerifyTransactionKey] = (payMethod.toLowerCase() == "stripe" || payMethod.toLowerCase() == "paypal"/*  || payMethod.toLowerCase() == "phonepe" */) ? "true" : "false";
      }
      

      print("Transaction:$parameter");

      Response response =
          await post(Uri.parse(Api.addTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);
      print("transaction${getdata.toString()}-$parameter${amountController!.text.toString()}");
      if((payMethod.toLowerCase()=="stripe" || payMethod.toLowerCase()=="paypal")){}else{
      setState(() {
        walletAmount = getdata['new_balance'];
      });
      }

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        if(payMethod.toLowerCase() == "phonepe"){
          startPaymentPhonePe(double.parse(amountController!.text.toString()), orderId: OrderID!, jsonDatas: jsonDatas, checksums: checksums);  
        }else{
        if (mounted) {
          setState(() {
            context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
            context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
          });
        }
        }
        //updat wallet balance//
        if(payMethod.toLowerCase() == "phonepe"){}else{
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg, context, false, type: "1");
        }
      }
      if(getdata["status_code"].toString() == "102"){
        reLogin(context);
      }
      if (mounted) {
        setState(() {
          isProgress = false;
        });
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");

      setState(() {
        isProgress = false;
      });
    }
    return;
  }

  List<Widget> getPayList() {
    return paymentMethodList
        .asMap()
        .map(
          (index, element) => MapEntry(index, paymentItem(index)),
        )
        .values
        .toList();
  }

  Widget paymentItem(int index) {
    if (index == 0 && paypal! ||
        index == 1 && razorpay! ||
        index == 2 && paystack! ||
        index == 3 && flutterwave! ||
        index == 4 && stripe! ||
        index == 5 && paytm! || 
        index == 6 && midtrans! ||
        index == 7 && phonepe!) {
      return InkWell(
        onTap: () {
          if (mounted) {
            dialogState!(() {
              selectedMethod = index;
              payMethod = paymentMethodList[selectedMethod!];
              for (var element in payModel) {
                element.isSelected = false;
              }
              payModel[index].isSelected = true;
            });
          }
        },
        child: RadioItem(payModel[index], height: height, width: width),
      );
    } else {
      return Container();
    }
  }

  Future<void> paypalPayment(String amt) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";

    try {
      var parameter = {userIdKey: context.read<AuthCubit>().getId(), orderIdKey: orderId, amountKey: amt};
      Response response =
          await post(Uri.parse(Api.getPaypalLinkUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        String? data = getdata["data"];

        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => PaypalWebView(
                      url: data,
                      from: "wallet",
                      addNote: "",
                    )));
      } else {
        if(getdata["status_code"].toString() == "102"){
          reLogin(context);
        }
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg!, context, false, type: "2");
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  Future<void> flutterWavePayment(String price) async {
    try {
      if (mounted) {
        setState(() {
          isProgress = true;
        });
      }

      var parameter = {
        amountKey: price,
        userIdKey: context.read<AuthCubit>().getId(),
      };
      Response response =
          await post(Uri.parse(Api.flutterwaveWebviewUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["link"];
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => PaypalWebView(
                        url: data,
                        from: "wallet",
                        amt: amountController!.text.toString(),
                        msg: messageController!.text,
                        addNote: "",
                      )));
        } else {
          if(getdata["status_code"].toString() == "102"){
            reLogin(context);
          }
          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg!, context, false, type: "2");
        }
        setState(() {
          isProgress = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isProgress = false;
      });

      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  razorpayPayment(double price) async {
    String? contact = context.read<AuthCubit>().getMobile();
    String? email = context.read<AuthCubit>().getEmail();
    String? name = context.read<AuthCubit>().getName();
    print("email:$email");
    double amt = price * 100;

    if (contact != '' && email != '') {
      if (mounted) {
        setState(() {
          isProgress = true;
        });
      }

      var options = {
        key: razorpayId,
        amountKey: amt,
        nameKey: name,
        'prefill': {contactKey: contact, emailKey: email},
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (email == '') {
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, emailLabel), StringsRes.emailWarning, context, false, type: "2");
      } else if (contact == '') {
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, phoneNumberLabel), StringsRes.phoneWarning, context, false, type: "2");
      }
    }
  }

  void paytmPayment(double price) async {
    String? paymentResponse;
    setState(() {
      isProgress = true;
    });
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = '${payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in'}/theia/paytmCallback?ORDER_ID=$orderId';

    var parameter = {amountKey: price.toString(), userIdKey: context.read<AuthCubit>().getId(), orderIdKey: orderId};

    try {
      final response = await post(
        Uri.parse(Api.generatePaytmTxnTokenUrl),
        body: parameter,
        headers: Api.getHeaders(),
      );
      var getdata = json.decode(response.body);
      String? txnToken;
      setState(() {
        txnToken = getdata["txn_token"];
      });

      var paytmResponse = Paytm.payWithPaytm(
          callBackUrl: callBackUrl, mId: paytmMerId!, orderId: orderId, txnToken: txnToken!, txnAmount: price.toString(), staging: payTesting);

      paytmResponse.then((value) {
        setState(() {
          isProgress = false;

          if (value['error']) {
            paymentResponse = value['errorMessage'];
          } else {
            if (value['response'] != null) {
              paymentResponse = value['response']['STATUS'];
              if (paymentResponse == "TXN_SUCCESS") {
                sendRequest(orderId, "Paytm");
              }
            }
          }

          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), paymentResponse!, context, false, type: "1");
        });
      });
    } catch (e) {
      print(e);
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), e.toString(), context, false, type: "2");
    }
  }

  stripePayment(int price) async {
    if (mounted) {
      setState(() {
        isProgress = true;
      });
    }

    var response =
        await StripeService.payWithPaymentSheet(amount: (price * 100).toString(), currency: stripeCurCode, from: "wallet", context: context);

    if (mounted) {
      setState(() {
        isProgress = false;
      });
    }
    print("responce:${stripePayId.toString()}");
    if (!mounted) return;
    if (response.status == 'succeeded') {
      sendRequest(stripePayId!, "Stripe");
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), response.message!, context, false, type: "1");
    } else {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), response.message!, context, false, type: "2");
    }
  }

  payStackPayment(BuildContext context, int price) async {
    if (mounted) {
      setState(() {
        isProgress = true;
      });
    }
    //await payStackPlugin.initialize(publicKey: payStackId!);
    if (!mounted) return;
    String? email = context.read<AuthCubit>().getEmail();

    // Charge charge = Charge()
    //   ..amount = int.parse("${(price.toInt() * 100)}").toInt()
    //   ..reference = _getReference()
    //   ..email = email;

    try {
      if (!mounted) return;
  /*    CheckoutResponse response = await payStackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );

      if (response.status) {
        sendRequest(response.reference!, "Paystack");
      } else {
        if (!mounted) return;
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), response.message, context, false, type: "2");
        if (mounted) {
          setState(() {
            isProgress = false;
          });
        }
      }*/
    } catch (e) {
      if (mounted) setState(() => isProgress = false);
      rethrow;
    }
  }

  

  Future<Map<String, dynamic>> midtransPayment({
    required String price,
  }) async {
    try {
      String orderID =
          'wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
//
      try {
        var parameter = {
          amountKey: price,
          userIdKey: context.read<AuthCubit>().getId(),
          orderIdKey: orderID,
        };
         await post(Uri.parse(Api.createMidtransTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50)).then(
          (result) {
            var getdata = json.decode(result.body);
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];
              //String token = data['token'];
              String redirectUrl = data['redirect_url'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => MidTrashWebview(
                    url: redirectUrl,
                    from: 'wallet',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) async {
                  /* String msg =
                      await midtransWebhook(
                            orderID,
                          );
                  if (msg ==
                      'Order id is not matched with transaction order id.') {
                    msg = 'Transaction Failed...!';
                  }
                  /* String currentBalance = await context
                      .read<PaymentProvider>()
                      .getUserCurrentBalance();
                  if (currentBalance != '') {
                    Provider.of<UserProvider>(context, listen: false)
                        .setBalance(currentBalance);
                  } */
                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg.toString(), context, false, type: "1");
                  Navigator.pop(context, value); */
                  if (mounted) {
                    setState(() {
                      context
                          .read<SystemConfigCubit>()
                          .getSystemConfig(context.read<AuthCubit>().getId());
                      context.read<TransactionCubit>().fetchTransaction(perPage,
                          context.read<AuthCubit>().getId(), walletKey);
                    });
                  }
                },
              );
            } else {
              UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg.toString(), context, false, type: "2");
            }
          },
          onError: (error) {
            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), error.toString(), context, false, type: "2");
          },
        );
      } on TimeoutException catch (_) {
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> phonepeCheckSum(double price) async {
    try {
      String orderID = '${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      var parameter = {
        typeKey: "wallet",
        transationIdKey: orderID,
        deviceOsKey: Platform.isAndroid ? "ANDROID" : "IOS",
        mobileKey: context.read<AuthCubit>().getMobile(),
        amountKey: price.toStringAsFixed(2)
      };

      Response response =
          await post(Uri.parse(Api.phonepeCheckSumUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));
      var getdata = json.decode(response.body);
      bool error = getdata['error'];
      if (!error) {
      var jsonData = getdata['data']['payload'];
      String checksum = getdata['data']['checksum'];
      phonePeMode = getdata['data']["environment"];
      phonePeMerId = getdata['data']['payload']["merchantId"];
      appId = getdata['data']["appId"];
      phonePeEndPointUrl = getdata['data']['payload']["callbackUrl"];
      initPhonePeSdk(price, orderId: orderID, jsonDatas: jsonData, checksums: checksum);
      }

      if (mounted) {
        setState(() {});
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");

      setState(() {});
    }
  }

  void initPhonePeSdk(double price, {required String orderId, Map<String, dynamic>? jsonDatas, String? checksums}) async {
    PhonePePaymentSdk.init(phonePeMode!, appId!, phonePeMerId!, true).then((isInitialized) {
      sendRequest(orderId, "phonepe", OrderID: orderId, status: waitingKey, jsonDatas: jsonDatas, checksums: checksums);
    }).catchError((error) {
      return error;
    });
  }

  void startPaymentPhonePe(double price, {required String orderId, Map<String, dynamic>? jsonDatas, String? checksums}) async {
    try {
      String body = '';
      String base64Data = base64Encode(utf8.encode(jsonEncode(jsonDatas)));
      body = base64Data;

      PhonePePaymentSdk.startTransaction(
              body,
              phonePeEndPointUrl!,
              checksums!,
              Platform.isAndroid ? packageName : iosPackage)
          .then((response) async {
        if (kDebugMode) {
          print("response $response");
        }
        if (response != null) {
          String status = response['status'].toString();
          if (status == 'SUCCESS') {
            context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
            context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
          } else {
            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
            if (mounted) {
              setState(() {
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
  
            });
          }
        }
      }).catchError((error) {
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), error.toString(), context, false, type: "2");
        return Future(() => null);
      });
    } catch (error) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), error.toString(), context, false, type: "2");
    }
  }

  Widget walletWithdraw() {
    return BlocConsumer<GetWithdrawRequestCubit, GetWithdrawRequestState>(
        bloc: context.read<GetWithdrawRequestCubit>(),
        listener: (context, state) {
          if (state is GetWithdrawRequestFailure) {
            if(state.errorStatusCode.toString() == "102"){
              reLogin(context);
            }
          }
        },
        builder: (context, state) {
          if (state is GetWithdrawRequestProgress || state is GetWithdrawRequestInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is GetWithdrawRequestFailure) {
            return SizedBox(
              height: height! / 1.5,child: onData());
          }
          final withdrawRequestList = (state as GetWithdrawRequestSuccess).withdrawRequestList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.5,
              child: withdrawRequestList.isEmpty?onData():ListView.builder(
                  shrinkWrap: true,
                  controller: withdrawWalletController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: withdrawRequestList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (withdrawRequestList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Container(
                            padding: EdgeInsetsDirectional.only(
                                start: width! / 35.0,
                                top: height! / 80.0,
                                end: width! / 35.0,
                                bottom: height! / 80.0),
                            width: width!,
                            margin: EdgeInsetsDirectional.only(
                                top: index==0?0.0:height! / 52.0,
                                start: width! / 20.0,
                                end: width! / 20.0),
                            decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                  start: width! / 60.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(UiUtils.getTranslatedLabel(context, idLabel).toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16.0)),
                                            Text(
                                                " #${withdrawRequestList[index].id!}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0)),
                                          ],
                                        ),
                                        withdrawRequestList[index].status == ""
                                            ? const SizedBox()
                                            : Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                                                    margin: const EdgeInsetsDirectional.only(start: 4.5),
                                                    width: 55,
                                                    decoration: DesignConfig
                                                        .boxDecorationContainerBorder(
                                                            withdrawRequestList[index].status == "1"
                                                                ? Theme.of(context).colorScheme.onPrimary:withdrawRequestList[index].status == "0"
                                                                ? yellowColor
                                                                : Theme.of(context).colorScheme.error,
                                                            withdrawRequestList[index].status == "1"
                                                                ? Theme.of(context).colorScheme.onPrimary .withOpacity(0.10):withdrawRequestList[index].status == "0"
                                                                ? yellowColor.withOpacity(0.10)
                                                                : Theme.of(context).colorScheme.error.withOpacity(0.10),
                                                            4.0),
                                                    child: Text(
                                                      withdrawRequestList[index]
                                                          .status!.toString()=="0"?StringsRes.pending:withdrawRequestList[index]
                                                          .status!.toString()=="1"?StringsRes.approval:withdrawRequestList[index]
                                                          .status!.toString()=="2"?StringsRes.rejected:"",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: withdrawRequestList[index].status == "1"
                                                              ? Theme.of(context).colorScheme.onPrimary:withdrawRequestList[index].status == "0"
                                                                ? yellowColor
                                                              : Theme.of(context).colorScheme.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 80.0,
                                          bottom: height! / 80.0),
                                      child: DesignConfig.divider(),
                                    ),
                                    Text("${UiUtils.getTranslatedLabel(context, dateLabel)} :",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.0)),
                                    Text(
                                        formatter.format(DateTime.parse(
                                            withdrawRequestList[index]
                                                .dateCreated!)),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14.0)),
                                    SizedBox(height: height! / 60.0),
                                    Text("${UiUtils.getTranslatedLabel(context, typeLabel)} : ",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.0)),
                                    Text(withdrawRequestList[index].paymentType!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14.0),
                                        maxLines: 2),
                                    SizedBox(height: height! / 60.0),
                                    withdrawRequestList[index].remarks!.isEmpty?const SizedBox():Text("${UiUtils.getTranslatedLabel(context, messageLabel)} :",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.0)),
                                    withdrawRequestList[index].remarks!.isEmpty?const SizedBox():SizedBox(
                                        width: width! / 1.1,
                                        child: Text(
                                            withdrawRequestList[index].remarks!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 80.0,
                                          bottom: height! / 80.0),
                                      child: DesignConfig.divider(),
                                    ),
                                    Row(children: [
                                      Text("${UiUtils.getTranslatedLabel(context, amountLabel)} : ",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSecondary,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 16.0)),
                                      const Spacer(),
                                      Text(
                                          "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(withdrawRequestList[index].amountRequested!).toStringAsFixed(2)}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSecondary,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 16.0)),
                                    ]),
                                  ]),
                            ),
                          );
                  }));
        });
  }

  Widget onData(){
    return NoDataContainer(
                image: "wallet",
                title: UiUtils.getTranslatedLabel(context, noWalletFoundLabel),
                subTitle: UiUtils.getTranslatedLabel(context, noWalletFoundSubTitleLabel),
                width: width!,
                height: height!);
  }

  Widget wallet() {
    return BlocConsumer<TransactionCubit, TransactionState>(
        bloc: context.read<TransactionCubit>(),
        listener: (context, state) {
          if (state is TransactionFailure) {
            if (state.errorStatusCode.toString() == "102") {
              reLogin(context);
            }
          }
        },
        builder: (context, state) {
          if (state is TransactionProgress || state is TransactionInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is TransactionFailure) {
            print("state:${state}--${state.errorStatusCode}--${state.errorMessage}");
            return SizedBox(
              height: height! / 1.5,child: onData());
          }
          final transactionList = (state as TransactionSuccess).transactionList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.5,
              child: transactionList.isEmpty?onData():ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: transactionList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (transactionList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : TransactionContainer(transactionModel: transactionList[index], height: height, width: width, index: index);
                  }));
        });
  }

  addMoneyDialog() async {
    bool payWarn = false;
    await dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      dialogState = setStater;
      return Dialog(
        shape: DesignConfig.setRounded(10.0),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: DesignConfig.boxDecorationContainer(Colors.white, 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(alignment: Alignment.centerLeft, padding: EdgeInsetsDirectional.only(start: width!/20.0), decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSecondary), height: height!/15.0, width: width!, child: Text(
                UiUtils.getTranslatedLabel(context, addMoneyLabel),
                style: const TextStyle(
                    color:  white,
                    fontWeight: FontWeight.w400,
                    fontStyle:  FontStyle.normal,
                    fontSize: 14.0
                ),
                textAlign: TextAlign.left                
                )),
                  Form(
                    key: _formkey,
                    child: Flexible(
                      child: SingleChildScrollView(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Container(decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0), margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 60.0, end: width! / 20.0),
                            padding: EdgeInsetsDirectional.only(start: width!/40.0),
                            child: TextFormField(
                              style: const TextStyle(
                                color: lightFont,
                                fontSize: 14.0,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => validateField(val!, UiUtils.getTranslatedLabel(context, requirdFieldLabel)),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(border: InputBorder.none,
                                  hintText: UiUtils.getTranslatedLabel(context, enterAmountLabel),
                                  labelStyle: const TextStyle(
                                    color: lightFont,
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: lightFont,
                                    fontSize: 14.0,
                                  )),
                              cursorColor: lightFont,
                              controller: amountController,
                            )),
                        Container(decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0), margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 60.0, end: width! / 20.0),
                            padding: EdgeInsetsDirectional.only(start: width!/40.0),
                            child: TextFormField(
                              style: const TextStyle(
                                color: lightFont,
                                fontSize: 14.0,
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(border: InputBorder.none,
                                hintText: UiUtils.getTranslatedLabel(context, enterMessageLabel),
                                labelStyle: const TextStyle(
                                  color: lightFont,
                                  fontSize: 14.0,
                                ),
                                hintStyle: const TextStyle(
                                  color: lightFont,
                                  fontSize: 14.0,
                                ),
                              ),
                              cursorColor: lightFont,
                              controller: messageController,
                            )),
                        //Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
                          child: Text(
                            UiUtils.getTranslatedLabel(context, paymentLabel),
                            style: TextStyle(
                              color:  Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.w500,
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.start,
                          ),
                        ),
                        DesignConfig.divider(),
                        payWarn
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  UiUtils.getTranslatedLabel(context, payWarningLabel),
                                  style: TextStyle(
                              color:  Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          )),
                              )
                            : Container(),

                        paypal == null
                            ? Center(
                                child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ))
                            : Column(mainAxisAlignment: MainAxisAlignment.start, children: getPayList()),
                      ])),
                    ),
                  ),
                  SizedBox(
                    height: height!/40.0,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmallButtonContainer(color: Theme.of(context).colorScheme.onSurface, height: height, width: width, text: UiUtils.getTranslatedLabel(context, cancelLabel), start: 0, end: 0, bottom: height!/60.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.onSurface, textColor: Theme.of(context).colorScheme.onSecondary, onTap: (){
                        Navigator.pop(context);
                      },),
                      SmallButtonContainer(color: Theme.of(context).colorScheme.primary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, addMoneyLabel), start: 0, end: width!/20.0, bottom: height!/60.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.primary, textColor: white, onTap: (){
                        final form = _formkey.currentState!;
                        if (form.validate() && amountController!.text != '0') {
                          form.save();
                          if (payMethod == null) {
                            dialogState!(() {
                            payWarn = true;
                          });
                          } else {
                            if (payMethod!.trim() == UiUtils.getTranslatedLabel(context, stripeLblLabel)) {
                              stripePayment(int.parse(amountController!.text));
                            } else if (payMethod!.trim() == UiUtils.getTranslatedLabel(context, razorpayLblLabel)) {
                              razorpayPayment(double.parse(amountController!.text));
                            } else if (payMethod!.trim() == UiUtils.getTranslatedLabel(context, payStackLblLabel)) {
                              payStackPayment(context, int.parse(amountController!.text));
                            } else if (payMethod == UiUtils.getTranslatedLabel(context, paytmLblLabel)) {
                              paytmPayment(double.parse(amountController!.text));
                            } else if (payMethod == UiUtils.getTranslatedLabel(context, payPalLblLabel)) {
                              paypalPayment((amountController!.text).toString());
                            } else if (payMethod == UiUtils.getTranslatedLabel(context, flutterWaveLblLabel)) {
                              flutterWavePayment(amountController!.text);
                            } else if(payMethod == UiUtils.getTranslatedLabel(context, midtransLable)){
                              midtransPayment(price: amountController!.text);
                            } else if (payMethod == UiUtils.getTranslatedLabel(context, phonePeLable)) {
                              phonepeCheckSum(double.parse(amountController!.text));
                            }
                              Navigator.pop(context);
                            }
                        }
                      },),
                    ],
                  ),
                ],
              ),
        ),
      );
    }));
  }

  /* filterDialog(BuildContext bldcontext) async {
    await dialogAnimate(context, StatefulBuilder(builder: (context, StateSetter setStater) {
      dialogState = setStater;
      return Dialog(
        shape: DesignConfig.setRounded(25.0),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: width! / 20.0, top: height! / 15.0, right: width! / 20.0, bottom: height! / 40.0),
              margin: EdgeInsets.only(top: height! / 18.0),
              decoration: DesignConfig.boxDecorationContainer(Colors.white, 25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: width!,
                    child: ButtonContainer(
                      color: white,
                      height: height,
                      width: width,
                      text: StringsRes.walletTransaction,
                      top: height! / 50.0,
                      end: width! / 99.0,
                      bottom: 0,
                      start: 0,
                      status: false,
                      borderColor: Theme.of(context).colorScheme.onSecondary,
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      onPressed: () {
                        setState(() {
                          filter = "1";
                          
                        });
                        print('here');
                        Future.delayed(Duration.zero, () {
                            bldcontext.read<TransactionCubit>().fetchTransaction(perPage, bldcontext.read<AuthCubit>().getId(), walletKey);
                          });
                          Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: width!,
                    child: ButtonContainer(
                      color: white,
                      height: height,
                      width: width,
                      text: StringsRes.walletWithdrawTransaction,
                      top: height! / 50.0,
                      end: width! / 99.0,
                      bottom: 0,
                      start: 0,
                      status: false,
                      borderColor: Theme.of(context).colorScheme.onSecondary,
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      onPressed: () {
                        setState(() {
                          filter = "2";
                          Future.delayed(Duration.zero, () {
                            context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
                          });
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: width!,
                    child: ButtonContainer(
                      color: Theme.of(context).colorScheme.onSecondary,
                      height: height,
                      width: width,
                      text: StringsRes.cancel,
                      top: height! / 50.0,
                      end: width! / 99.0,
                      bottom: 0,
                      start: 0,
                      status: false,
                      borderColor: Theme.of(context).colorScheme.onSecondary,
                      textColor: white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned.directional(
                top: 20,
                start: width! / 3,
                end: width! / 3,
                textDirection: Directionality.of(context),
                child: Container(
                    padding: const EdgeInsetsDirectional.all(5),
                    width: 45.0,
                    height: 45.0,
                    decoration: DesignConfig.boxDecorationContainerCardShadow(red, shadowCard, 5, 0, 3, 6, 0),
                    child: SvgPicture.asset(DesignConfig.setSvgPath("pro_wh"), fit: BoxFit.scaleDown, color: white))),
          ],
        ),
      );
    }));
  } */

  withDrawMoneyDialog() async {
    await dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      dialogState = setStater;
      return Dialog(
        shape: DesignConfig.setRounded(10.0),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: DesignConfig.boxDecorationContainer(Colors.white, 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(alignment: Alignment.centerLeft, padding: EdgeInsetsDirectional.only(start: width!/20.0), decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSecondary), height: height!/15.0, width: width!, child: Text(
                UiUtils.getTranslatedLabel(context, withdrawMoneyLabel),
                style: const TextStyle(
                    color:  white,
                    fontWeight: FontWeight.w400,
                    fontStyle:  FontStyle.normal,
                    fontSize: 14.0
                ),
                textAlign: TextAlign.left                
                )),
              Form(
                key: _formkey,
                child: Flexible(
                  child: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0), margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 60.0, end: width! / 20.0),
                        padding: EdgeInsetsDirectional.only(start: width!/40.0),
                        child: TextFormField(
                          style: const TextStyle(
                            color: lightFont,
                            fontSize: 14.0,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) => validateField(val!, UiUtils.getTranslatedLabel(context, requirdFieldLabel)),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(border: InputBorder.none,
                              hintText: UiUtils.getTranslatedLabel(context, enterWithdrawAmountLabel),
                              labelStyle: const TextStyle(
                                color: lightFont,
                                fontSize: 14.0,
                              ),
                              hintStyle: const TextStyle(
                                color: lightFont,
                                fontSize: 14.0,
                              )),
                          cursorColor: lightFont,
                          controller: withdrawAmountController,
                        )),
                    Container(decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0), margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 80.0, end: width! / 20.0),
                        padding: EdgeInsetsDirectional.only(start: width!/40.0),
                        child: TextFormField(
                          maxLines: 7,
                          style: const TextStyle(
                            color: lightFont,
                            fontSize: 14.0,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(border: InputBorder.none,
                            hintText: UiUtils.getTranslatedLabel(context, enterPaymentAddressLabel),
                            labelStyle: const TextStyle(
                              color: lightFont,
                              fontSize: 14.0,
                            ),
                            hintStyle: const TextStyle(
                              color: lightFont,
                              fontSize: 14.0,
                            ),
                          ),
                          cursorColor: lightFont,
                          controller: paymentAddressController,
                        )),
                  ])),
                ),
              ),
              SizedBox(
                height: height!/40.0,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SmallButtonContainer(color: Theme.of(context).colorScheme.onSurface, height: height, width: width, text: UiUtils.getTranslatedLabel(context, cancelLabel), start: 0, end: 0, bottom: height!/60.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.onSurface, textColor: Theme.of(context).colorScheme.onSecondary, onTap: (){
                        Navigator.pop(context);
                  },),
                  //SizedBox(width: width! / 70.0),
                  BlocConsumer<SendWithdrawRequestCubit, SendWithdrawRequestState>(
                        bloc: context.read<SendWithdrawRequestCubit>(),
                        listener: (context, state) {
                          if (state is SendWithdrawRequestFetchSuccess) {
                            print(state.walletAmount);
                            walletAmount = state.walletAmount.toString();
                            context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
                            context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
                            Navigator.of(context, rootNavigator: true).pop(true);
                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), "Withdrawal Request Sent Successfully. Wait for admin to accept the withdrawal request.", context, false, type: "2");
                          }
                          if(state is SendWithdrawRequestFetchFailure){
                            if(state.errorStatusCode.toString() == "102"){
                              reLogin(context);
                            }
                            Navigator.of(context, rootNavigator: true).pop(true);
                          UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel),
                              state.errorCode, context, false,
                              type: "2");
                          }
                        },
                        builder: (context, state) {
                          print(state.toString());
                          if (state is SendWithdrawRequestFetchFailure) {
                            print(state.errorCode);
                            return SmallButtonContainer(color: Theme.of(context).colorScheme.primary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, sendLabel), start: 0, end: 0, bottom: height!/60.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.primary, textColor: white, onTap: (){
                                final form = _formkey.currentState!;
                                if (form.validate() && withdrawAmountController!.text != '0') {
                                  form.save();
                                  context.read<SendWithdrawRequestCubit>().sendWithdrawRequest(
                                  context.read<AuthCubit>().getId(), withdrawAmountController!.text, paymentAddressController!.text);
                                }
                            },);
                          } else {
                            return SmallButtonContainer(color: Theme.of(context).colorScheme.primary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, sendLabel), start: 0, end: width!/20.0, bottom: height!/60.0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.primary, textColor: white, onTap: (){
                              final form = _formkey.currentState!;
                              if (form.validate() && withdrawAmountController!.text != '0') {
                                form.save();
                                context.read<SendWithdrawRequestCubit>().sendWithdrawRequest(
                                context.read<AuthCubit>().getId(), withdrawAmountController!.text, paymentAddressController!.text);
                              }
                            },);
                          }
                        }),
                ],
              ),
            ],
          ),
        ),
      );
    }));
  }

  Future<void> refreshList() async {
    context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
    context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
    context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
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
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, walletLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: BlocListener<SystemConfigCubit, SystemConfigState>(
              bloc: context.read<SystemConfigCubit>(),
              listener: (context, state) {
                print("state:${state.toString()}");
                if (state is SystemConfigFetchSuccess) {
                  print("state:${state.systemConfigModel.data!.userData![0].balance}");
                  walletAmount = state.systemConfigModel.data!.userData![0].balance;//context.read<SystemConfigCubit>().getWallet();
                  //context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
                }
                if (state is SystemConfigFetchFailure) {
                  print(state.errorCode);
                }
              },
              child: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 90.0),
                  width: width,
                  child: SingleChildScrollView( physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(padding: EdgeInsetsDirectional.only(start: width! / 30.0, end: width! / 30.0, top: height! / 80.0, bottom: height!/80.0), decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children:[ Stack(
                            children: [
                              Container(
                                decoration: DesignConfig.boxDecorationContainer(
                                    Theme.of(context).colorScheme.secondary,
                                    10.0), margin: EdgeInsetsDirectional.only(start: width!/30.0, end: width!/30.0), padding: EdgeInsetsDirectional.only(top: height!/40.0, bottom: height!/40.0, start: width!/20.0, end: width!/20.0),
                                    child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  " ${UiUtils.getTranslatedLabel(context, currentBalanceLabel)}",
                                  style:
                                      const TextStyle(
                                      color:  Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontStyle:  FontStyle.normal,
                                      fontSize: 14.0
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                BlocBuilder<SystemConfigCubit, SystemConfigState>(
                                    bloc: context.read<SystemConfigCubit>(),
                                    builder: (context, state) {
                                      if (state is SystemConfigFetchSuccess) {
                                        return Text(
                                          "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(state.systemConfigModel.data!.userData![0].balance!).toStringAsFixed(2)}",
                                          style: const TextStyle(
                                          color:  Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:  FontStyle.normal,
                                          fontSize: 20.0
                                      ),
                                        );
                                      } else {
                                        return Text("${context.read<SystemConfigCubit>().getCurrency()}${double.parse(walletAmount??"0.0").toStringAsFixed(2)}",
                                          style: const TextStyle(
                                          color:  Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:  FontStyle.normal,
                                          fontSize: 20.0
                                      ),
                                        );
                                      }
                                    }),
                                SizedBox(height: height! / 40.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SmallButtonContainer(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        height: height,
                                        width: width,
                                        text: UiUtils.getTranslatedLabel(context, addMoneyLabel),
                                        start: width! / 99.0,
                                        end: width! / 40.0,
                                        bottom: 0,
                                        top: 0,
                                        status: false,
                                        radius: 5.0,
                                        borderColor: Theme.of(context).colorScheme.onSurface,
                                        textColor: Theme.of(context).colorScheme.onSecondary,
                                        onTap: () {
                                          addMoneyDialog();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: SmallButtonContainer(
                                        color: Theme.of(context).colorScheme.secondary,
                                        height: height,
                                        width: width,
                                        text: UiUtils.getTranslatedLabel(context, withdrawMoneyLabel),
                                        start: width! / 40.0,
                                        end: width! / 99.0,
                                        bottom: 0,
                                        top: 0,
                                        status: false,
                                        radius: 5.0,
                                        borderColor: Theme.of(context).colorScheme.onSurface,
                                        textColor: white,
                                        onTap: () {
                                            withDrawMoneyDialog();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                              ),
                              Positioned.directional(end: width!/30.0,
                                textDirection: Directionality.of(context),
                                // /end: 0.0,
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  width: width!/5.4,
                                  height: height!/12.0,
                                  decoration:
                                      Directionality.of(context) == ui.TextDirection.rtl
                                              ? DesignConfig.boxDecorationContainerRoundHalf(
                                          Theme.of(context).colorScheme.onSurface.withOpacity(0.10), 0, 0, 10, 62):DesignConfig.boxDecorationContainerRoundHalf(
                                          Theme.of(context).colorScheme.onSurface.withOpacity(0.10), 0, 62, 10, 0),
                                ),
                              ),
                              Positioned.directional(start: width!/30.0,
                                textDirection: Directionality.of(context),
                                bottom: 0.0,
                                child: Container(
                                  width: width!/5.4,
                                  height: height!/12.0,
                                  decoration:
                                      Directionality.of(context) == ui.TextDirection.rtl
                                              ? DesignConfig.boxDecorationContainerRoundHalf(
                                          Theme.of(context).colorScheme.onSurface.withOpacity(0.10), 62, 10, 0, 0):DesignConfig.boxDecorationContainerRoundHalf(
                                          Theme.of(context).colorScheme.onSurface.withOpacity(0.10), 0, 0, 62, 0),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: width!/30.0, top: height!/80.0),
                            child: Text(UiUtils.getTranslatedLabel(context, walletHistoryLabel),
                            style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500)),
                          ),
                          selectTransactionType(),]),
                        ),
                        Container(
                            margin: EdgeInsetsDirectional.only(/* start: width! / 30.0, end: width! / 30.0,  */top: height! / 60.0),
                            child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: _selectedIndex == 0 ? wallet() : walletWithdraw())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

dialogAnimate(BuildContext context, Widget dialog) {
  return showGeneralDialog(
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(opacity: a1.value, child: dialog),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      // pageBuilder: null
      pageBuilder: (context, animation1, animation2) {
        return Container();
      } //as Widget Function(BuildContext, Animation<double>, Animation<double>)
      );
}

String? validateField(String value, String? msg) {
  if (value.isEmpty) {
    return msg;
  } else {
    return null;
  }
}

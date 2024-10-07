/* import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/ui/screen/order/thank_you_for_order.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalWebView extends StatefulWidget {
  final String? url, from, msg, amt, orderId, addNote;

  const PaypalWebView({Key? key, this.url, this.from, this.msg, this.amt, this.orderId, this.addNote}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebView();
  }
}

class StatePayPalWebView extends State<PaypalWebView> {
  String message = "";
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  DateTime? currentBackPressTime;
  double? width, height;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                DateTime now = DateTime.now();
                if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
                  currentBackPressTime = now;
                  setSnackbar("Don't press back while doing payment!\n Double tap back button to exit");

                  //return Future.value(false);
                }
                if (widget.from == "order" && widget.orderId != null) deleteOrder();
                Navigator.pop(context);
              },
              child: Padding(
                  padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32,fit: BoxFit.scaleDown,))),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          centerTitle: true,
          title: Text(StringsRes.appName,
              textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: WillPopScope(
            onWillPop: onWillPop,
            child: Container(
              margin: EdgeInsetsDirectional.only(top: height! / 30.0),
              decoration: DesignConfig.boxCurveShadow(Theme.of(context).colorScheme.onSurface),
              width: width,
              child: Container(
                margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 50.0),
                child: Stack(
                  children: <Widget>[
                    WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      javascriptChannels: <JavascriptChannel>{
                        _toasterJavascriptChannel(context),
                      },
                      navigationDelegate: (NavigationRequest request) async {
                        //print("Url:=================***********" + request.url.toString());
                        if (request.url.startsWith(Api.appPaymentStatusUrl) || request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
                          if (mounted) {
                            setState(() {
                              isloading = true;
                            });
                          }

                          String responseurl = request.url;

                          if (responseurl.contains("Failed") || responseurl.contains("failed")) {
                            if (mounted) {
                              setState(() {
                                isloading = false;
                                message = "Transaction Failed";
                              });
                            }
                            Timer(const Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          } else if (responseurl.contains("Completed") ||
                              responseurl.contains("completed") ||
                              responseurl.toLowerCase().contains("success")) {
                            if (mounted) {
                              setState(() {
                                if (mounted) {
                                  setState(() {
                                    message = "Transaction Successfull";
                                  });
                                }
                              });
                            }
                            List<String> testdata = responseurl.split("&");
                            for (String data in testdata) {
                              if (data.split("=")[0].toLowerCase() == "tx" || data.split("=")[0].toLowerCase() == "transaction_id") {
                                // String txid = data.split("=")[1];

                                //userProvider.setCartCount("0");

                                // CUR_CART_COUNT = "0";

                                if (widget.from == "order") {
                                  if (request.url.startsWith(Api.appPaymentStatusUrl)) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(builder: (BuildContext context) => const ThankYouForOrderScreen()),
                                        ModalRoute.withName('/home'));
                                  } else {
                                    String txid = data.split("=")[1];

                                    placeOrder(txid);
                                  }
                                } else if (widget.from == "wallet") {
                                  if (request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
                                    String txid = data.split("=")[1];
                                    sendRequest(txid, "flutterwave");
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }

                                break;
                              }
                            }
                          }

                          if (request.url.startsWith(Api.appPaymentStatusUrl) &&
                              widget.orderId != null &&
                              (responseurl.contains('Canceled-Reversal') || responseurl.contains('Denied') || responseurl.contains('Failed'))) {
                            deleteOrder();
                          }
                          return NavigationDecision.prevent;
                        } else {}

                        return NavigationDecision.navigate;
                      },
                      onPageFinished: (String url) {
                        setState(() {
                          isloading = false;
                        });
                      },
                    ),
                    isloading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                    message.trim().isEmpty
                        ? Container()
                        : Center(
                            child: Container(
                                color: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.all(5),
                                child: Text(
                                  message,
                                  style: const TextStyle(color: white),
                                )))
                  ],
                ),
              ),
            )));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar("Don't press back while doing payment!\n Double tap back button to exit");

      return Future.value(false);
    }
    if (widget.from == "order" && widget.orderId != null) deleteOrder();
    return Future.value(true);
  }

  Future<void> sendRequest(String txnId, String payMethod) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        amountKey: widget.amt,
        transactionTypeKey: 'wallet',
        typeKey: 'credit',
        messageKey: (widget.msg == '' || widget.msg!.isEmpty) ? "Added through wallet" : widget.msg,
        txnIdKey: txnId,
        orderIdKey: orderId,
        statusKey: "Success",
        paymentMethodKey: payMethod.toLowerCase()
      };

      Response response =
          await post(Uri.parse(Api.addTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      // String msg = getdata["message"];

      if (!error) {}
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(StringsRes.somethingMsg);

      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> deleteOrder() async {
    try {
      var parameter = {
        orderIdKey: widget.orderId,
      };

      Response response = await post(Uri.parse(Api.deleteOrderUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      //  var getdata = json.decode(response.body);
      // bool error = getdata["error"];
      //  String msg = getdata["message"];

      if (mounted) {
        setState(() {
          isloading = false;
        });
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(StringsRes.somethingMsg);

      setState(() {
        isloading = false;
      });
    }
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: black),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 1.0,
    ));
  }

  Future<void> placeOrder(String tranId) async {
    setState(() {
      isloading = true;
    });

    String? mobile = context.read<SystemConfigCubit>().getMobile();
    String? varientId, quantity;
    final cartModel = context.read<GetCartCubit>().getCartModel();
    varientId = cartModel.variantId!.join(",");
    for (int i = 0; i < cartModel.data!.length; i++) {
      quantity = quantity != null ? "$quantity,${cartModel.data![i].qty!}" : cartModel.data![i].qty!;
    }
    String payVia;

    payVia = "flutterwave";

    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        mobileKey: context.read<SystemConfigCubit>().getMobile(),
        productVariantIdKey: varientId,
        quantityKey: quantity,
        totalKey: subTotal.toString(),
        finalTotalKey: finalTotal.toString(),
        deliveryChargeKey: deliveryCharge.toString(),
        taxAmountKey: taxAmount.toString(),
        taxPercentageKey: taxPercentage.toString(),
        latitudeKey: latitude.toString(),
        longitudeKey: longitude.toString(),
        paymentMethodKey: payVia,
        addressIdKey: selAddress,
        isWalletUsedKey: isUseWallet! ? "1" : "0",
        walletBalanceUsedKey: isPayLayShow.toString(),
        orderNoteKey: widget.addNote ?? "",
        deliveryTipKey: deliveryTip.toString(),
      };

      if (isPromoValid!) {
        parameter["promo_code"] = promoCode;
      }

      Response response = await post(Uri.parse(Api.placeOrderUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          String orderId = getdata["order_id"].toString();
          addTransaction(tranId, orderId, "Success", msg, true);
        } else {
          setSnackbar(msg!);
        }
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  Future<void> addTransaction(String tranId, String orderID, String status, String? msg, bool redirect) async {
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        orderIdKey: orderID,
        typeKey: paymentMethod,
        txnIdKey: tranId,
        amountKey: finalTotal.toString(),
        statusKey: status,
        messageKey: msg
      };

      Response response =
          await post(Uri.parse(Api.addTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          promoAmt = 0;
          remWalBal = 0;
          walletBalanceUsed = 0;
          paymentMethod = '';
          isPromoValid = false;
          isUseWallet = false;
          isPayLayShow = true;
          selectedMethod = null;
          finalTotal = 0;
          subTotal = 0;

          taxPercentage = 0;
          deliveryCharge = 0;
          orderTypeIndex = 0;

          Navigator.pushAndRemoveUntil(
              context, CupertinoPageRoute(builder: (BuildContext context) => const ThankYouForOrderScreen()), ModalRoute.withName('/home'));
        }
      } else {
        setSnackbar(msg1!);
      }
    } on TimeoutException catch (_) {
      setSnackbar(StringsRes.somethingMsg);
    }
  }
}
 */

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:project1/cubit/address/addressCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/screen/cart/cart_screen.dart';
import 'package:project1/ui/screen/order/thank_you_for_order.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


class PaypalWebView extends StatefulWidget {
  final String? url, from, msg, amt, orderId, addNote;

  const PaypalWebView({Key? key, this.url, this.from, this.msg, this.amt, this.orderId, this.addNote}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebView();
  }
}

class StatePayPalWebView extends State<PaypalWebView> {
  String message = "";
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final WebViewController _controller;
  DateTime? currentBackPressTime;
  double? width, height;

  @override
  void initState(){
    super.initState();
    webViewInitiliased();
  }

  webViewInitiliased() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(
                  () {
                isloading = false;
              },
            );
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            //print("Url:=================***********" + request.url.toString());
                        if (request.url.startsWith(Api.appPaymentStatusUrl) || request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
                          if (mounted) {
                            setState(() {
                              isloading = true;
                            });
                          }

                          String responseurl = request.url;

                          if (responseurl.contains("Failed") || responseurl.contains("failed")) {
                            if (mounted) {
                              setState(() {
                                isloading = false;
                                message = "Transaction Failed";
                              });
                            }
                            Timer(const Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          } else if (responseurl.contains("Completed") ||
                              responseurl.contains("completed") ||
                              responseurl.toLowerCase().contains("success")) {
                            if (mounted) {
                              setState(() {
                                if (mounted) {
                                  setState(() {
                                    message = "Transaction Successfull";
                                  });
                                }
                              });
                            }
                            List<String> testdata = responseurl.split("&");
                            for (String data in testdata) {
                              if (data.split("=")[0].toLowerCase() == "tx" || data.split("=")[0].toLowerCase() == "transaction_id") {
                                // String txid = data.split("=")[1];

                                //userProvider.setCartCount("0");

                                // CUR_CART_COUNT = "0";

                                if (widget.from == "order") {
                                  if (request.url.startsWith(Api.appPaymentStatusUrl)) {
                                    /* Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(builder: (BuildContext context) => ThankYouForOrderScreen(orderId: widget.orderId.toString())),
                                        ModalRoute.withName('/home')); */
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThankYouForOrderScreen(orderId: widget.orderId.toString())));
                                        context.read<GetCartCubit>().clearCartModel();
                                  } else {
                                    String txid = data.split("=")[1];

                                    placeOrder(txid);
                                  }
                                } else if (widget.from == "wallet") {
                                  if (request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
                                    String txid = data.split("=")[1];
                                    sendRequest(txid, "flutterwave");
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }

                                break;
                              }
                            }
                          }

                          if (request.url.startsWith(Api.appPaymentStatusUrl) &&
                              widget.orderId != null &&
                              (responseurl.contains('Canceled-Reversal') || responseurl.contains('Denied') || responseurl.contains('Failed'))) {
                            deleteOrder();
                          }
                          return NavigationDecision.prevent;
                        } else {}

                        return NavigationDecision.navigate;
                      },
                      
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                DateTime now = DateTime.now();
                if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
                  currentBackPressTime = now;
                  setSnackbar("Don't press back while doing payment!\n Double tap back button to exit");

                  //return Future.value(false);
                }
                if (widget.from == "order" && widget.orderId != null) deleteOrder();
                Navigator.pop(context);
              },
              child: Padding(
                  padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32,fit: BoxFit.scaleDown,))),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          centerTitle: true,
          title: Text(StringsRes.appName,
              textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        body: PopScope(
            canPop: currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2) ? false : true,
            onPopInvoked: (value) => onWillPop(),
            child: Container(
              margin: EdgeInsetsDirectional.only(top: height! / 80.0),
              decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
              width: width,
              child: Container(
                margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 50.0),
                child: Stack(
                  children: <Widget>[
                    WebViewWidget(controller: _controller,
                      /* initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      javascriptChannels: <JavascriptChannel>{
                        _toasterJavascriptChannel(context),
                      },
                      navigationDelegate: (NavigationRequest request) async {
                        //print("Url:=================***********" + request.url.toString());
                        if (request.url.startsWith(Api.appPaymentStatusUrl) || request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
                          if (mounted) {
                            setState(() {
                              isloading = true;
                            });
                          }

                          String responseurl = request.url;

                          if (responseurl.contains("Failed") || responseurl.contains("failed")) {
                            if (mounted) {
                              setState(() {
                                isloading = false;
                                message = "Transaction Failed";
                              });
                            }
                            Timer(const Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          } else if (responseurl.contains("Completed") ||
                              responseurl.contains("completed") ||
                              responseurl.toLowerCase().contains("success")) {
                            if (mounted) {
                              setState(() {
                                if (mounted) {
                                  setState(() {
                                    message = "Transaction Successfull";
                                  });
                                }
                              });
                            }
                            List<String> testdata = responseurl.split("&");
                            for (String data in testdata) {
                              if (data.split("=")[0].toLowerCase() == "tx" || data.split("=")[0].toLowerCase() == "transaction_id") {
                                // String txid = data.split("=")[1];

                                //userProvider.setCartCount("0");

                                // CUR_CART_COUNT = "0";

                                if (widget.from == "order") {
                                  if (request.url.startsWith(Api.appPaymentStatusUrl)) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(builder: (BuildContext context) => const ThankYouForOrderScreen()),
                                        ModalRoute.withName('/home'));
                                  } else {
                                    String txid = data.split("=")[1];

                                    placeOrder(txid);
                                  }
                                } else if (widget.from == "wallet") {
                                  if (request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
                                    String txid = data.split("=")[1];
                                    sendRequest(txid, "flutterwave");
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }

                                break;
                              }
                            }
                          }

                          if (request.url.startsWith(Api.appPaymentStatusUrl) &&
                              widget.orderId != null &&
                              (responseurl.contains('Canceled-Reversal') || responseurl.contains('Denied') || responseurl.contains('Failed'))) {
                            deleteOrder();
                          }
                          return NavigationDecision.prevent;
                        } else {}

                        return NavigationDecision.navigate;
                      },
                      onPageFinished: (String url) {
                        setState(() {
                          isloading = false;
                        });
                      }, */
                    ),
                    isloading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                    message.trim().isEmpty
                        ? Container()
                        : Center(
                            child: Container(
                                color: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.all(5),
                                child: Text(
                                  message,
                                  style: const TextStyle(color: white),
                                )))
                  ],
                ),
              ),
            )));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar("Don't press back while doing payment!\n Double tap back button to exit");

      return Future.value(false);
    }
    if (widget.from == "order" && widget.orderId != null) deleteOrder();
    return Future.value(true);
  }

  Future<void> sendRequest(String txnId, String payMethod) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        amountKey: widget.amt,
        transactionTypeKey: 'wallet',
        typeKey: 'credit',
        messageKey: (widget.msg == '' || widget.msg!.isEmpty) ? "Added through wallet" : widget.msg,
        txnIdKey: txnId,
        orderIdKey: orderId,
        statusKey: "success",
        paymentMethodKey: payMethod.toLowerCase()
      };

      Response response =
          await post(Uri.parse(Api.addTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      // String msg = getdata["message"];

      if (!error) {}
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(StringsRes.somethingMsg);

      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> deleteOrder() async {
    try {
      var parameter = {
        orderIdKey: widget.orderId,
      };

      Response response = await post(Uri.parse(Api.deleteOrderUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);
      print('getdata*****delete order****$getdata');
      bool error = getdata['error'];
      if (!error) {
      }

      if (mounted) {
        setState(() {
          isloading = false;
        });
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(StringsRes.somethingMsg);

      setState(() {
        isloading = false;
      });
    }
  }

  /* JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  } */

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: black),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 1.0,
    ));
  }

  double total() {
    if (isUseWallet == true) {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! + deliveryCharge + deliveryTip - promoAmt - walletBalanceUsed);
    } else {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! + deliveryCharge + deliveryTip - promoAmt + walletBalanceUsed);
    }
  }

  Future<void> placeOrder(String tranId) async {
    setState(() {
      isloading = true;
    });

    //String? mobile = context.read<SystemConfigCubit>().getMobile();
    String? varientId, quantity;
    final cartModel = context.read<GetCartCubit>().getCartModel();
    varientId = cartModel.variantId!.join(",");
    for (int i = 0; i < cartModel.data!.length; i++) {
      quantity = quantity != null ? "$quantity,${cartModel.data![i].qty!}" : cartModel.data![i].qty!;
    }
    String payVia;

    payVia = "flutterwave";

    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        mobileKey: context.read<AddressCubit>().gerCurrentAddress().mobile==""?context.read<SystemConfigCubit>().getMobile():context.read<AddressCubit>().gerCurrentAddress().mobile, //context.read<SystemConfigCubit>().getMobile(),
        productVariantIdKey: varientId,
        quantityKey: quantity,
        totalKey: subTotal.toString(),
        finalTotalKey: total().toStringAsFixed(2),
        deliveryChargeKey: deliveryCharge.toString(),
        taxAmountKey: taxAmount.toString(),
        taxPercentageKey: taxPercentage.toString(),
        latitudeKey: latitude.toString(),
        longitudeKey: longitude.toString(),
        paymentMethodKey: payVia,
        addressIdKey: selAddress,
        isWalletUsedKey: isUseWallet! ? "1" : "0",
        walletBalanceUsedKey: isPayLayShow.toString(),
        orderNoteKey: widget.addNote ?? "",
        deliveryTipKey: deliveryTip.toString(),
      };

      if (isPromoValid!) {
        parameter["promo_code"] = promoCode;
      }

      Response response = await post(Uri.parse(Api.placeOrderUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          String orderId = getdata["order_id"].toString();
          addTransaction(tranId, orderId, "Success", msg, true);
        } else {
          setSnackbar(msg!);
        }
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  Future<void> addTransaction(String tranId, String orderID, String status, String? msg, bool redirect) async {
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        orderIdKey: orderID,
        typeKey: paymentMethod,
        txnIdKey: tranId,
        amountKey: finalTotal.toString(),
        statusKey: status,
        messageKey: msg
      };

      Response response =
          await post(Uri.parse(Api.addTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          promoAmt = 0;
          remWalBal = 0;
          walletBalanceUsed = 0;
          paymentMethod = '';
          isPromoValid = false;
          isUseWallet = false;
          isPayLayShow = true;
          selectedMethod = null;
          finalTotal = 0;
          subTotal = 0;

          taxPercentage = 0;
          deliveryCharge = 0;
          orderTypeIndex = 0;

          /* Navigator.pushAndRemoveUntil(
              context, CupertinoPageRoute(builder: (BuildContext context) => ThankYouForOrderScreen(orderId: orderID.toString())), ModalRoute.withName('/home')); */
              Navigator.push(context, MaterialPageRoute(builder: (context) => ThankYouForOrderScreen(orderId: orderID.toString())));
              context.read<GetCartCubit>().clearCartModel();
        }
      } else {
        setSnackbar(msg1!);
      }
    } on TimeoutException catch (_) {
      setSnackbar(StringsRes.somethingMsg);
    }
  }
}

import 'package:project1/data/model/orderLiveTrackingModel.dart';
import 'package:project1/data/model/orderModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';


class OrderRemoteDataSource {
  //to getUserOrder
  Future<OrderModel> updateOrderStatus({String? status, String? orderId, String? reason}) async {
    try {
      //body of post request
      final body = {statusKey: status, orderIdKey: orderId, reasonKey: reason ?? ""};
      final result = await Api.post(body: body, url: Api.updateOrderStatusUrl, token: true, errorCode: true);
      return OrderModel.fromJson(result["data"][0]);
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to getUserOrderLiveTracking
  Future<OrderLiveTrackingModel> getOrderLiveTracing({String? orderId}) async {
    try {
      //body of post request
      final body = {orderIdKey: orderId};
      final result = await Api.post(body: body, url: Api.getLiveTrackingDetailsUrl, token: true, errorCode: true);
      return OrderLiveTrackingModel.fromJson(result['data'][0]);
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  ///to reOrder
  Future<dynamic> reOrder(
      {String? orderId}) async {
    try {
      //body of post request
      final body = {
        orderIdKey: orderId
      };
      final result = await Api.post(body: body, url: Api.reOrderUrl, token: true, errorCode: true);
      print("result:$result");
      return result;
    } catch (e) {
      //print(e.toString());
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}

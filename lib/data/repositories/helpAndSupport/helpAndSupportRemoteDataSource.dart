import 'dart:io';
import 'package:project1/data/model/helpAndSupportModel.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';


class HelpAndSupportRemoteDataSource {
  Future<List<HelpAndSupportModel>> getHelpAndSupport() async {
    try {
      final body = {};
      final result = await Api.post(body: body, url: Api.getTicketTypesUrl, token: true, errorCode: false);
      return (result['data'] as List).map((e) => HelpAndSupportModel.fromJson(Map.from(e))).toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future getAddTicket(String? ticketTypeId, String? subject, String? email, String? description, String? userId) async {
    try {
      final body = {ticketTypeIdKey: ticketTypeId, subjectKey: subject, emailKey: email, descriptionKey: description, userIdKey: userId};
      final result = await Api.post(body: body, url: Api.addTicketUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future getEditTicket(String? ticketId, String? ticketTypeId, String? subject, String? email, String? description, String? userId, String? status) async {
    try {
      final body = {ticketIdKey: ticketId, ticketTypeIdKey: ticketTypeId, subjectKey: subject, emailKey: email, descriptionKey: description, userIdKey: userId, statusKey: status};
      final result = await Api.post(body: body, url: Api.editTicketUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
  /*user_type:user
  user_id:1
  ticket_id:1
  message:test
  attachments[]:files  {optional} {type allowed -> image,video,document,spreadsheet,archive}*/

  Future setMessage(String? userType, String? userId, String? ticketId, String? message, List<File>? attachments) async {
    try {
      final body = {userTypeKey: userType, userIdKey: userId, ticketIdKey: ticketId, messageKey: message};
      final result = await Api.post(body: body, url: Api.sendMessageUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

}

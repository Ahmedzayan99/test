import 'package:project1/data/model/faqsModel.dart';
import 'package:project1/utils/api.dart';


class FaqsRemoteDataSource {
  Future<List<FaqsModel>> getFaqs() async {
    try {
      final body = {};
      final result = await Api.post(body: body, url: Api.getFaqsUrl, token: true, errorCode: false);
      return (result['data'] as List).map((e) => FaqsModel.fromJson(Map.from(e))).toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}

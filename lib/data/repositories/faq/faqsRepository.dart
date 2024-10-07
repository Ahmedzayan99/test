import 'package:project1/data/model/faqsModel.dart';
import 'package:project1/data/repositories/faq/faqsRemoteDataSource.dart';
import 'package:project1/utils/api.dart';

class FaqsRepository {
  static final FaqsRepository _faqsRepository = FaqsRepository._internal();
  late FaqsRemoteDataSource _faqsRemoteDataSource;

  factory FaqsRepository() {
    _faqsRepository._faqsRemoteDataSource = FaqsRemoteDataSource();
    return _faqsRepository;
  }

  FaqsRepository._internal();

  Future<List<FaqsModel>> getFaqs() async {
    try {
      List<FaqsModel> result = await _faqsRemoteDataSource.getFaqs();
      return result/*.map((e) => FaqsModel.fromJson(Map.from(e))).toList()*/;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

}

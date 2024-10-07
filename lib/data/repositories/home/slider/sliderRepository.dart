import 'package:project1/data/model/sliderModel.dart';
import 'package:project1/data/repositories/home/slider/sliderRemoteDataSource.dart';
import 'package:project1/utils/api.dart';

class SliderRepository {
  static final SliderRepository _sliderRepository = SliderRepository._internal();
  late SliderRemoteDataSource _sliderRemoteDataSource;

  factory SliderRepository() {
    _sliderRepository._sliderRemoteDataSource = SliderRemoteDataSource();
    return _sliderRepository;
  }

  SliderRepository._internal();

  Future<List<SliderModel>> getSlider() async {
    try {
      List<SliderModel> result = await _sliderRemoteDataSource.getSlider();
      return result/*.map((e) => SliderModel.fromJson(Map.from(e))).toList()*/;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

}

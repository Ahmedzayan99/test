import 'package:project1/data/model/sliderModel.dart';
import 'package:project1/utils/api.dart';


class SliderRemoteDataSource {
  Future<List<SliderModel>> getSlider() async {
    try {
      final body = {};
      final result = await Api.post(body: body, url: Api.getSliderImagesUrl, token: true, errorCode: false);
      return (result['data'] as List).map((e) => SliderModel.fromJson(Map.from(e))).toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}

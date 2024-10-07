import 'package:project1/data/localDataStore/settingsLocalDataSource.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/hiveBoxKey.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  static final SettingsRepository _settingsRepository = SettingsRepository._internal();
  late SettingsLocalDataSource _settingsLocalDataSource;

  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  Map<String, dynamic> getCurrentSettings() {
    return {
      "showIntroSlider": _settingsLocalDataSource.showIntroSlider(),
      "notification": _settingsLocalDataSource.notification(),
      "cityId": _settingsLocalDataSource.showCityId(),
      "city": _settingsLocalDataSource.showCity(),
      "latitude": _settingsLocalDataSource.showLatitude(),
      "longitude": _settingsLocalDataSource.showLongitude(),
      "address": _settingsLocalDataSource.showAddress(),
      "cartCount": _settingsLocalDataSource.showCartCount(),
      "cartTotal": _settingsLocalDataSource.showCartTotal(),
      "restaurantId": _settingsLocalDataSource.showRestaurantId(),
      "skip": _settingsLocalDataSource.showSkip(),
    };
  }

  void changeIntroSlider(bool value) => _settingsLocalDataSource.setShowIntroSlider(value);
  void changeSkip(bool value) => _settingsLocalDataSource.setSkip(value);
  void changeCity(String city) => _settingsLocalDataSource.setCity(city);
  void changeCityId(String cityId) => _settingsLocalDataSource.setCityId(cityId);
  void changeLatitude(String latitude) => _settingsLocalDataSource.setLatitude(latitude);
  void changeLongitude(String longitude) => _settingsLocalDataSource.setLongitude(longitude);
  void changeAddress(String address) => _settingsLocalDataSource.setAddress(address);
  void changeCartCount(String cartCount) => _settingsLocalDataSource.setCartCount(cartCount);
  void changeCartTotal(String cartTotal) => _settingsLocalDataSource.setCartTotal(cartTotal);
  void changeRestaurantId(String restaurantId) => _settingsLocalDataSource.setRestaurantId(restaurantId);

  void changeNotification(bool value) => _settingsLocalDataSource.setNotification(value);
  String getCurrentLanguageCode() {
    return Hive.box(settingsBox).get(currentLanguageCodeKey) ??
        defaultLanguageCode;
  }

  Future<void> setCurrentLanguageCode(String value) async {
    Hive.box(settingsBox).put(currentLanguageCodeKey, value);
  }
}

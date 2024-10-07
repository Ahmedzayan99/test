//State
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/data/model/settingsModel.dart';
import 'package:project1/data/repositories/settings/settingsRepository.dart';

class SettingsState {
  final SettingsModel? settingsModel;
  SettingsState({this.settingsModel});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository) : super(SettingsState()) {
    _getCurrentSettings();
  }

  void _getCurrentSettings() {
    emit(SettingsState(settingsModel: SettingsModel.fromJson(_settingsRepository.getCurrentSettings())));
  }

  SettingsModel getSettings() {
    return state.settingsModel!;
  }

  void changeShowIntroSlider() {
    _settingsRepository.changeIntroSlider(false);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(showIntroSlider: false)));
  }

  void changeShowSkip() {
    _settingsRepository.changeSkip(false);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(skip: false)));
  }

  setCity(String city) {
    _settingsRepository.changeCity(city);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(city: city)));
  }

  setCityId(String cityId) {
    _settingsRepository.changeCityId(cityId);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(cityId: cityId)));
  }

  setLatitude(String latitude) {
    _settingsRepository.changeLatitude(latitude);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(latitude: latitude)));
  }

  setLongitude(String longitude) {
    _settingsRepository.changeLongitude(longitude);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(longitude: longitude)));
  }

  setAddress(String address) {
    _settingsRepository.changeAddress(address);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(address: address)));
  }

  setCartCount(String cartCount) {
    _settingsRepository.changeCartCount(cartCount);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(cartCount: cartCount)));
  }

  setCartTotal(String cartTotal) {
    _settingsRepository.changeCartTotal(cartTotal);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(cartTotal: cartTotal)));
  }

  setRestaurantId(String restaurantId) {
    _settingsRepository.changeRestaurantId(restaurantId);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(restaurantId: restaurantId)));
  }

  void changeNotification(bool value) {
    _settingsRepository.changeNotification(value);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(notification: value)));
  }
}

import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CityDeliverableState {}

class CityDeliverableInitial extends CityDeliverableState {}

class CityDeliverableProgress extends CityDeliverableState {}

class CityDeliverableSuccess extends CityDeliverableState {
  final String? name, cityId;

  CityDeliverableSuccess(this.name, this.cityId);
}

class CityDeliverableFailure extends CityDeliverableState {
  final String errorStatusCode, errorMessage;
  CityDeliverableFailure(this.errorMessage, this.errorStatusCode);
}

class CityDeliverableCubit extends Cubit<CityDeliverableState> {
  final AddressRepository _addressRepository;

  CityDeliverableCubit(this._addressRepository) : super(CityDeliverableInitial());

  fetchCityDeliverable(String? name) {
    emit(CityDeliverableProgress());
    _addressRepository.getCityDeliverable('cairo').then((value) => emit(CityDeliverableSuccess(name, value))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("cityDeliverableError:${apiMessageAndCodeException.errorMessage}");
      emit(CityDeliverableFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getCityId() {
    if (state is CityDeliverableSuccess) {
      //print("check City Id :"+(state as CityDeliverableSuccess).cityId!);
      return (state as CityDeliverableSuccess).cityId!;
    } else if (state is CityDeliverableFailure) {
      //print("city..!!");
    }
    return "";
  }
}

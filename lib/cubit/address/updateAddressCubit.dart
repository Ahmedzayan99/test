import 'package:project1/data/model/addressModel.dart';
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateAddressState {}

class UpdateAddressInitial extends UpdateAddressState {}

class UpdateAddressProgress extends UpdateAddressState {}

class UpdateAddressSuccess extends UpdateAddressState {
  final AddressModel addressModel;

  UpdateAddressSuccess(this.addressModel);
}

class UpdateAddressFailure extends UpdateAddressState {
  final String errorStatusCode, errorMessage;
  UpdateAddressFailure(this.errorMessage, this.errorStatusCode);
}

class UpdateAddressCubit extends Cubit<UpdateAddressState> {
  final AddressRepository _addressRepository;

  UpdateAddressCubit(this._addressRepository) : super(UpdateAddressInitial());

  void fetchUpdateAddress(String? id, String? userId, String? mobile, String? address, String? city, String? latitude, String? longitude,
      String? area, String? type, String? name, String? countryCode, String? alternateCountryCode, String? alternateMobile, String? landmark, String? pincode, String? state, String? country, String? isDefault) {
    emit(UpdateAddressProgress());
    _addressRepository.getUpdateAddress(id, userId, mobile, address, city, latitude, longitude,
        area, type, name, countryCode, alternateCountryCode, alternateMobile, landmark, pincode, state, country, isDefault).then((value) => emit(UpdateAddressSuccess(AddressModel(id: id, userId: userId, mobile: mobile, address: address, city: city, latitude: latitude, longitude: longitude, area: area, type: type, name: name, countryCode: countryCode, alternateMobile: alternateMobile, landmark: landmark, pincode: pincode, state: state, country: country, isDefault: isDefault)))).catchError((e) {
          ApiMessageAndCodeException apiMessageAndCodeException = e;
          //print("updateAddressError:${apiMessageAndCodeException.errorMessage}");
          emit(UpdateAddressFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }


  String getCity() {
    if (state is UpdateAddressSuccess) {
      print((state as UpdateAddressSuccess).addressModel.city!);
      return (state as UpdateAddressSuccess).addressModel.city!;
    }
    return "";
  }

  String getLatitude() {
    if (state is UpdateAddressSuccess) {
      return (state as UpdateAddressSuccess).addressModel.latitude!;
    }
    return "";
  }

  String getLongitude() {
    if (state is UpdateAddressSuccess) {
      return (state as UpdateAddressSuccess).addressModel.longitude!;
    }
    return "";
  }
}
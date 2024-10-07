import 'package:project1/data/model/addressModel.dart';
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddAddressState {}

class AddAddressInitial extends AddAddressState {}

class AddAddressProgress extends AddAddressState {}

class AddAddressSuccess extends AddAddressState {
  final AddressModel addressModel;

  AddAddressSuccess(this.addressModel);
}

class AddAddressFailure extends AddAddressState {
  final String errorStatusCode, errorMessage;
  AddAddressFailure(this.errorMessage, this.errorStatusCode);
}

class AddAddressCubit extends Cubit<AddAddressState> {
  final AddressRepository _addAddressRepository;

  AddAddressCubit(this._addAddressRepository) : super(AddAddressInitial());

  void fetchAddAddress(
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) {
    emit(AddAddressProgress());
    _addAddressRepository
        .getAddAddress(
            userId,
            mobile,
            address,
            city,
            latitude,
            longitude,
            area,
            type,
            name,
            countryCode,
            alternateCountryCode,
            alternateMobile,
            landmark,
            pincode,
            state,
            country,
            isDefault)
        .then((value) => emit(AddAddressSuccess(AddressModel.fromJson(value))))
        .catchError((e) {
          ApiMessageAndCodeException apiMessageAndCodeException = e;
          //print("addAddressError:${apiMessageAndCodeException.errorMessage}");
      emit(AddAddressFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getCity() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel.city!;
    }
    return "";
  }

  String getLatitude() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel.latitude!;
    }
    return "";
  }

  String getLongitude() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel.longitude!;
    }
    return "";
  }

  /* AddressModel getAddress() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel;
    }
    return AddressModel();
  } */
}

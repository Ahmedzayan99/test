import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAddressState {}

class DeleteAddressInitial extends DeleteAddressState {}

class DeleteAddressProgress extends DeleteAddressState {}

class DeleteAddressSuccess extends DeleteAddressState {
  final String id;

  DeleteAddressSuccess(this.id);
}

class DeleteAddressFailure extends DeleteAddressState {
  final String errorStatusCode, errorMessage;
  DeleteAddressFailure(this.errorMessage, this.errorStatusCode);
}

class DeleteAddressCubit extends Cubit<DeleteAddressState> {
  final AddressRepository _addressRepository;

  DeleteAddressCubit(this._addressRepository) : super(DeleteAddressInitial());

  void fetchDeleteAddress(String? id) {
    emit(DeleteAddressProgress());
    _addressRepository.getDeleteAddress(id).then((value)  {
      emit(DeleteAddressSuccess(id!));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("deleteAddressError:${apiMessageAndCodeException.errorMessage}");
      emit(DeleteAddressFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }
}
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeliveryChargeState {}

class DeliveryChargeInitial extends DeliveryChargeState {}

class DeliveryChargeProgress extends DeliveryChargeState {}

class DeliveryChargeSuccess extends DeliveryChargeState {
  final String? userId, addressId, delivaryCharge, isFreeDelivery;

  DeliveryChargeSuccess(this.userId, this.addressId, this.delivaryCharge, this.isFreeDelivery);
}

class DeliveryChargeFailure extends DeliveryChargeState {
  final String errorStatusCode, errorMessage;
  DeliveryChargeFailure(this.errorMessage, this.errorStatusCode);
}

class DeliveryChargeCubit extends Cubit<DeliveryChargeState> {
  final AddressRepository _addressRepository;

  DeliveryChargeCubit(this._addressRepository) : super(DeliveryChargeInitial());

  fetchDeliveryCharge(String? userId, String? addressId, String? finalTotal) {
    emit(DeliveryChargeProgress());
    _addressRepository.getDeliveryCharge(userId, addressId, finalTotal).then((value) => emit(DeliveryChargeSuccess(userId, addressId, value['delivery_charge'], value['is_free_delivery'] ?? ""))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      //print("DeliveryChargeError:${apiMessageAndCodeException.errorMessage}");
      emit(DeliveryChargeFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getDeliveryCharge() {
    if (state is DeliveryChargeSuccess) {
      return (state as DeliveryChargeSuccess).delivaryCharge!;
    }
    return "";
  }
}

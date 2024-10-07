import 'package:project1/data/model/bestOfferModel.dart';
import 'package:project1/data/repositories/home/bestOffer/bestOfferRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BestOfferState {}

class BestOfferInitial extends BestOfferState {}

class BestOfferProgress extends BestOfferState {}

class BestOfferSuccess extends BestOfferState {
  final List<BestOfferModel> bestOfferList;

  BestOfferSuccess(this.bestOfferList);
}

class BestOfferFailure extends BestOfferState {
  final String errorCode;

  BestOfferFailure(this.errorCode);
}

class BestOfferCubit extends Cubit<BestOfferState> {
  final BestOfferRepository _bestOfferRepository;

  BestOfferCubit(this._bestOfferRepository) : super(BestOfferInitial());

  void fetchBestOffer() {
    emit(BestOfferProgress());
    _bestOfferRepository.getBestOffer().then((value) => emit(BestOfferSuccess(value))).catchError((e) {
      //print("bestOfferError:${e.toString()}");
      emit(BestOfferFailure(e.toString()));
    });
  }
}

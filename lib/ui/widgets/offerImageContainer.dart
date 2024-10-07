import 'package:project1/data/model/bestOfferModel.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';

class OfferImageContainer extends StatelessWidget {
  final List<BestOfferModel> bestOfferList;
  final double? width, height;
  final int index;
  const OfferImageContainer(
      {Key? key,
      required this.bestOfferList,
      this.width,
      this.height,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsetsDirectional.only(
            top: height! / 88.0, start: width! / 20.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          child: DesignConfig.imageWidgets(bestOfferList[index].image!, height! / 4.7, width! / 2.75,"2"),
        ));
  }
}

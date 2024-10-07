import 'package:project1/data/model/cuisineModel.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';

class CuisineContainer extends StatelessWidget {
  final List<CuisineModel> cuisineList;
  final double? width, height;
  final int index;
  const CuisineContainer(
      {Key? key,
      required this.cuisineList,
      this.width,
      this.height,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: height! / 88.0,),
      child: Container(
        alignment: Alignment.center,
        width: width! / 3.5,
        height: height! / 6.8,
        decoration: DesignConfig.boxDecorationContainerBorder(
            Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.07), 10.0),
        padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0, start: 2.0, end: 2.0),
        margin:
            EdgeInsetsDirectional.only(top: 2.0, start: width! / 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: DesignConfig.boxDecorationContainerShadow1(context),
              alignment: Alignment.center,
              child: ClipOval(
                  child: DesignConfig.imageWidgets(
                      cuisineList[index].image!, 55.0, 55.0, "2")),
            ),
            const SizedBox(height: 6.0),
            Text(cuisineList[index].name!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

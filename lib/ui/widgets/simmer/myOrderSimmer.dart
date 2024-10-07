import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyOrderSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;

  const MyOrderSimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
      child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: length!,
          itemBuilder: (BuildContext context, index) {
            return Container(
              decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 10.0),
              padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
              width: width!,
              margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
              child: Container(
                width: 40.0,
                height: height! / 4.0,
                color: shimmerContentColor,
              ),
            );
          }),
    ));
  }
}

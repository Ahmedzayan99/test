import 'package:project1/ui/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BottomCartSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  final bool? show;

  const BottomCartSimmer({Key? key, this.length, this.width, this.height, this.show}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(bottom: show == true ? height! / 9.9 : height! / 9.9),
      width: width,
      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 20.0, end: width! / 20.0),
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40.0,
              height: 10.0,
              color: shimmerContentColor,
            ),
            const Spacer(),
            Container(
              width: 40.0,
              height: 10.0,
              color: shimmerContentColor,
            )
          ],
        ),
      ),
    );
  }
}

import 'package:project1/ui/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CuisineVerticallySimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const CuisineVerticallySimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerhighlightColor,
            // enabled: _enabled,
            child: Container(
                height: height! / 2.8,
                margin: EdgeInsetsDirectional.only(start: width! / 20.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: length!,
                    itemBuilder: (BuildContext context, index) {
                      return Container(
                        padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
                        width: width!,
                        margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
                        child: Container(
                          width: width!,
                          height: 10.0,
                          color: shimmerContentColor,
                        ),
                      );
                    }))));
  }
}

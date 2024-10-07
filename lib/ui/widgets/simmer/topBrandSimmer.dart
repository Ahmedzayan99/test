import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TopBrandSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const TopBrandSimmer({Key? key, this.width, this.height, this.length}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerhighlightColor,
            // enabled: _enabled,
            child: SizedBox(
              height: height!,
              child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  scrollDirection: length==2?Axis.horizontal:Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: length,
                  itemBuilder: (BuildContext context, i) {
                    return Container(
                        decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 10.0),
                        padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                        //height: height!/4.7,,
                        margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: length==2?0.0:width! / 40.0),
                        height: height! / 4.0, width: width! / 1.1);
                  }),
            )));
  }
}

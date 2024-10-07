import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PromoCodeSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  final String? type;
  const PromoCodeSimmer({Key? key, this.length, this.width, this.height, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
      child: SizedBox(
        height: height! / 1.3,
        child: type == "horizontal"
            ? ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (BuildContext context, index) {
                  return InkWell(
                      onTap: () {},
                      child: Container(
                          margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0, top: height! / 80.0),
                          decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 10.0)));
                })
            : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.1,
                children: List.generate(8, (index) {
                  return InkWell(
                    onTap: () {},
                    child: Container(
                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 80.0, top: height! / 80.0),
                      decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 10.0),
                    ),
                  );
                })),
      ),
    ));
  }
}

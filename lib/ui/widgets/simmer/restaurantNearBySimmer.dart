import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantNearBySimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const RestaurantNearBySimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

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
                padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 99.0, end: width! / 40.0, bottom: height! / 99.0),
                width: width!,
                margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      flex: 2,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                          child: Container(color: shimmerContentColor, width: width! / 5.0, height: height! / 8.2))),
                  Expanded(
                      flex: 5,
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40.0,
                                      height: 10.0,
                                      color: shimmerContentColor,
                                    ),
                                    SizedBox(width: width! / 50.0),
                                    Container(color: shimmerContentColor, width: 15, height: 15),
                                  ],
                                ),
                                Align(alignment: Alignment.topRight, child: Container(color: shimmerContentColor, width: 15.0, height: 12.8)),
                              ],
                            ),
                            SizedBox(height: height! / 99.0),
                            Container(height: 10.0, width: 30.0, color: shimmerContentColor),
                            SizedBox(height: height! / 99.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(height: 15.5, width: 15.5, color: shimmerContentColor),
                                    SizedBox(width: width! / 99.0),
                                    Container(height: 10.0, width: 40.0, color: shimmerContentColor),
                                  ],
                                ),
                                SizedBox(width: width! / 60.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(height: 15.5, width: 15.5, color: shimmerContentColor),
                                    SizedBox(width: width! / 99.0),
                                    Container(height: 10.0, width: 40.0, color: shimmerContentColor),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                                height: 10.0,
                                width: double.maxFinite,
                                margin: EdgeInsetsDirectional.only(top: height! / 99.0),
                                padding: const EdgeInsetsDirectional.only(top: 2, bottom: 2, start: 3.8, end: 3.8),
                                decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 5)),
                          ])))
                ]));
          }),
    ));
  }
}

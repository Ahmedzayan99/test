import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/widgets/simmer/cuicineSimmer.dart';
import 'package:project1/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project1/ui/widgets/simmer/sectionSimmer.dart';
import 'package:project1/ui/widgets/simmer/sliderSimmer.dart';
import 'package:project1/ui/widgets/simmer/topBrandSimmer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSimmer extends StatelessWidget {
  final double? width, height;
  const HomeSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerhighlightColor,
            // enabled: _enabled,
            child: SizedBox(
                height: height,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(children: [
                    SliderSimmer(width: width, height: height),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 50.0, bottom: height! / 20.0),
                      child: Row(children: [
                        Container(
                          width: width! / 4.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                        const Spacer(),
                        Container(
                          width: width! / 20.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                      ]),
                    ),
                    CuisineSimmer(length: 3, width: width, height: height! / 4.9),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 50.0, bottom: height! / 20.0),
                      child: Row(children: [
                        Container(
                          width: width! / 4.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                        const Spacer(),
                        Container(
                          width: width! / 20.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                      ]),
                    ),
                    TopBrandSimmer(width: width, height: height!/5.0, length: 2),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 50.0, bottom: height! / 20.0),
                      child: Row(children: [
                        Container(
                          width: width! / 4.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                        const Spacer(),
                        Container(
                          width: width! / 20.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                      ]),
                    ),
                    /* SliderSimmer(width: width, height: height),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 50.0, bottom: height! / 20.0),
                      child: Row(children: [
                        Container(
                          width: width! / 4.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                        const Spacer(),
                        Container(
                          width: width! / 20.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                      ]),
                    ), */
                    /* Padding(
                      padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 50.0, bottom: height! / 20.0),
                      child: Row(children: [
                        Container(
                          width: width! / 4.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                        const Spacer(),
                        Container(
                          width: width! / 20.0,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                      ]),
                    ), */
                    RestaurantNearBySimmer(length: 5, width: width!, height: height!),
                    SectionSimmer(length: 4, width: width!, height: height!),
                    SizedBox(height: height! / 20.0),
                  ]),
                ))));
  }
}

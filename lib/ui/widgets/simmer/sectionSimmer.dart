import 'package:project1/ui/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SectionSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const SectionSimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerhighlightColor,
            // enabled: _enabled,
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                // scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (BuildContext buildContext, index) {
                  return Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 60.0),
                          child: Container(color: shimmerContentColor, height: 10.0, width: width! / 1.5),
                        ),
                        const Spacer(),
                      ]),
                      SizedBox(
                        height: height! / 4.0,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (BuildContext buildContext, i) {
                              return Container(
                                margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 80.0),
                                child:ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        child: Container(
                                          color: shimmerContentColor,
                                          width: width! / 2.32,
                                          height: height! / 5.0,
                                        )),
                              );
                            }),
                      ),
                    ],
                  );
                })));
  }
}

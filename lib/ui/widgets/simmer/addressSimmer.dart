import 'package:project1/ui/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddressSimmer extends StatelessWidget {
  final double? width, height;
  const AddressSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        // enabled: _enabled,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (_, __) => Container(
            margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
            padding: EdgeInsets.symmetric(vertical: height! / 40.0, horizontal: height! / 40.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 25.0,
                  height: 25.0,
                  color: shimmerContentColor,
                ),
                SizedBox(width: height! / 99.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 40.0,
                        height: 10.0,
                        color: shimmerContentColor,
                      ),
                      SizedBox(height: height! / 99.0),
                      Container(
                        width: double.maxFinite,
                        height: 10.0,
                        color: shimmerContentColor,
                      ),
                      SizedBox(height: height! / 99.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsetsDirectional.only(end: width! / 99.0, top: height! / 99.0),
                            width: width! / 5.0,
                            padding: EdgeInsetsDirectional.only(
                              top: height! / 99.0,
                              bottom: height! / 99.0,
                            ),
                            height: 30.0,
                            color: shimmerContentColor,
                          ),
                          SizedBox(width: height! / 99.0),
                          Container(
                            margin: EdgeInsetsDirectional.only(start: width! / 15.0, end: width! / 99.0, top: height! / 99.0),
                            width: width! / 5.0,
                            padding: EdgeInsetsDirectional.only(
                              top: height! / 99.0,
                              bottom: height! / 99.0,
                            ),
                            height: 30.0,
                            color: shimmerContentColor,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 2.0,
                        color: shimmerContentColor,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          itemCount: 5,
        ),
      ),
    );
  }
}

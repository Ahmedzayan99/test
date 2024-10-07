import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MapDataLoadSimmer extends StatelessWidget {
  final double? width, height;
  const MapDataLoadSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        // enabled: _enabled,
        child: Container(
            margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
            padding: EdgeInsets.symmetric(vertical: height! / 40.0, horizontal: height! / 40.0),
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.maxFinite,
                  height: 20.0,
                  color: shimmerContentColor,
                ),
                SizedBox(height: height! / 99.0),
                Container(
                  width: double.maxFinite,
                  height: 2.0,
                  color: shimmerContentColor,
                ),
                SizedBox(height: height! / 40.0),
                Row(
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
                          
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: height! / 99.0),
                Container(
                  width: double.maxFinite,
                  height: 2.0,
                  color: shimmerContentColor,
                ),
                SizedBox(height: height! / 40.0),
                Container(
                  margin: EdgeInsetsDirectional.only(end: width! / 99.0, top: height! / 99.0),
                  width: width,
                  padding: EdgeInsetsDirectional.only(
                    top: height! / 99.0,
                    bottom: height! / 99.0,
                  ),
                  height: height! / 15.0,
                  decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 15),
                ),
                SizedBox(width: height! / 99.0),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

class MapLoadSimmer extends StatelessWidget {
  final double? width, height;
  const MapLoadSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        // enabled: _enabled,
        child: Container(
            margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
            padding: EdgeInsets.symmetric(vertical: height! / 99.0, horizontal: height! / 99.0),
            child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: shimmerContentColor,
                ),
          ),
      ),
    );
  }
}

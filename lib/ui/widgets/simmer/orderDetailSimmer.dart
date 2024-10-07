import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderSimmer extends StatelessWidget {
  final double? width, height;
  const OrderSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerhighlightColor,
            // enabled: _enabled,
            child: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 30.0),
                height: height! / 0.9,
                width: width,
                child: Container(
                    padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 99.0),
                    //height: height!/4.7,
                    width: width!,
                    margin: EdgeInsetsDirectional.only(top: height! / 70.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 25.0,
                                  height: 25.0,
                                  color: Colors.white,
                                ),
                                SizedBox(width: height! / 99.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: double.maxFinite,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: height! / 99.0),
                                      Container(
                                        width: double.maxFinite,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0),
                              child: Container(
                                width: 5.0,
                                height: height! / 15.0,
                                color: Colors.white,
                              )),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 25.0,
                                  height: 25.0,
                                  color: Colors.white,
                                ),
                                SizedBox(width: height! / 99.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: double.maxFinite,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: height! / 99.0),
                                      Container(
                                        width: double.maxFinite,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 80.0, bottom: height! / 50.0),
                              child: Container(
                                width: width! / 4.0,
                                height: 2.0,
                                color: shimmerContentColor,
                              )),
                          SizedBox(
                            height: height! / 4.5,
                            child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 2,
                                itemBuilder: (BuildContext context, i) {
                                  return Container(
                                    margin: const EdgeInsetsDirectional.only(top: 5),
                                    padding: EdgeInsetsDirectional.only(bottom: height! / 99.0, start: width! / 40.0, end: width! / 40.0),
                                    child: Column(children: [
                                      Container(
                                        width: width!,
                                        height: height! / 12.0,
                                        color: shimmerContentColor,
                                      ),
                                    ]),
                                  );
                                }),
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 80.0, bottom: height! / 50.0),
                              child: Container(
                                width: width! / 4.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 99.0, start: width! / 40.0, end: width! / 40.0),
                            child: Container(
                              width: width! / 4.0,
                              height: 8.0,
                              color: shimmerContentColor,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 70.0, start: width! / 40.0, end: width! / 40.0),
                            child: Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              ),
                              const Spacer(),
                              Container(
                                width: width! / 20.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )
                            ]),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 70.0, start: width! / 40.0, end: width! / 40.0),
                            child: Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              ),
                              const Spacer(),
                              Container(
                                width: width! / 20.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )
                            ]),
                          ),
                          Container(
                            width: width! / 4.0,
                            height: height! / 10.0,
                            color: shimmerContentColor,
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(top: height! / 70.0, start: width! / 40.0),
                              child: Container(
                                width: width! / 4.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: width! / 4.0,
                                  height: 8.0,
                                  color: shimmerContentColor,
                                ),
                                const Spacer(),
                                Container(
                                  width: width! / 10.0,
                                  height: 8.0,
                                  color: shimmerContentColor,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 70.0),
                            child: DesignConfig.divider(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(top: height! / 70.0, bottom: height! / 70.0),
                            child: DesignConfig.divider(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: width! / 4.0,
                                  height: 8.0,
                                  color: shimmerContentColor,
                                ),
                                const Spacer(),
                                Container(
                                  width: 15.0,
                                  height: 15.0,
                                  color: shimmerContentColor,
                                )
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 70.0, bottom: height! / 70.0),
                              child: Container(
                                width: width! / 4.0,
                                height: 2.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: width! / 40.0,
                                end: width! / 40.0,
                              ),
                              child: Container(
                                width: width! / 4.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 70.0, bottom: height! / 70.0),
                              child: Container(
                                width: width! / 4.0,
                                height: 2.0,
                                color: shimmerContentColor,
                              )),
                          Container(
                            margin: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            padding: EdgeInsetsDirectional.only(start: width! / 20.0, bottom: height! / 99.0),
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          Container(
                            margin: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            padding: EdgeInsetsDirectional.only(start: width! / 20.0, bottom: height! / 99.0),
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 40.0, top: height! / 70.0, bottom: height! / 70.0),
                              child: Container(
                                width: width! / 4.0,
                                height: 2.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: width! / 40.0,
                                end: width! / 40.0,
                              ),
                              child: Container(
                                width: width! / 4.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: 4.5,
                              bottom: 4.5,
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              ),
                              const Spacer(),
                              Container(
                                width: width! / 20.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              ),
                              const Spacer(),
                              Container(
                                width: width! / 20.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )
                            ]),
                          ),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                              child: Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              ),
                              const Spacer(),
                              Container(
                                width: width! / 20.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )
                            ]),
                          ),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                              child: Container(
                                width: width! / 4.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              ),
                              const Spacer(),
                              Container(
                                width: width! / 20.0,
                                height: 8.0,
                                color: shimmerContentColor,
                              )
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: 4.5,
                              bottom: 4.5,
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
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
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
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
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: 4.5,
                              bottom: 4.5,
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Container(
                              width: width! / 3.0,
                              height: 2.0,
                              color: shimmerContentColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: width! / 40.0,
                              end: width! / 40.0,
                            ),
                            child: Row(children: [
                              Container(
                                width: width! / 3.0,
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
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                            child: Container(
                              width: width! / 3.0,
                              height: 2.0,
                              color: shimmerContentColor,
                            ),
                          ),
                          Container(
                              margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0),
                              width: width,
                              height: height! / 20.0,
                              padding:
                                  EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 20.0, end: width! / 20.0),
                              decoration: DesignConfig.boxDecorationContainer(shimmerContentColor, 100.0)),
                        ],
                      ),
                    )))));
  }
}

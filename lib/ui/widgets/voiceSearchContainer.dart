import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VoiceSearchContainer extends StatelessWidget {
  final double? width, height;
  const VoiceSearchContainer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: const EdgeInsets.all(8.0),
            margin: EdgeInsetsDirectional.only(start: width!/99.0, top: height! / 99.0, bottom: height! / 99.0),
            width: width!/8.0,
            height: height!/16.0,
            decoration:
            DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 4.0),
            child: SvgPicture.asset(DesignConfig.setSvgPath("voice_search_icon"), fit: BoxFit.scaleDown));
  }
}
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoDataContainer extends StatelessWidget {
  final String? title, subTitle, image;
  final double? width, height;
  const NoDataContainer({Key? key, this.title, this.subTitle, this.image, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      alignment: Alignment.center,
      decoration: DesignConfig.boxDecorationContainerHalf(
          Theme.of(context).colorScheme.onSurface),
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, /*top: height! / 10.0*/ /* top: height! / 14.0 */),
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(DesignConfig.setSvgPath(image!)),
              SizedBox(height: height! / 20.0),
              Text(title!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5.0),
              Text(subTitle!, textAlign: TextAlign.center, maxLines: 3, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
      ),
    );
  }
}

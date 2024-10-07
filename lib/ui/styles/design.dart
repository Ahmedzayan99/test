import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'color.dart';

class DesignConfig {
  static RoundedRectangleBorder setRoundedBorderCard(double radius1, double radius2, double radius3, double radius4) {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius1),
            bottomRight: Radius.circular(radius2),
            topLeft: Radius.circular(radius3),
            topRight: Radius.circular(radius4)));
  }

  static RoundedRectangleBorder setRoundedBorder(Color borderColor, double radius, bool isSetSide) {
    return RoundedRectangleBorder(side: BorderSide(color: borderColor, width: isSetSide ? 1.0 : 0), borderRadius: BorderRadius.circular(radius));
  }

  static RoundedRectangleBorder setRounded(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }

  static RoundedRectangleBorder setHalfRoundedBorder(
      Color borderColor, double radius1, double radius2, double radius3, double radius4, bool isSetSide) {
    return RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: isSetSide ? 1.0 : 0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius1),
            bottomLeft: Radius.circular(radius2),
            topRight: Radius.circular(radius3),
            bottomRight: Radius.circular(radius4)));
  }

  static BoxDecoration boxDecorationContainerRoundHalf(Color color, double bradius1, double bradius2, double bradius3, double bradius4) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
    );
  }

  static BoxDecoration boxDecorationContainerShadow(Color color, double bradius1, double bradius2, double bradius3, double bradius4, BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
      boxShadow: [BoxShadow(color: color, offset: const Offset(0.0, 2.0), blurRadius: 6.0, spreadRadius: 0)],
    );
  }

  static BoxDecoration boxDecorationContainer(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static OutlineInputBorder outlineInputBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  static BoxDecoration boxDecorationContainerHalf(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(0.0), bottomLeft: Radius.circular(0.0), topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    );
  }

  static BoxDecoration boxDecorationContainerBorder(Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationContainerBorderCustom(Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color, width: 0.5),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationCircle(Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color, width: 2.0),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration circle(Color color){
    return BoxDecoration(shape: BoxShape.circle,
            color: color
          );
  }

  static setSvgPath(String name) {
    return "assets/images/svg/$name.svg";
  }

  static setPngPath(String name) {
    return "assets/images/image/4.0x/$name.png";
  }

  static setJpgPath(String name) {
    return "assets/images/image/4.0x/$name.jpg";
  }

  static setLottiePath(String name){
    return "assets/images/json/$name.json";
  }

  static BoxDecoration boxCurveShadow(Color? color) {
    return BoxDecoration(
        color: color!,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: shadow,
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -9),
          )
        ]);
  }

  /* static BoxDecoration boxCurveBottomBarShadow() {
    return const BoxDecoration(
        color: ColorsRes.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsRes.shadowBottomBar,
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, -5),
          )
        ]);
  } */

  static BoxDecoration boxDecorationContainerCardShadow(Color color, Color shadowColor, double radius, double x, double y, double b, double s) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: shadowColor, offset: Offset(x, y), blurRadius: b, spreadRadius: s),
      ],
    );
  }



  static BoxDecoration boxDecorationContainerShadow1(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface,shape: BoxShape.circle,
      boxShadow: const [BoxShadow(color: Color(0x0f292929), offset: Offset(0.0, 6.0), blurRadius: 10.0, spreadRadius: 0)],
    );
  }

  static InputDecoration inputDecorationextField (String lableText, String hintText, double width, BuildContext context) {
    return InputDecoration(labelText: lableText,
            border: InputBorder.none,
            hintText: hintText,
            labelStyle: const TextStyle(
              color: greayLightColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: greayLightColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsetsDirectional.only(start: width/20.0),
            enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: greayLightColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1.0, color: Theme.of(context).colorScheme.primary),
          ),disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: greayLightColor),
          ),
          );
  }

  static imageWidgets (String? image, double? height, double? width, String? imageStatus){
    return (image != "" && image!.isNotEmpty)
        ? FadeInImage(
            placeholder: AssetImage(
              DesignConfig.setPngPath('placeholder_square'),
            ),
            image: (imageStatus=="1")?AssetImage(
              DesignConfig.setPngPath(image),
            ):NetworkImage(
              image,
            ) as ImageProvider,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                DesignConfig.setPngPath('placeholder_square'),
                height: height,
                width: width,
                fit: BoxFit.cover,
              );
            },placeholderErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                DesignConfig.setPngPath('placeholder_square'),
                height: height,
                width: width,
                fit: BoxFit.cover,
              );
            },
            height: height!,
            width: width!,
            fit: BoxFit.cover,
          )
        : Image.asset(
            DesignConfig.setPngPath('placeholder_square'),
            height: height!,
            width: width!,
            fit: BoxFit.cover,
          );
}

static appBar(BuildContext context, double? width, String? text, bottom, {bool? status = false}){
  return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      leading: InkWell(
          onTap: () {
            if(status == false){
              Navigator.pop(context);
            }else{
              Future.delayed(Duration.zero, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
            }
          },
          child: Padding(
              padding: EdgeInsetsDirectional.only(start: width! / 20),
              child: SvgPicture.asset(
                DesignConfig.setSvgPath("back_icon"),
                width: 32,
                height: 32,
                fit: BoxFit.scaleDown,
              ))),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      shadowColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      title: Text(text!,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500)),
              bottom: bottom,
    );
}

static appBarWihoutBackbutton(BuildContext context, double? width, String? text, bottom){
  return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.secondary, //change your color here
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      shadowColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      title: Text(text!,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500)),
              bottom: bottom,
    );
}

static Divider divider(){
  return Divider(color: lightFont.withOpacity(0.85), height: 0.2, thickness: 0.2);
}

Widget spicyWidget(double? width) {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: width! / 60.0),
        child: SvgPicture.asset(DesignConfig.setSvgPath("icon_spicy"), width: 15.0, height: 15.0));
  }

  Widget bestSellerWidget(double? width, BuildContext context) {
    return Container(
        padding: EdgeInsetsDirectional.all(4.0),
        margin: EdgeInsetsDirectional.only(start: width! / 80.0),
        decoration: DesignConfig.boxDecorationContainer(yellowColor.withOpacity(0.1), 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(DesignConfig.setSvgPath("icon_bestseller"), width: 15.0, height: 15.0),
            const SizedBox(width: 3.4),
            Text(
              UiUtils.getTranslatedLabel(context, bestSellerLabel),
              textAlign: TextAlign.center,
              style: TextStyle(color: yellowColor, fontSize: 11, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ],
        ));
  }

}

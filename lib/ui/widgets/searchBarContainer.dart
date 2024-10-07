import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';

class SearchBarContainer extends StatelessWidget {
  final double? width, height;
  final String? title;
  const SearchBarContainer({Key? key, this.width, this.height, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: height!/16.0, alignment: Alignment.centerLeft,
          decoration:
              DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.surface, 4.0),
          padding: EdgeInsetsDirectional.only(
              start: width! /
                  20.0), 
          child: Text(title!, style: const TextStyle(
                color: lightFont,
                fontSize: 14.0,
              )));
  }
}
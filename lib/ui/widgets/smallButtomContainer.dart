import 'package:project1/ui/styles/design.dart';
import 'package:flutter/material.dart';

class SmallButtonContainer extends StatefulWidget {
  final double? width, height, start, end, top, bottom, radius;
  final String? text;
  final VoidCallback? onTap;
  final Color? color, borderColor, textColor;
  final bool? status;
  const SmallButtonContainer({Key? key, this.width, this.height, this.text, this.onTap, this.color, this. start, this.end, this.top, this.bottom, this.status, this.borderColor, this.textColor, this.radius})
      : super(key: key);

  @override
  State<SmallButtonContainer> createState() => _SmallButtonContainerState();
}

class _SmallButtonContainerState extends State<SmallButtonContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(width: widget.width!/3.6, height: widget.height!/25,
          margin: EdgeInsetsDirectional.only(start: widget.start!, end: widget.end!, top: widget.top!, bottom: widget.bottom!),
          alignment: Alignment.center,
          decoration: DesignConfig.boxDecorationContainerBorder(
              widget.borderColor!, widget.color!, widget.radius!),
          child:  widget.status == true? SizedBox(height: 15, width: 15,
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
          ):Text(widget.text!,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  color: widget.textColor!,
                  fontSize: 12,
                  fontWeight: FontWeight.w500))),
    );
  }
}
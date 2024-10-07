import 'package:flutter/material.dart';

class ButtonImageContainer extends StatefulWidget {
  final double? width, height, start, end, top, bottom;
  final String? text;
  final VoidCallback? onPressed;
  final Color? color, borderColor, textColor;
  final bool? status;
  final Widget? widget;
  const ButtonImageContainer({Key? key, this.width, this.height, this.text, this.onPressed, this.color, this. start, this.end, this.top, this.bottom, this.status, this.borderColor, this.textColor, this.widget})
      : super(key: key);

  @override
  State<ButtonImageContainer> createState() => _ButtonImageContainerState();
}

class _ButtonImageContainerState extends State<ButtonImageContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.start!, end: widget.end!, top: widget.top!, bottom: widget.bottom!),
      child: SizedBox(height: widget.height!/15.0,
        child: TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            backgroundColor: WidgetStateProperty.all(widget.color),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),side: BorderSide(color: widget.borderColor!)
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: widget.status == true? CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface):Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.widget!,
              SizedBox(width: widget.width!/40.0),
              Text(widget.text!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: widget.textColor!,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

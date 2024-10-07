import 'package:flutter/material.dart';

class ButtonContainer extends StatefulWidget {
  final double? width, height, start, end, top, bottom;
  final String? text;
  final VoidCallback? onPressed;
  final Color? color, borderColor, textColor;
  final bool? status;
  const ButtonContainer({Key? key, this.width, this.height, this.text, this.onPressed, this.color, this. start, this.end, this.top, this.bottom, this.status, this.borderColor, this.textColor})
      : super(key: key);

  @override
  State<ButtonContainer> createState() => _ButtonContainerState();
}

class _ButtonContainerState extends State<ButtonContainer> {
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
          child: widget.status == true? CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface):Text(widget.text!,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  color: widget.textColor!,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

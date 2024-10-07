import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductUnavailableDialog extends StatelessWidget {
  final String? startTime, endTime;
  const ProductUnavailableDialog({Key? key, this.startTime, this.endTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime startTimeData = DateFormat("hh:mm:ss").parse(startTime!);
    DateTime endTimeData = DateFormat("hh:mm").parse(endTime!);
    var dateFormat = DateFormat("h:mm a");
    return AlertDialog(
      content: Text("${UiUtils.getTranslatedLabel(context, itmeAvailableBetweenLabel)} ${dateFormat.format(startTimeData)} to ${dateFormat.format(endTimeData)}",
              textAlign: TextAlign.start,
              maxLines: 2,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      actions: [
        TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Text(UiUtils.getTranslatedLabel(context, okLabel), style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12, fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
        )
      ],
    );
  }
}

import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class RestaurantCloseDialog extends StatelessWidget {
  final String? hours, minute;
  final bool? status;
  const RestaurantCloseDialog({Key? key, this.hours, this.minute, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: status == true
          ? Text("${UiUtils.getTranslatedLabel(context, openingInLabel)} ${hours!} ${UiUtils.getTranslatedLabel(context, hoursLabel)} and ${minute!} ${UiUtils.getTranslatedLabel(context, minuteLabel)}",
              textAlign: TextAlign.start,
              maxLines: 2,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500))
          : Text(UiUtils.getTranslatedLabel(context, restaurantCloseLabel),
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

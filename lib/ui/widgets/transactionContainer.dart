import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/data/model/transactionModel.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../utils/apiBodyParameterLabels.dart';

class TransactionContainer extends StatelessWidget {
  final TransactionModel transactionModel;
  final double? width, height;
  final int? index;
  const TransactionContainer({Key? key, required this.transactionModel, this.width, this.height, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 35.0, top: height! / 80.0, end: width! / 35.0, bottom: height! / 80.0),
      width: width!,
      margin: EdgeInsetsDirectional.only(top: index==0?0.0:height! / 52.0, start: width! / 20.0, end: width! / 20.0),
      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: width! / 60.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(UiUtils.getTranslatedLabel(context, idLabel).toUpperCase(),
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600, fontSize: 16.0)),
                  Text(" #${transactionModel.id!}",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.normal, fontSize: 16.0)),
                ],
              ),
              transactionModel.status == ""
                  ? const SizedBox()
                  : Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5),
                          margin: const EdgeInsetsDirectional.only(start: 4.5),
                          width: 55,
                          decoration: DesignConfig.boxDecorationContainerBorder(
                              transactionModel.status!.toLowerCase() == successKey.toLowerCase() ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.error,
                              transactionModel.status!.toLowerCase() == successKey.toLowerCase()
                                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.10)
                                  : Theme.of(context).colorScheme.error.withOpacity(0.10),
                              4.0),
                          child: Text(
                            transactionModel.status!,
                            style: TextStyle(
                                fontSize: 10,
                                color: transactionModel.status!.toLowerCase() == successKey.toLowerCase()
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(top: height! / 80.0, bottom: height! / 80.0),
            child: DesignConfig.divider(),
          ),
          Text("${UiUtils.getTranslatedLabel(context, dateLabel)} : ",
              textAlign: TextAlign.start,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600, fontSize: 14.0)),
          Text(formatter.format(DateTime.parse(transactionModel.transactionDate!)),
              textAlign: TextAlign.start,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.normal, fontSize: 14.0)),
          SizedBox(height: height! / 60.0),
          Text("${UiUtils.getTranslatedLabel(context, typeLabel)} : ",
              textAlign: TextAlign.start,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600, fontSize: 14.0)),
          Text(transactionModel.type!,
              textAlign: TextAlign.start,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.normal, fontSize: 14.0),
              maxLines: 2),
          SizedBox(height: height! / 60.0),
          Text("${UiUtils.getTranslatedLabel(context, messageLabel)} : ",
              textAlign: TextAlign.start,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600, fontSize: 14.0)),
          SizedBox(
              width: width! / 1.1,
              child: Text(transactionModel.message!,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.normal, fontSize: 14.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
          Padding(
            padding: EdgeInsetsDirectional.only(top: height! / 80.0, bottom: height! / 80.0),
            child: DesignConfig.divider(),
          ),
          Row(children: [
            Text("${UiUtils.getTranslatedLabel(context, amountLabel)} : ",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, fontSize: 16.0)),
            const Spacer(),
            Text("${context.read<SystemConfigCubit>().getCurrency()}${double.parse(transactionModel.amount!).toStringAsFixed(2)}",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, fontSize: 16.0)),
          ]),
        ]),
      ),
    );
  }
}

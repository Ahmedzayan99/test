import 'package:project1/cubit/localization/appLocalizationCubit.dart';
import 'package:project1/data/model/appLanguage.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/appLanguages.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageChangeDialog extends StatefulWidget {
  final String title, subtitle, from;
  final double? width, height;
  const LanguageChangeDialog({Key? key, required this.width, required this.height, required this.title, required this.subtitle, required this.from})
      : super(key: key);

  @override
  _LanguageChangeDialogState createState() => _LanguageChangeDialogState();
}

class _LanguageChangeDialogState extends State<LanguageChangeDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: DesignConfig.setRounded(25.0),
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget _buildAppLanguageTile(
      {required AppLanguage appLanguage,
      required BuildContext context,
      required String currentSelectedLanguageCode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          context
              .read<AppLocalizationCubit>()
              .changeLanguage(appLanguage.languageCode);
              Navigator.of(context, rootNavigator: true).pop(true);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 1.75),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appLanguage.languageCode == currentSelectedLanguageCode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              appLanguage.languageName,
              style: TextStyle(
                  fontSize: 14, color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
      ),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.height! / 18.0),
      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(alignment: Alignment.centerLeft, padding: EdgeInsetsDirectional.only(start: widget.width!/20.0, end: widget.width!/20.0), decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSecondary), height: widget.height!/15.0, width: widget.width!, child: Text(
                UiUtils.getTranslatedLabel(context, languageChangeLabel),
                style: const TextStyle(
                    color:  white,
                    fontWeight: FontWeight.w400,
                    fontStyle:  FontStyle.normal,
                    fontSize: 14.0
                ),
                textAlign: TextAlign.left                
                )),
          BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsetsDirectional.only(start: widget.width!/20.0, bottom: widget.height!/80.0, top: widget.height!/80.0),
                child: Column(
                  children: appLanguages
                      .map((appLanguage) => _buildAppLanguageTile(
                          appLanguage: appLanguage,
                          context: context,
                          currentSelectedLanguageCode:
                              state.language.languageCode))
                      .toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

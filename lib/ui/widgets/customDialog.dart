import 'package:project1/app/routes.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/auth/deleteMyAccountCubit.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/widgets/smallButtomContainer.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDialog extends StatefulWidget {
  final String title, subtitle, from;
  final double? width, height;
  const CustomDialog({Key? key, required this.width, required this.height, required this.title, required this.subtitle, required this.from})
      : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: DesignConfig.setRounded(25.0),
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.height! / 18.0),
      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(alignment: Alignment.centerLeft, padding: EdgeInsetsDirectional.only(start: widget.width!/20.0), decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSecondary), height: widget.height!/15.0, width: widget.width!, child: Text(
                widget.from==UiUtils.getTranslatedLabel(context, deleteLabel)?UiUtils.getTranslatedLabel(context, deleteAccountLabel):UiUtils.getTranslatedLabel(context, logoutLabel),
                style: const TextStyle(
                    color:  white,
                    fontWeight: FontWeight.w400,
                    fontStyle:  FontStyle.normal,
                    fontSize: 14.0
                ),
                textAlign: TextAlign.left                
                )),
          Padding(
          padding: EdgeInsetsDirectional.only(start: widget.width! / 40.0, top: widget.height! / 40.0, end: widget.width! / 40.0),
            child: Text(widget.subtitle,
                textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal,)),
          ),
          SizedBox(
            height: widget.height!/40.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SmallButtonContainer(color: Theme.of(context).colorScheme.onSurface, height: widget.height, width: widget.width, text: UiUtils.getTranslatedLabel(context, cancelLabel), start: 0, end: 0, bottom: widget.height!/60.0, top: widget.height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.onSurface, textColor: Theme.of(context).colorScheme.onSecondary, onTap: (){
                        Navigator.of(context, rootNavigator: true).pop(true);
              },),
              widget.from ==UiUtils.getTranslatedLabel(context, logoutLabel)
                  ? SmallButtonContainer(color: Theme.of(context).colorScheme.primary, height: widget.height, width: widget.width, text: UiUtils.getTranslatedLabel(context, logoutLabel), start: 0, end: widget.width!/20.0, bottom: widget.height!/60.0, top: widget.height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.primary, textColor: white, onTap: (){
                    clearOffLineCart(context);
                        Navigator.of(context, rootNavigator: true).pop(true);
                        if(context.read<AuthCubit>().getType()=="google"){
                          context.read<AuthCubit>().signOut(AuthProviders.google);
                        }else if(context.read<AuthCubit>().getType()=="facebook"){
                          context.read<AuthCubit>().signOut(AuthProviders.facebook);
                        }else{
                          context.read<AuthCubit>().signOut(AuthProviders.apple);
                        }
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(Routes.login, (Route<dynamic> route) => false, arguments: {'from': 'logout'});
              },) : BlocConsumer<DeleteMyAccountCubit, DeleteMyAccountState>(
                      bloc: context.read<DeleteMyAccountCubit>(),
                      listener: (context, state) {
                        if (state is DeleteMyAccountFailure) {
                          if(state.errorStatusCode.toString() == "102"){
                            reLogin(context);
                          }
                        }
                        if (state is DeleteMyAccountFailure) {
                          Center(
                              child: SizedBox(
                            width: widget.width! / 2,
                            child: Text(state.errorMessage.toString(),
                                textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                          ));
                        }
                        if (state is DeleteMyAccountSuccess) {
                          clearOffLineCart(context);
                          Navigator.of(context, rootNavigator: true).pop(true);
                          if(context.read<AuthCubit>().getType()=="google"){
                            context.read<AuthCubit>().signOut(AuthProviders.google);
                          }else if(context.read<AuthCubit>().getType()=="facebook"){
                            context.read<AuthCubit>().signOut(AuthProviders.facebook);
                          }else{
                            context.read<AuthCubit>().signOut(AuthProviders.apple);
                          }
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil(Routes.login, (Route<dynamic> route) => false, arguments: {'from': 'delete'});
                        }
                      },
                      builder: (context, state) {
                        return SmallButtonContainer(color: Theme.of(context).colorScheme.error, height: widget.height, width: widget.width, text: UiUtils.getTranslatedLabel(context, deleteLabel), start: 0, end: widget.width!/20.0, bottom: widget.height!/60.0, top: widget.height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.error, textColor: white, onTap: (){
                          User? currentUser =
                          FirebaseAuth.instance.currentUser;
                          print("currentUser is:$currentUser");
                          if (currentUser != null) {
                            currentUser.delete().then((value) async {
                              context.read<DeleteMyAccountCubit>().deleteMyAccount(userId: context.read<AuthCubit>().getId());
                          }).catchError((error) {
                                  Navigator.of(context, rootNavigator: true).pop(true);
                                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, loginLabel), StringsRes.messageReLogin, context, false,
                                      type: "2");
                                });
                          }else {
                            Navigator.of(context, rootNavigator: true).pop(true);
                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, loginLabel), StringsRes.messageReLogin, context, false, type: "2");
                          }
                      });})],
          ),
        ],
      ),
    );
  }
}

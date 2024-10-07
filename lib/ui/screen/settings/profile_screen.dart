import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/profileManagement/updateUserDetailsCubit.dart';
import 'package:project1/cubit/profileManagement/uploadProfileCubit.dart';
import 'package:project1/data/repositories/profileManagement/profileManagementRepository.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:project1/utils/internetConnectivity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<UploadProfileCubit>(
            create: (context) => UploadProfileCubit(
                  ProfileManagementRepository(),
                )),
        BlocProvider<UpdateUserDetailCubit>(create: (_) => UpdateUserDetailCubit(ProfileManagementRepository())),
      ], child: const ProfileScreen()),
    );
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  double? width, height;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController referralCodeController = TextEditingController(text: "");
  //TextEditingController addressController = TextEditingController(text: "");
  String? countryCode = defaulCountryCode;
  bool status = false;
  final formKey = GlobalKey<FormState>();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  File? image;
  // get image File camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(sourcePath: pickedFile!.path,/* aspectRatio: [
      CropAspectRatio(ratioX:3, ratioY: 2),
      CropAspectRatio(ratioX: 4, ratioY: 3),
      CropAspectRatio(ratioX: 16, ratioY:9),
    ]*/uiSettings: [
      AndroidUiSettings(
          statusBarColor: Colors.black, toolbarWidgetColor: Colors.black, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
      IOSUiSettings(),
    ]);
    File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    image = rotatedImage;
    final userId = context.read<AuthCubit>().getId();
    context.read<UploadProfileCubit>().uploadProfilePicture(image, userId);
  }

//get image file from library
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(sourcePath: pickedFile!.path, /*aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],*/ uiSettings: [
      AndroidUiSettings(
          statusBarColor: Colors.black, toolbarWidgetColor: Colors.black, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
      IOSUiSettings(),
    ]);
    File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    image = rotatedImage;
    //File(pickedFile.path);
    final userId = context.read<AuthCubit>().getId();

    context.read<UploadProfileCubit>().uploadProfilePicture(image, userId);
  }

  Future chooseProfile(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: DesignConfig.setRounded(25.0),
            //title: Text('Not in stock'),
            content: SizedBox(
              height: height! / 5.5,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    icon: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    label: Text(
                      UiUtils.getTranslatedLabel(context, galleryLabel),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _getFromGallery();
                      Navigator.of(context).pop();
                    }),
                TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  icon: Icon(
                    Icons.photo_camera,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  label: Text(
                    UiUtils.getTranslatedLabel(context, cameraLabel),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _getFromCamera();
                    Navigator.of(context).pop();
                  },
                )
              ]),
            ));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    //print("profile${context.read<AuthCubit>().getMobile()}");
    nameController = TextEditingController(text: context.read<AuthCubit>().getName());
    emailController = TextEditingController(text: context.read<AuthCubit>().getEmail());
    phoneNumberController = TextEditingController(text: context.read<AuthCubit>().getMobile());
    referralCodeController = TextEditingController(text: context.read<AuthCubit>().getReferralCode());
    //addressController = TextEditingController(text: context.read<AuthCubit>().getAddress());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    referralCodeController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget nameField(){
  return Container(
    padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
    margin: EdgeInsets.zero,
    child: TextFormField(
      controller: nameController,
      cursorColor: lightFont,
        decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, fullNameLabel), UiUtils.getTranslatedLabel(context, enterNameLabel), width!, context),
        keyboardType: TextInputType.text,
        style: const TextStyle(
        color: greayLightColor,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        ),
      )
    );  
  }

  Widget referralCodeField() {
    return Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: TextFormField(enabled: false,
            controller: referralCodeController,
            decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, referralCodeLabel), UiUtils.getTranslatedLabel(context, enterReferralCodeLabel), width!, context),
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: greayLightColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )
        )
      );
  }

  Widget phoneNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
            validator: (value) {
              if(value!.isEmpty){
                setState(() {
                  status = false;
                });
                return UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel);
              }
              return null;
            },
            controller: phoneNumberController,
            enabled: (context.read<AuthCubit>().getType()=="google")||(context.read<AuthCubit>().getType()=="facebook")?true:false,
            decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, phoneNumberLabel), UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel), width!, context),
            keyboardType: TextInputType.number,inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: greayLightColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )));
  }

  Widget emailField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(validator: (value){return UiUtils.validateEmail(value!, StringsRes.enterEmail, UiUtils.getTranslatedLabel(context, enterValidEmailLabel));},
          controller: emailController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, emailIdLabel), StringsRes.enterEmail, width!, context),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: greayLightColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
              appBar: DesignConfig.appBar(context, width, UiUtils.getTranslatedLabel(context, profileLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              bottomNavigationBar: BlocConsumer<UpdateUserDetailCubit, UpdateUserDetailState>(
                  bloc: context.read<UpdateUserDetailCubit>(),
                  listener: (context, state) {
                    if (state is UpdateUserDetailFailure) {
                      if(state.errorStatusCode.toString() == "102"){
                        reLogin(context);
                      }
                      status = false;
                    }
                    if (state is UpdateUserDetailSuccess) {
                      context.read<AuthCubit>().updateUserName(state.authModel.username ?? "");
                      context.read<AuthCubit>().updateUserEmail(state.authModel.email ?? "");
                      context.read<AuthCubit>().updateUserMobile(state.authModel.mobile ?? "");
                      context.read<AuthCubit>().updateUserReferralCode(state.authModel.referralCode ?? "");
                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, profileLabel), StringsRes.updateSuccessFully, context, false, type: "1");
                      status = false;
                      // Navigator.pop(context);
                    } else if (state is UpdateUserDetailFailure) {
                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, profileLabel), state.errorMessage, context, false, type: "2");
                      status = false;
                    }
                  },
                  builder: (context, state) {
                    return ButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, saveProfileLabel), start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0, top: 0, status: status, borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onPressed: (){
                      setState(() {
                        status = true;
                      });
                      if (formKey.currentState!.validate()) {
                      context.read<UpdateUserDetailCubit>().updateProfile(
                              userId: context.read<AuthCubit>().getId(),
                              name: nameController.text,
                              email: emailController.text,
                              mobile: phoneNumberController.text,
                              referralCode: referralCodeController.text);
                              }
                    },);
                  }),
              body: Form(key: formKey,
                child: BlocConsumer<UploadProfileCubit, UploadProfileState>(listener: (context, state) {
                  if (state is UploadProfileFailure) {
                    UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, profileLabel), state.errorMessage, context, false, type: "2");
                    if(state.errorStatusCode.toString() == "102"){
                      reLogin(context);
                    }
                  } else if (state is UploadProfileSuccess) {
                    context.read<AuthCubit>().updateUserProfileUrl(state.imageUrl);
                  }
                }, builder: (context, state) {
                  return Container(height: height,
                      margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                      decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                      width: width,
                      child: Container(
                        margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 20.0),
                        child: SingleChildScrollView(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 10.0, end: width! / 10.0, bottom: height! / 25.0),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Center(
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.50),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: ClipOval(
                                            child: DesignConfig.imageWidgets(context.read<AuthCubit>().getProfile(), 85, 85,"2")),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(top: height! / 15.0, start: width! / 5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        chooseProfile(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          child: Container(
                                              alignment: Alignment.center,
                                              child: SvgPicture.asset(
                                                DesignConfig.setSvgPath("change_acc_pic_icon"),
                                                width: 20,
                                                height: 20,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            nameField(),
                            emailField(),
                            phoneNumberField(),
                            referralCodeField()
                          ]),
                        ),
                      ));
                }),
              ),
            ),
    );
  }
}

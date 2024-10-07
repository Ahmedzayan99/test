import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/data/model/addressModel.dart';
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/cubit/address/addressCubit.dart';
import 'package:project1/cubit/address/deleteAddressCubit.dart';
import 'package:project1/cubit/address/updateAddressCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/simmer/addressSimmer.dart';
import 'package:project1/ui/widgets/buttomContainer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/ui/widgets/smallButtomContainer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
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
import 'package:flutter_svg/svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({Key? key}) : super(key: key);

  @override
  DeliveryAddressScreenState createState() => DeliveryAddressScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<UpdateAddressCubit>(create: (_) => UpdateAddressCubit(AddressRepository())),
      ], child: const DeliveryAddressScreen()),
    );
  }
}

class DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> refreshList() async {
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
  }

  Widget noAddressData() {
    return NoDataContainer(
        image: "address",
        title: UiUtils.getTranslatedLabel(context, noAddressYetLabel),
        subTitle:
            UiUtils.getTranslatedLabel(context, noAddressYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget addressData() {
    return BlocConsumer<AddressCubit, AddressState>(
        bloc: context.read<AddressCubit>(),
        listener: (context, state) {
          if (state is AddressFailure) {
            if(state.errorStatusCode.toString() == "102"){
              reLogin(context);
            }
          }
        },
        builder: (context, state) {
          if (state is AddressProgress || state is AddressInitial) {
            return AddressSimmer(width: width!, height: height!);
          }
          if (state is AddressFailure) {
            print("AddressFailure${state.errorMessage}-${state.errorStatusCode}");
            //return Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center,));
            if(state.errorStatusCode.toString() == "102"){
              reLogin(context);
            }
            return noAddressData();
          }
          final addressList = (state as AddressSuccess).addressList;
          return addressList.isEmpty
                    ? noAddressData():ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: addressList.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, index) {
                return BlocProvider(
                        create: (context) => DeleteAddressCubit(AddressRepository()),
                        child: Builder(builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {});
                            },
                            child: Container(
                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
                              //decoration: address == StringsRes.home ? DesignConfig.boxDecorationContainerBorder(red, redLight, 15) : DesignConfig.boxDecorationContainerBorder(white, white, 15),
                              margin: EdgeInsetsDirectional.only(bottom: height! / 50.0, start: width!/ 20.0, end: width!/20.0),
                              padding: EdgeInsetsDirectional.only(top: height! / 40.0, bottom: height! / 40.0, start: width!/ 20.0, end: width!/40.0),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Row(
                                  children: [
                                    addressList[index].type == homeKey
                                        ? SvgPicture.asset(
                                            DesignConfig.setSvgPath("home_address"),fit: BoxFit.scaleDown, height: 20, width: 20,
                                          )
                                        : addressList[index].type == officeKey
                                            ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"),fit: BoxFit.scaleDown, height: 20, width: 20,)
                                            : SvgPicture.asset(DesignConfig.setSvgPath("other_address"),fit: BoxFit.scaleDown, height: 20, width: 20,),
                                    SizedBox(width: height! / 99.0),
                                    Text(
                                      addressList[index].type!/*  == homeKey
                                          ? StringsRes.home
                                          : addressList[index].type == officeKey
                                              ? StringsRes.office
                                              : StringsRes.other */,
                                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                                SizedBox(width: height! / 99.0),
                                Row(
                                  children: [
                                    SizedBox(width: width! / 11.0),
                                    Expanded(
                                      child: Text(
                                        "${addressList[index].address!}, ${addressList[index].area!}, ${addressList[index].city}, ${addressList[index].state!}, ${addressList[index].pincode!}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SmallButtonContainer(color: Theme.of(context).colorScheme.onSurface, height: height, width: width, text: UiUtils.getTranslatedLabel(context, editLabel), start: width! / 11.0, end: width! / 40.0, bottom: 0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: Theme.of(context).colorScheme.onSecondary, onTap: (){
                                                      Navigator.pushNamed(context, Routes.address, arguments: {
                                            'addressModel': addressList[index],
                                            'from': 'updateAddress',
                                          });
                },),
                                    BlocConsumer<DeleteAddressCubit, DeleteAddressState>(
                                        bloc: context.read<DeleteAddressCubit>(),
                                        listener: (context, state) {
                                          if (state is DeleteAddressSuccess) {
                                            context.read<AddressCubit>().deleteAddress(state.id);
                                            UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addressLabel), StringsRes.deleteSuccessFully, context, false, type: "1");
                                          }
                                        },
                                        builder: (context, state) {
                                          return SmallButtonContainer(color: Theme.of(context).colorScheme.secondary, height: height, width: width, text: UiUtils.getTranslatedLabel(context, deleteLabel), start: width! / 99.0, end: width! / 40.0, bottom: 0, top: height!/99.0, radius: 5.0, status: false,borderColor: Theme.of(context).colorScheme.secondary, textColor: white, onTap: (){
                                            if (addressList.length > 1) {
                                                  context.read<DeleteAddressCubit>().fetchDeleteAddress(addressList[index].id!);
                                                } else if (addressList[index].isDefault == "1") {
                                                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addressLabel), StringsRes.addressChange, context, false, type: "2");
                                                } else {
                                                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, addressLabel), StringsRes.addressOne, context, false, type: "2");
                                                }
                },);
                                        })
                                  ],
                                ),
                                /* Divider(
                                  color: lightFont.withOpacity(0.50),
                                  height: 1.0,
                                ), */
                              ]),
                            ),
                          );
                        }),
                      );
              });
        });
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
                appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, deliveryAddressLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
                bottomNavigationBar: ButtonContainer(
                  color: Theme.of(context).colorScheme.secondary,
                  height: height,
                  width: width,
                  text: UiUtils.getTranslatedLabel(context, addNewAddressLabel),
                  start: width! / 40.0,
                  end: width! / 40.0,
                  bottom: height! / 55.0,
                  top: 0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.secondary,
                  textColor: white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.address, arguments: {
                      'addressModel': AddressModel(),
                      'from': 'addAddress',
                    });
                    },),
                body: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0/* , start: width!/ 40.0, end: width!/40.0 */)/* , padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0) */, height: height!,
                  width: width,
                  child: RefreshIndicator(
                      onRefresh: refreshList,
                      color: Theme.of(context).colorScheme.primary,
                      child: addressData(),
                    ),
                ),
              ));
  }
}

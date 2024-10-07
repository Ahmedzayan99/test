import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/data/model/addressModel.dart';
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/cubit/address/addressCubit.dart';
import 'package:project1/cubit/address/updateAddressCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/ui/widgets/simmer/addressSimmer.dart';
import 'package:project1/ui/widgets/noDataContainer.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:project1/utils/internetConnectivity.dart';

class SelectDeliveryLocationScreen extends StatefulWidget {
  final String? from;
  const SelectDeliveryLocationScreen({Key? key, this.from}) : super(key: key);

  @override
  SelectDeliveryLocationScreenState createState() => SelectDeliveryLocationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        // BlocProvider<AddressCubit>(create: (context) => AddressCubit(AddressRepository(),)),
        BlocProvider<UpdateAddressCubit>(create: (_) => UpdateAddressCubit(AddressRepository())),
      ], child: const SelectDeliveryLocationScreen()),
    );
  }
}

class SelectDeliveryLocationScreenState extends State<SelectDeliveryLocationScreen> {
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

  Widget addressData() {
    return BlocConsumer<AddressCubit, AddressState>(
        bloc: context.read<AddressCubit>(),
        listener: (context, state) {
          if (state is AddressSuccess) {
            // context.read<AddressCubit>().addAddress();
          }
        },
        builder: (context, state) {
          if (state is AddressProgress || state is AddressInitial) {
            return AddressSimmer(width: width!, height: height!);
          }
          if (state is AddressFailure) {
            return /*Center(
                child: Text(
              state.errorCode.toString(),
              textAlign: TextAlign.center,
            ))*/
                NoDataContainer(
                    image: "address", title: UiUtils.getTranslatedLabel(context, noAddressYetLabel), subTitle: UiUtils.getTranslatedLabel(context, noAddressYetSubTitleLabel), width: width!, height: height!);
          }
          final addressList = (state as AddressSuccess).addressList;
          return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: addressList.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, index) {
                return addressList.isNotEmpty
                    ? BlocProvider<UpdateAddressCubit>(
                        create: (_) => UpdateAddressCubit(AddressRepository()),
                        child: Builder(builder: (context) {
                          return BlocConsumer<UpdateAddressCubit, UpdateAddressState>(
                              bloc: context.read<UpdateAddressCubit>(),
                              listener: (context, state) {
                                //print(state.toString());
                                if (state is UpdateAddressSuccess) {
                                  context.read<AddressCubit>().updateAddress(state.addressModel);

                                  Navigator.pop(context);
                                  // Navigator.pop(context);
                                } else if (state is UpdateAddressFailure) {
                                  if(state.errorStatusCode.toString() == "Token Expired"){
                                    reLogin(context);
                                  }
                                  print(state.errorMessage.toString());
                                }
                              },
                              builder: (context, state) {
                                return GestureDetector(
                                  onTap: () {
                                    context.read<UpdateAddressCubit>().fetchUpdateAddress(
                                        addressList[index].id,
                                        addressList[index].userId,
                                        addressList[index].mobile,
                                        addressList[index].address,
                                        addressList[index].city,
                                        addressList[index].latitude,
                                        addressList[index].longitude,
                                        addressList[index].area,
                                        addressList[index].type,
                                        addressList[index].name,
                                        addressList[index].countryCode,
                                        addressList[index].alternateCountryCode,
                                        addressList[index].alternateMobile,
                                        addressList[index].landmark,
                                        addressList[index].pincode,
                                        addressList[index].state,
                                        addressList[index].country,
                                        "1");
                                  },
                                  child: Container(
                                    decoration: addressList[index].isDefault == "1"
                                        ? DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.10), 15)
                                        : DesignConfig.boxDecorationContainerBorder(Theme.of(context).colorScheme.onSurface, Theme.of(context).colorScheme.onSurface, 15),
                                    margin: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                    padding: EdgeInsets.symmetric(vertical: height! / 40.0, horizontal: height! / 40.0),
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      Row(
                                        children: [
                                          addressList[index].type == homeKey
                                              ? SvgPicture.asset(
                                                  DesignConfig.setSvgPath("home_address"),
                                                )
                                              : addressList[index].type == officeKey
                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                                                  : SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
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
                                              "${addressList[index].address!},${addressList[index].area!},${addressList[index].city},${addressList[index].state!},${addressList[index].pincode!}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                  ),
                                );
                              });
                        }),
                      )
                    : NoDataContainer(
                        image: "address", title: UiUtils.getTranslatedLabel(context, noAddressYetLabel), subTitle: UiUtils.getTranslatedLabel(context, noAddressYetSubTitleLabel), width: width!, height: height!);
              });
        });
  }

  Future<void> refreshList() async {
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
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
              appBar: AppBar(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                        padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                        child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32,fit: BoxFit.scaleDown,))),
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                shadowColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                centerTitle: true,
                title: Text(UiUtils.getTranslatedLabel(context, selectDeliveryLocationLabel),
                    textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              bottomNavigationBar: TextButton(
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    if (widget.from != null) {
                      Navigator.of(context).pushNamed(Routes.address, arguments: {'from': widget.from!, 'addressModel': AddressModel(),});
                    } else {
                      Navigator.of(context).pushNamed(Routes.address, arguments: {'from': "", 'addressModel': AddressModel(),});
                    }
                  },
                  child: Container(
                      margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, bottom: height! / 55.0),
                      width: width,
                      padding: EdgeInsetsDirectional.only(top: height! / 55.0, bottom: height! / 55.0, start: width! / 20.0, end: width! / 20.0),
                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 10.0),
                      child: Text(UiUtils.getTranslatedLabel(context, addAddressLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500)))),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: Container(
                    margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 40.0),
                    child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: addressData())),
              )),
    );
  }
}

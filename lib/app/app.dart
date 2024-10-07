import 'dart:io';
import 'package:project1/app/appLocalization.dart';
import 'package:project1/cubit/address/isOrderDeliverableCubit.dart';
import 'package:project1/cubit/auth/resendOtpCubit.dart';
import 'package:project1/cubit/auth/socialSignUpCubit.dart';
import 'package:project1/cubit/auth/verifyOtpCubit.dart';
import 'package:project1/cubit/auth/verifyUserCubit.dart';
import 'package:project1/cubit/helpAndSupport/ticketCubit.dart';
import 'package:project1/cubit/home/cuisine/restaurantCuisineCubit.dart';
import 'package:project1/cubit/home/sections/sectionsDetailCubit.dart';
import 'package:project1/cubit/localization/appLocalizationCubit.dart';
import 'package:project1/cubit/notificatiion/notificationCubit.dart';
import 'package:project1/cubit/order/activeOrderCubit.dart';
import 'package:project1/cubit/order/orderDetailCubit.dart';
import 'package:project1/cubit/order/reOrderCubit.dart';
import 'package:project1/cubit/product/ProductViewAllCubit.dart';
import 'package:project1/cubit/product/productLoadCubit.dart';
import 'package:project1/cubit/product/restaurantCategoryCubit.dart';
import 'package:project1/data/repositories/address/addressRepository.dart';
import 'package:project1/cubit/address/addAddressCubit.dart';
import 'package:project1/cubit/address/addressCubit.dart';
import 'package:project1/cubit/address/cityDeliverableCubit.dart';
import 'package:project1/cubit/address/deliveryChargeCubit.dart';
import 'package:project1/cubit/address/updateAddressCubit.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/cubit/auth/deleteMyAccountCubit.dart';
import 'package:project1/cubit/auth/referAndEarnCubit.dart';
import 'package:project1/cubit/auth/signInCubit.dart';
import 'package:project1/cubit/auth/signUpCubit.dart';
import 'package:project1/cubit/bottomNavigationBar/navicationBarCubit.dart';
import 'package:project1/data/repositories/cart/cartRepository.dart';
import 'package:project1/cubit/cart/clearCartCubit.dart';
import 'package:project1/cubit/cart/getCartCubit.dart';
import 'package:project1/cubit/cart/manageCartCubit.dart';
import 'package:project1/cubit/cart/placeOrder.dart';
import 'package:project1/cubit/cart/removeFromCartCubit.dart';
import 'package:project1/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project1/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project1/cubit/favourite/updateFavouriteRestaurant.dart';
import 'package:project1/cubit/favourite/updateFavouriteProduct.dart';
import 'package:project1/data/repositories/home/bestOffer/bestOfferRepository.dart';
import 'package:project1/cubit/home/bestOffer/bestOfferCubit.dart';
import 'package:project1/cubit/home/cuisine/cuisineCubit.dart';
import 'package:project1/cubit/home/restaurants/restaurantCubit.dart';
import 'package:project1/cubit/home/restaurants/topRestaurantCubit.dart';
import 'package:project1/cubit/home/search/searchCubit.dart';
import 'package:project1/cubit/home/sections/sectionsCubit.dart';
import 'package:project1/cubit/home/slider/sliderOfferCubit.dart';
import 'package:project1/data/repositories/home/slider/sliderRepository.dart';
import 'package:project1/cubit/order/orderCubit.dart';
import 'package:project1/cubit/order/updateOrderStatusCubit.dart';
import 'package:project1/cubit/order/orderLiveTrackingCubit.dart';
import 'package:project1/data/repositories/order/orderRepository.dart';
import 'package:project1/cubit/payment/GetWithdrawRequestCubit.dart';
import 'package:project1/cubit/payment/sendWithdrawRequestCubit.dart';
import 'package:project1/cubit/product/manageOfflineCartCubit.dart';
import 'package:project1/cubit/product/offlineCartCubit.dart';
import 'package:project1/cubit/product/productCubit.dart';
import 'package:project1/data/repositories/payment/paymentRepository.dart';
import 'package:project1/data/repositories/product/productRepository.dart';
import 'package:project1/cubit/promoCode/promoCodeCubit.dart';
import 'package:project1/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:project1/data/repositories/promoCode/promoCodeRepository.dart';
import 'package:project1/cubit/rating/setRiderRatingCubit.dart';
import 'package:project1/data/repositories/rating/ratingRepository.dart';
import 'package:project1/cubit/settings/settingsCubit.dart';
import 'package:project1/data/repositories/settings/settingsRepository.dart';
import 'package:project1/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project1/data/repositories/systemConfig/systemConfigRepository.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/utils/appLanguages.dart';
import 'package:project1/utils/hiveBoxKey.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/data/repositories/auth/authRepository.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<Widget> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark));
    initializedDownload();
    print('ahmed');
    await Firebase.initializeApp(
        options: FirebaseOptions(
            projectId: "AIzaSyD_l5KaoHuYHgFPw16eZNzAZsQQn-c78Qo",
            appId: 'learn-flutter-1747a',
            messagingSenderId: '1:329219398078:android:29aa8d8ae17557919ac1ef',
            apiKey: '1:329219398078:android:29aa8d8ae17557919ac1ef'));

    if (defaultTargetPlatform == TargetPlatform.android) {}
  }

  await Hive.initFlutter();
  await Hive.openBox(
      authBox); //auth box for storing all authentication related details
  await Hive.openBox(
      settingsBox); //settings box for storing all settings details
  await Hive.openBox(
      userdetailsBox); //userDetails box for storing all userDetails details
  await Hive.openBox(addressBox); //address box for storing all address details
  await Hive.openBox(
      searchAddressBox); //searchAddress box for storing all searchAddress details

  return const MyApp();
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //providing global providers
      providers: [
        //Creating cubit/bloc that will be use in whole app or
        //will be use in multiple screens
        BlocProvider<AppLocalizationCubit>(
            create: (_) => AppLocalizationCubit(SettingsRepository())),
        BlocProvider<NavigationBarCubit>(create: (_) => NavigationBarCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<SignUpCubit>(create: (_) => SignUpCubit(AuthRepository())),
        BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository())),
        BlocProvider<SignInCubit>(create: (_) => SignInCubit(AuthRepository())),
        BlocProvider<SocialSignUpCubit>(
            create: (_) => SocialSignUpCubit(AuthRepository())),
        BlocProvider<RestaurantCubit>(create: (_) => RestaurantCubit()),
        BlocProvider<TopRestaurantCubit>(create: (_) => TopRestaurantCubit()),
        BlocProvider<CuisineCubit>(create: (_) => CuisineCubit()),
        BlocProvider<RestaurantCuisineCubit>(
            create: (_) => RestaurantCuisineCubit()),
        BlocProvider<BestOfferCubit>(
            create: (_) => BestOfferCubit(BestOfferRepository())),
        BlocProvider<SliderCubit>(
            create: (_) => SliderCubit(SliderRepository())),
        BlocProvider<SectionsCubit>(create: (_) => SectionsCubit()),
        BlocProvider<SectionsDetailCubit>(create: (_) => SectionsDetailCubit()),
        BlocProvider<AddressCubit>(
            create: (_) => AddressCubit(AddressRepository())),
        BlocProvider<AddAddressCubit>(
            create: (_) => AddAddressCubit(AddressRepository())),
        BlocProvider<CityDeliverableCubit>(
            create: (_) => CityDeliverableCubit(AddressRepository())),
        BlocProvider<IsOrderDeliverableCubit>(
            create: (_) => IsOrderDeliverableCubit(AddressRepository())),
        BlocProvider<PromoCodeCubit>(create: (_) => PromoCodeCubit()),
        BlocProvider<ValidatePromoCodeCubit>(
            create: (_) => ValidatePromoCodeCubit(PromoCodeRepository())),
        BlocProvider<GetCartCubit>(
            create: (_) => GetCartCubit(CartRepository())),
        BlocProvider<ProductCubit>(
            create: (_) => ProductCubit(ProductRepository())),
        BlocProvider<ProductViewAllCubit>(create: (_) => ProductViewAllCubit()),
        BlocProvider<ManageCartCubit>(
            create: (_) => ManageCartCubit(CartRepository())),
        BlocProvider<RemoveFromCartCubit>(
            create: (_) => RemoveFromCartCubit(CartRepository())),
        BlocProvider<OrderCubit>(create: (_) => OrderCubit()),
        BlocProvider<PlaceOrderCubit>(
            create: (_) => PlaceOrderCubit(CartRepository())),
        BlocProvider<SearchCubit>(create: (_) => SearchCubit()),
        BlocProvider<SystemConfigCubit>(
            create: (_) => SystemConfigCubit(SystemConfigRepository())),
        BlocProvider<UpdateOrderStatusCubit>(
            create: (_) => UpdateOrderStatusCubit(OrderRepository())),
        BlocProvider<OrderLiveTrackingCubit>(
            create: (_) => OrderLiveTrackingCubit(OrderRepository())),
        BlocProvider<UpdateAddressCubit>(
            create: (_) => UpdateAddressCubit(AddressRepository())),
        BlocProvider<DeliveryChargeCubit>(
            create: (_) => DeliveryChargeCubit(AddressRepository())),
        BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(SettingsRepository())),
        BlocProvider<SetRiderRatingCubit>(
            create: (_) => SetRiderRatingCubit(RatingRepository())),
        BlocProvider<FavoriteRestaurantsCubit>(
            create: (_) => FavoriteRestaurantsCubit()),
        BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
            create: (_) => UpdateRestaurantFavoriteStatusCubit()),
        BlocProvider<FavoriteProductsCubit>(
            create: (_) => FavoriteProductsCubit()),
        BlocProvider<UpdateProductFavoriteStatusCubit>(
            create: (_) => UpdateProductFavoriteStatusCubit()),
        BlocProvider<DeleteMyAccountCubit>(
            create: (_) => DeleteMyAccountCubit(AuthRepository())),
        BlocProvider<ClearCartCubit>(
            create: (_) => ClearCartCubit(CartRepository())),
        BlocProvider<OfflineCartCubit>(
            create: (_) => OfflineCartCubit(ProductRepository())),
        BlocProvider<ManageOfflineCartCubit>(
            create: (_) => ManageOfflineCartCubit(ProductRepository())),
        BlocProvider<SendWithdrawRequestCubit>(
            create: (_) => SendWithdrawRequestCubit(PaymentRepository())),
        BlocProvider<GetWithdrawRequestCubit>(
            create: (_) => GetWithdrawRequestCubit()),
        BlocProvider<TicketCubit>(create: (_) => TicketCubit()),
        BlocProvider<RestaurantCategoryCubit>(
            create: (_) => RestaurantCategoryCubit()),
        BlocProvider<ProductLoadCubit>(create: (_) => ProductLoadCubit()),
        BlocProvider<NotificationCubit>(
          create: (_) => NotificationCubit(),
        ),
        BlocProvider<ActiveOrderCubit>(create: (_) => ActiveOrderCubit()),
        BlocProvider<ReOrderCubit>(
            create: (_) => ReOrderCubit(OrderRepository())),
        BlocProvider<VerifyUserCubit>(
            create: (_) => VerifyUserCubit(AuthRepository())),
        BlocProvider<VerifyOtpCubit>(
            create: (_) => VerifyOtpCubit(AuthRepository())),
        BlocProvider<ResendOtpCubit>(
            create: (_) => ResendOtpCubit(AuthRepository())),
        BlocProvider<OrderDetailCubit>(create: (_) => OrderDetailCubit()),
      ],
      child: Builder(
        builder: (context) {
          final currentLanguage =
              context.watch<AppLocalizationCubit>().state.language;
          return MaterialApp(
            navigatorKey: navigatorKey,
            builder: (context, widget) {
              return ScrollConfiguration(
                  behavior: GlobalScrollBehavior(), child: widget!);
            },
            theme: ThemeData(
                scaffoldBackgroundColor: backgroundColor,
                useMaterial3: false,
                fontFamily: 'Quicksand',
                iconTheme: const IconThemeData(
                  color: black,
                ),
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: primaryColor,
                      secondary: secondaryColor,
                      surface: backgroundColor,
                      error: errorColor,
                      onPrimary: onPrimaryColor,
                      onSecondary: onSecondaryColor,
                      onSurface: onBackgroundColor,
                    )),
            locale: currentLanguage,
              localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appLanguages.map((appLanguage) {
            return UiUtils.getLocaleFromLanguageCode(appLanguage.languageCode);
          }).toList(),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

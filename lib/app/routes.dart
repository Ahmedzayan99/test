import 'package:project1/ui/screen/address/address_screen.dart';
import 'package:project1/ui/screen/address/search_location_screen.dart';
import 'package:project1/ui/screen/home/cuisine/cuisine_detail_Screen.dart';
import 'package:project1/ui/screen/home/cuisine/cuisine_screen.dart';
import 'package:project1/ui/screen/address/delivery_address_screen.dart';
import 'package:project1/ui/screen/home/home_screen.dart';
import 'package:project1/ui/screen/home/restaurants/restaurant_detail_screen.dart';
import 'package:project1/ui/screen/home/section/section_screen.dart';
import 'package:project1/ui/screen/order/order_tracking_detail_screen.dart';
import 'package:project1/ui/screen/rating/restaurant_rating_detail_Screen.dart';
import 'package:project1/ui/screen/rating/product_rating_detail_Screen.dart';
import 'package:project1/ui/screen/rating/rider_rating_detail_Screen.dart';
import 'package:project1/ui/screen/search/filter_detail_Screen.dart';
import 'package:project1/ui/screen/order/order_tracking_screen.dart';
import 'package:project1/ui/screen/payment/payment_screen.dart';
import 'package:project1/ui/screen/rating/product_rating_screen.dart';
import 'package:project1/ui/screen/rating/rider_rating_screen.dart';
import 'package:project1/ui/screen/faq/faq_Screen.dart';
import 'package:project1/ui/screen/search/filter_screen.dart';
import 'package:project1/ui/screen/search/product_search_screen.dart';
import 'package:project1/ui/screen/settings/account_screen.dart';
import 'package:project1/ui/screen/ticket/add_ticket_screen.dart';
import 'package:project1/ui/screen/ticket/edit_ticket_screen.dart';
import 'package:project1/ui/screen/order/my_order_screen.dart';
import 'package:project1/ui/screen/order/order_detail_screen.dart';
import 'package:project1/ui/screen/search/search_screen.dart';
import 'package:project1/ui/screen/address/select_delivery_location_screen.dart';
import 'package:project1/ui/screen/ticket/ticket_screen.dart';
import 'package:project1/ui/screen/main/introduction_slider_screen.dart';
import 'package:project1/ui/screen/auth/login_screen.dart';
import 'package:project1/ui/screen/notification/notification_screen.dart';
import 'package:project1/ui/screen/settings/profile_screen.dart';
import 'package:project1/ui/screen/auth/registration_screen.dart';
import 'package:project1/ui/screen/home/restaurants/restaurants_nearby_Screen.dart';
import 'package:project1/ui/screen/settings/service_screen.dart';
import 'package:project1/ui/screen/main/splash_screen.dart';
import 'package:project1/ui/screen/transaction/transaction_screen.dart';
import 'package:project1/ui/screen/transaction/wallet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  static const home = "/";
  static const restaurantNearBy = "/restaurantNearBy";
  static const restaurantDetail = "/restaurantDetail";
  static const login = "login";
  static const splash = 'splash';
  static const signUp = "/signUp";
  static const introSlider = "/introSlider";
  static const cuisine = "/cuisine";
  static const faqs = "/faqs";
  static const addTicket = "/addTicket";
  static const ticket = "/ticket";
  static const editTicket = "/editTicket";
  static const profile = "/profile";
  static const address = "/address";
  //static const updateAddress = "/updateAddress";
  static const deliveryAddress = "/deliveryAddress";
  static const selectAddress = "/selectAddress";
  static const changePassword = "/changePassword";
  static const notification = "/notification";
  static const appSettings = "/appSettings";
  static const settings = "/settings";
  static const cuisineDetail = "/cuisineDetail";
  static const productRatingDetail = "/productRatingDetail";
  static const riderRatingDetail = "/riderRatingDetail";
  static const order = "/order";
  static const orderDetail = "/orderDetail";
  static const riderRating = "/riderRating";
  static const search = "/search";
  static const productSearch = "/productSearch";
  static const place = "/place";
  static const filter = "/filter";
  static const filterDetail = "/filterDetail";
  static const payment = "/payment";
  static const transaction = "/transaction";
  static const wallet = "/wallet";
  static const orderTracking = "/orderTracking";
  static const orderTrackingDetail = "/orderTrackingDetail";
  static const productRating = "/productRating";
  static const partnerRating = "/partnerRating";
  static const account = "/account";
  static const searchLocation = "/searchLocation";
  static const section = "/section";
  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? "";
    print("Current route is : $currentRoute");
    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case home:
        //return MainScreen.route(routeSettings); /*CupertinoPageRoute(builder: (context) => const MainScreen());*/
        return CupertinoPageRoute(builder: (context) => const HomeScreen());
      case introSlider:
        return CupertinoPageRoute(builder: (context) => const IntroductionSliderScreen());
      case login:
        return LoginScreen.route(routeSettings); /*CupertinoPageRoute(builder: (context) => const LoginScreen());*/
      case signUp:
        return RegistrationScreen.route(routeSettings);
      case notification:
        return NotificationScreen.route(routeSettings);
      case appSettings:
        return ServiceScreen.route(routeSettings);
      case restaurantNearBy:
        return RestaurantsNearbyScreen.route(routeSettings);
      case restaurantDetail:
        return RestaurantDetailScreen.route(routeSettings);
      case cuisine:
        return CuisineScreen.route(routeSettings);
      case faqs:
        return FaqsScreen.route(routeSettings);
      case addTicket:
        return AddTicketScreen.route(routeSettings);
      case ticket:
        return CupertinoPageRoute(builder: (context) => const TicketScreen());
      case editTicket:
        return EditTicketScreen.route(routeSettings);
      case profile:
        return ProfileScreen.route(routeSettings);
      case address:
        return AddressScreen.route(routeSettings);
      /* case updateAddress:
        return UpdateAddressScreen.route(routeSettings); */
      case deliveryAddress:
        return DeliveryAddressScreen.route(routeSettings);
      case selectAddress:
        return SelectDeliveryLocationScreen.route(routeSettings);
      case cuisineDetail:
        return CuisineDetailScreen.route(routeSettings);
      case productRatingDetail:
        return ProductRatingDetailScreen.route(routeSettings);
      case riderRatingDetail:
        return RiderRatingDetailScreen.route(routeSettings);
      case order:
        return MyOrderScreen.route(routeSettings);
      case orderDetail:
        return OrderDetailScreen.route(routeSettings);
      case riderRating:
        return RiderRatingScreen.route(routeSettings);
      case search:
        return SearchScreen.route(routeSettings);
      case productSearch:
        return ProductSearchScreen.route(routeSettings);
      case filterDetail:
        return FilterDetailScreen.route(routeSettings);
      case filter:
        return FilterScreen.route(routeSettings);  
      case payment:
        return PaymentScreen.route(routeSettings);
      case transaction:
        return TransactionScreen.route(routeSettings);
      case wallet:
        return WalletScreen.route(routeSettings);
      case orderTracking:
        return OrderTrackingScreen.route(routeSettings);
      case orderTrackingDetail:
        return OrderTrackingDetailScreen.route(routeSettings);
      case productRating:
        return ProductRatingScreen.route(routeSettings);
      case partnerRating:
        return RestaurantRatingDetailScreen.route(routeSettings);  
      case account:
        return CupertinoPageRoute(builder: (context) => const AccountScreen());
      case section:
        return SectionScreen.route(routeSettings);
      case searchLocation:
        return CupertinoPageRoute(builder: (context) => const SearchLocationScreen());  
      default:
        return CupertinoPageRoute(builder: (context) => const Scaffold());
    }
  }
}


import 'package:get/get.dart';
import '../bindings/initial_binding.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/document_screen.dart';
import '../screens/landing/active_trip_screen.dart';
import '../screens/landing/earnings_screen.dart';
import '../screens/landing/home_screen.dart';
import '../bindings/auth_binding.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/landing/order_detail_screen.dart';
import '../screens/landing/rating_screen.dart';
import '../screens/landing/trip_history_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';

import 'package:get/get.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';

import '../bindings/splash_binding.dart';
import '../bindings/auth_binding.dart';

import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupScreen(),
    ),
    GetPage(
      name: Routes.DOCUMENT,
      page: () => DocumentScreen(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
    ),
    // GetPage(
    //   name: Routes.REQUEST,
    //   page: () => TripRequestScreen(),
    // ),
    GetPage(
      name: Routes.ACTIVE_TRIP,
      page: () => ActiveTripScreen(),
    ),
    GetPage(
      name: Routes.EARNINGS,
      page: () => EarningsScreen(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => TripHistoryScreen(),
    ),
    GetPage(
      name: Routes.RATING,
      page: () => RatingScreen(),
    ),
    GetPage(
        name: Routes.LANDING,
        page: () => LandingScreen(),
    ),
  ];
}


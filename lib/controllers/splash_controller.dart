import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';

class SplashController extends GetxController {
  final AuthController authController = AuthController.instance;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(Duration(seconds: 2)); // simulate splash delay


    bool isLoggedIn = await authController.checkLoginStatus(); // Check session and route accordingly

    if (isLoggedIn) {
      Get.offAllNamed(Routes.LANDING);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}

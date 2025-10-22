import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Driver Login",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo
                Image.asset('assets/images/commv_logo.jpg', height: 100),

                const SizedBox(height: 40),

                // 📱 Mobile Number Field
                TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  style: textTheme.bodyLarge,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) {
                    if (controller.isOtpSent.value) {
                      controller.resetOtpFlow();
                    }
                  },
                ),


                const SizedBox(height: 16),

                // 🔑 OTP Field (only if OTP sent)
                if (controller.isOtpSent.value) ...[
                  TextField(
                    controller: controller.otpController,
                    keyboardType: TextInputType.number,
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Enter OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ⏱ Resend OTP
                  Obx(() {
                    return controller.isResendAvailable.value
                        ? TextButton(
                      onPressed: controller.resendOtp,
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    )
                        : Text(
                      "Resend in ${controller.resendSeconds.value}s",
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    );
                  }),
                ],

                const SizedBox(height: 24),

                // 🔘 Send OTP / Verify OTP Button
                controller.isLoading.value
                    ? CircularProgressIndicator(color: colorScheme.primary)
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: controller.isOtpSent.value
                        ? controller.verifyOtp
                        : controller.sendOtp,
                    child: Text(
                      controller.isOtpSent.value ? "Verify OTP" : "Send OTP",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔗 Sign Up Link
                // TextButton(
                //   onPressed: () => Get.toNamed(Routes.SIGNUP),
                //   child: Text.rich(
                //     TextSpan(
                //       text: "Don't have an account? ",
                //       style: textTheme.bodyMedium,
                //       children: [
                //         TextSpan(
                //           text: "Sign Up",
                //           style: textTheme.bodyMedium?.copyWith(
                //             fontWeight: FontWeight.bold,
                //             color: colorScheme.primary,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

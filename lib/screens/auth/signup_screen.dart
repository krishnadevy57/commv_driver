import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController lNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final AuthController authController = Get.put(AuthController());
@override
  void initState() {
    // TODO: implement initState

    super.initState();

    nameController.text = authController.userProfile.value.driverFirstName??"";
    lNameController.text = authController.userProfile.value.driverLastName??"";
    emailController.text = authController.userProfile.value.driverEmail??"";
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Driver Account",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // back button color
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

                // 👤 First Name Field
                TextField(
                  controller: nameController,
                  style: textTheme.bodyLarge,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // 👤 Last Name Field
                TextField(
                  controller: lNameController,
                  style: textTheme.bodyLarge,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 📱 Mobile Number Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.bodyLarge,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // // 🔒 Password Field
                // TextField(
                //   controller: passwordController,
                //   obscureText: true,
                //   style: textTheme.bodyLarge,
                //   decoration: InputDecoration(
                //     prefixIcon: const Icon(Icons.lock),
                //     labelText: 'Password',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 24),

                // 🔘 Sign Up Button
                authController.isLoading.value
                    ? CircularProgressIndicator(color: colorScheme.primary)
                    :SizedBox(
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
                    onPressed: () async{
                     var result = await authController.updateProfile(mfirstName: nameController.text,mlastName: lNameController.text, memail: emailController.text);
                      // Get.snackbar("Signup", "Account created successfully");
                      // Get.offNamed(Routes.LOGIN);
                     if(result){
                       Navigator.pop(context);                     }
                    },
                    child: Text(
                      'Update Account',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔗 Already have an account? Login
                // TextButton(
                //   onPressed: () => Get.offNamed(Routes.LOGIN),
                //   child: Text.rich(
                //     TextSpan(
                //       text: "Already have an account? ",
                //       style: textTheme.bodyMedium,
                //       children: [
                //         TextSpan(
                //           text: "Login",
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
      }
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Header with Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authController.userProfile.value.driverFirstName??"",
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 4),
                          Text(authController.userProfile.value.driverEmail??"",
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                          const SizedBox(height: 2),
                          Text(authController.userProfile.value.driverPhoneNo??"",
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Get.toNamed(
                          Routes.SIGNUP,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // KYC Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.verified_user, color: colorScheme.primary),
                  ),
                  title: Text('Documents KYC', style: textTheme.bodyLarge),
                  subtitle: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text("Verified", style: textTheme.bodySmall?.copyWith(color: Colors.green)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update'),
                    onPressed: () => Get.toNamed(Routes.DOCUMENT),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Support Section
              _buildSectionHeader(context, "Support & Legal"),
              _buildSectionTile(context, "Help & Support", Icons.help_outline),
              _buildSectionTile(context, "Terms and Conditions", Icons.article_outlined),

              // Settings Section
              _buildSectionHeader(context, "Settings"),
              _buildSectionTile(
                context,
                "Logout",
                Icons.logout,
                iconColor: Colors.red,
                onTap: () => authController.logout(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSectionTile(
      BuildContext context,
      String title,
      IconData icon, {
        Color? iconColor,
        VoidCallback? onTap,
      }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        title: Text(title, style: textTheme.bodyLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

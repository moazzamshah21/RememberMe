import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/settings_controller.dart';
import 'package:rememberme/widgets/customAppbar.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomAppBar(
              appBarContent: Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 32,
                        fontFamily: 'PolySans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Plan Section
                _buildCurrentPlanCard(),
                const SizedBox(height: 30),
                
                // Upgrade Your Plan Section
                Text(
                  'Upgrade Your Plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mediumGray,
                    fontFamily: 'PolySans',
                  ),
                ),
                const SizedBox(height: 20),
                
                // Free Plan
                Obx(() => _buildPlanCard(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.mediumGray,
                  title: 'Free',
                  price: '\$0',
                  isCurrent: controller.isCurrentPlan('Free'),
                  borderColor: AppColors.brightTealGreen,
                  onUpgrade: () => controller.upgradePlan('Free'),
                  features: [
                    _FeatureItem(text: 'Up to 50 contacts', included: true),
                    _FeatureItem(text: 'Basic search', included: true),
                    _FeatureItem(text: 'Photo upload', included: true),
                    _FeatureItem(text: 'Offline access', included: true),
                    _FeatureItem(text: 'Advanced filters', included: false),
                    _FeatureItem(text: 'Cloud sync', included: false),
                    _FeatureItem(text: 'Export contacts', included: false),
                    _FeatureItem(text: 'Share contacts', included: false),
                  ],
                )),
                const SizedBox(height: 16),
                
                // Pro Plan
                Obx(() => _buildPlanCard(
                  icon: Icons.bolt,
                  iconColor: AppColors.mediumGray,
                  title: 'Pro',
                  price: '\$4.99/month',
                  isCurrent: controller.isCurrentPlan('Pro'),
                  borderColor: AppColors.brightTealGreen,
                  buttonText: 'Upgrade',
                  onUpgrade: () => controller.upgradePlan('Pro'),
                  features: [
                    _FeatureItem(text: 'Photo upload', included: true),
                    _FeatureItem(text: 'Cloud sync', included: true),
                    _FeatureItem(text: 'Export to CSV', included: true),
                    _FeatureItem(text: 'Custom tags', included: true),
                    _FeatureItem(text: 'Share contact cards', included: false),
                    _FeatureItem(text: 'Priority support', included: false),
                  ],
                )),
                const SizedBox(height: 16),
                
                // Premium Plan
                Obx(() => _buildPlanCard(
                  icon: Icons.workspace_premium,
                  iconColor: AppColors.purple,
                  title: 'Premium',
                  price: '\$9.99/month',
                  isCurrent: controller.isCurrentPlan('Premium'),
                  borderColor: AppColors.brightTealGreen,
                  buttonText: 'Upgrade',
                  onUpgrade: () => controller.upgradePlan('Premium'),
                  features: [
                    _FeatureItem(text: 'Everything in Pro', included: true),
                    _FeatureItem(text: 'Share contact cards', included: true),
                    _FeatureItem(text: 'Multiple devices sync', included: true),
                    _FeatureItem(text: 'Advanced analytics', included: true),
                    _FeatureItem(text: 'Custom reminders', included: true),
                    _FeatureItem(text: 'Priority support', included: true),
                    _FeatureItem(text: 'Dark mode', included: true),
                    _FeatureItem(text: 'Backup & restore', included: true),
                  ],
                )),
                const SizedBox(height: 16),
                
                // Platinum Plan
                Obx(() => _buildPlanCard(
                  icon: Icons.workspace_premium,
                  iconColor: AppColors.orange700,
                  title: 'Platinum',
                  price: '\$19.99/month',
                  isCurrent: controller.isCurrentPlan('Platinum'),
                  borderColor: AppColors.orange300,
                  buttonText: 'Upgrade',
                  onUpgrade: () => controller.upgradePlan('Platinum'),
                  features: [
                    _FeatureItem(text: 'Everything in Premium', included: true),
                    _FeatureItem(text: 'Lifetime updates', included: true),
                    _FeatureItem(text: 'White-label options', included: true),
                    _FeatureItem(text: 'API access', included: true),
                    _FeatureItem(text: 'Dedicated support', included: true),
                    _FeatureItem(text: 'Team collaboration', included: true),
                    _FeatureItem(text: 'Custom integrations', included: true),
                    _FeatureItem(text: 'Early access to features', included: true),
                  ],
                )),
                const SizedBox(height: 30),
                
                // General Heading
                Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mediumGray,
                    fontFamily: 'PolySans',
                  ),
                ),
                const SizedBox(height: 20),
                
                // General Settings Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Privacy & Security
                      _buildGeneralItem(
                        title: 'Privacy & Security',
                        subtitle: 'Manage your data and privacy settings',
                        showDivider: true,
                        onTap: controller.handlePrivacySecurity,
                      ),
                      // Export Data
                      _buildGeneralItem(
                        title: 'Export Data',
                        subtitle: 'Download all your contacts',
                        showDivider: true,
                        onTap: controller.handleExportData,
                      ),
                      // About Remember Me
                      _buildGeneralItem(
                        title: 'About Remember Me',
                        subtitle: 'Version 1.0.0',
                        showDivider: false,
                        onTap: controller.handleAbout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Logout Card
                GestureDetector(
                  onTap: controller.handleLogout,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: AppColors.red700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red700,
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
    }

  IconData _getPlanIcon(String plan) {
    switch (plan) {
      case 'Pro':
        return Icons.bolt;
      case 'Premium':
      case 'Platinum':
        return Icons.workspace_premium;
      case 'Free':
      default:
        return Icons.shield_outlined;
    }
  }

  Widget _buildGeneralItem({
    required String title,
    required String subtitle,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          fontFamily: 'PolySans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                          fontFamily: 'PolySans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200],
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildCurrentPlanCard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.settingsCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.settingsBorderTeal,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with light gray circular background
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPlanIcon(controller.currentPlan.value),
              color: Colors.grey[800],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMediumGray,
                    fontFamily: 'PolySans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.currentPlan.value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'PolySans',
                  ),
                ),
              ],
            ),
          ),
          // Gift button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLightGray,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: Colors.grey[800],
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Gift',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumGray,
                    fontFamily: 'PolySans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPlanCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String price,
    required bool isCurrent,
    required Color borderColor,
    String? buttonText,
    required List<_FeatureItem> features,
    VoidCallback? onUpgrade,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon with light gray circular background (for Free plan)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.lightGray : iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isCurrent ? AppColors.mediumGray : AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: 'PolySans',
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.brightTealGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PolySans',
                    ),
                  ),
                )
              else if (buttonText != null)
                GestureDetector(
                  onTap: onUpgrade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.brightTealGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PolySans',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      feature.included ? Icons.check_circle : Icons.cancel,
                      color: feature.included 
                          ? AppColors.brightTealGreen
                          : AppColors.settingsExcludedFeatureGray,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: feature.included 
                              ? Colors.black 
                              : AppColors.settingsExcludedFeatureGray,
                          fontFamily: 'PolySans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String text;
  final bool included;

  _FeatureItem({required this.text, required this.included});
}

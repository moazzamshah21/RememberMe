import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/bottom_tabs_controller.dart';
import 'package:rememberme/app/views/contact/add_contact_screen.dart';
import 'package:rememberme/app/views/home/home_screen.dart';
import 'package:rememberme/app/views/search/search_screen.dart';
import 'package:rememberme/app/views/favorites/favorites_screen.dart';
import 'package:rememberme/app/views/settings/settings_screen.dart';

class BottomTabs extends GetView<BottomTabsController> {
  const BottomTabs({super.key});

  List<Map<String, dynamic>> _getTabItems() {
    return [
      {'icon': Icons.home, 'label': 'Home', 'screen': HomeScreen()},
      {'icon': Icons.favorite, 'label': 'Favorites', 'screen': FavoritesScreen()},
      {'icon': Icons.search, 'label': 'Search', 'screen': SearchScreen()},
      {'icon': Icons.settings, 'label': 'Settings', 'screen': SettingsScreen()},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabItems = _getTabItems();
    return Scaffold(
      // Display the selected screen - only wrap the body that changes
      body: Obx(() => tabItems[controller.selectedIndex.value]['screen'] as Widget),
      
      floatingActionButton: GestureDetector(
        onTapDown: (_) {
          controller.setPressed(true);
        },
        onTapUp: (_) {
          controller.setPressed(false);
        },
        onTapCancel: () {
          controller.setPressed(false);
        },
        onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContactScreen()),
              );
        },
        child: Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 75,
          width: 75,
          transform: Matrix4.identity()..scale(controller.isPressed.value ? 0.9 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/plus.png'),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            boxShadow: controller.isPressed.value
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadowBlackVeryHeavy,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
        )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: -40,
        elevation: 5,
        height: 80,
        color: const Color(0xFF025786),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final spacing = screenWidth * 0.1; // Responsive spacing (8% of screen width)
            final edgePadding = screenWidth * 0.03; // Responsive edge padding (2% of screen width)
            
            return SizedBox(
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - Home and Favorites
                  Row(
                    children: [
                      SizedBox(width: edgePadding),
                      _buildTabButton(context, 0, tabItems), // Home
                      SizedBox(width: spacing),
                      _buildTabButton(context, 1, tabItems), // Favorites
                    ],
                  ),
                  
                  // Right side - Search and Settings
                  Row(
                    children: [
                      _buildTabButton(context, 2, tabItems), // Search
                      SizedBox(width: spacing),
                      _buildTabButton(context, 3, tabItems), // Settings
                      SizedBox(width: edgePadding),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, int index, List<Map<String, dynamic>> tabItems) {
    return Obx(() {
      final bool isSelected = controller.selectedIndex.value == index;
      
      return GestureDetector(
        onTap: () {
          controller.changeTab(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tabItems[index]['icon'] as IconData,
              color: isSelected ? AppColors.primaryTeal : AppColors.white,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              tabItems[index]['label'] as String,
              style: TextStyle(
                fontFamily: 'PolySans',
                color: isSelected ? AppColors.primaryTeal : AppColors.white,
                fontSize: 9,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      );
    });
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/bottom_tabs_controller.dart';
import 'package:rememberme/app/controllers/search_controller.dart' as app;
import 'package:rememberme/app/controllers/settings_controller.dart';
import 'package:rememberme/widgets/custom_appbar.dart';
import 'package:rememberme/widgets/saved_contact_item.dart';

class SearchScreen extends GetView<app.AppSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<app.AppSearchController>();
    
    // Ensure filtered contacts are updated when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onScreenVisible();
    });
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomAppBar(
              appBarContent: Padding(
                padding: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 0),
                child: Center(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 32,
                      fontFamily: 'PolySans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            controller.refreshFilteredContacts();
          },
          child: CustomScrollView(
            slivers: [
            // Search Input Field
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    color: AppColors.white,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grayWithOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0,6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: (value) {
                          // Update search query immediately for real-time filtering
                          controller.searchQuery.value = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          hintStyle: TextStyle(
                            color: AppColors.textGray,
                            fontFamily: 'PolySans',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textGray,
                            size: 24,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                        ),
                        style: TextStyle(
                          fontFamily: 'PolySans',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Industry Filter Tabs - Multi-select
                  Obx(() {
                    final industries = controller.getAvailableIndustries();
                    if (industries.isEmpty) return const SizedBox.shrink();
                    
                    return Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: industries.length,
                        itemBuilder: (context, index) {
                          final industry = industries[index];
                          final isSelected = controller.selectedIndustries.contains(industry);
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                // Check subscription for advanced filters
                                bool isPremium = false;
                                if (Get.isRegistered<SettingsController>()) {
                                  final settingsController = Get.find<SettingsController>();
                                  isPremium = settingsController.currentPlan.value != 'Free';
                                }

                                if (!isPremium) {
                                  // Get.snackbar(
                                  //   'Premium Feature',
                                  //   'Advanced filtering is available for Pro and Premium users. Please upgrade to use this feature.',
                                  //   snackPosition: SnackPosition.BOTTOM,
                                  //   backgroundColor: AppColors.primaryTeal,
                                  //   colorText: Colors.white,
                                  //   duration: const Duration(seconds: 3),
                                  //   mainButton: TextButton(
                                  //     onPressed: () {
                                  //       Get.back(); // Close snackbar
                                  //       Get.toNamed('settings'); // Navigate to settings
                                  //     },
                                  //     child: const Text(
                                  //       'Upgrade',
                                  //       style: TextStyle(
                                  //         color: Colors.white,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // );

                                  Get.snackbar(
                                    'Premium Feature',
                                    'Advanced filtering is available for Pro and Premium users. Please upgrade to use this feature.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.primaryTeal,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                    mainButton: TextButton(
                                      onPressed: () {
                                        Get.closeAllSnackbars();
                                        final bottomTabsController = Get.find<BottomTabsController>();
                                        bottomTabsController.changeTab(3);
                                      },
                                      child: const Text(
                                        'Upgrade',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                controller.toggleIndustry(industry);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF2F4FC).withValues(alpha: 0.6) 
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(55),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  industry,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.selectedFilterBlue : AppColors.unselectedFilterGray,
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  // Active Filters Display - Below tabs
                  Obx(() {
                    final searchQuery = controller.searchQuery.value.trim();
                    final selectedIndustriesList = controller.selectedIndustries.toList();
                    final hasActiveFilters = searchQuery.isNotEmpty || selectedIndustriesList.isNotEmpty;
                    
                    if (!hasActiveFilters) return const SizedBox.shrink();
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Search query chip
                          if (searchQuery.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Search: $searchQuery',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryBlue,
                                      fontFamily: 'PolySans',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      controller.clearSearchQuery();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Industry filter chips
                          ...selectedIndustriesList.map((industry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    industry,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryBlue,
                                      fontFamily: 'PolySans',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      controller.clearIndustry(industry);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),

                  // Section Header
                  Obx(() {
                    final selectedIndustriesList = controller.selectedIndustries.toList();
                    final hasSelectedIndustries = selectedIndustriesList.isNotEmpty;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasSelectedIndustries 
                                ? selectedIndustriesList.length == 1
                                    ? selectedIndustriesList.first
                                    : '${selectedIndustriesList.length} Industries'
                                : 'All',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              fontFamily: 'PolySans',
                            ),
                          ),
                          if (hasSelectedIndustries)
                            GestureDetector(
                              onTap: () {
                                controller.clearAllFilters();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Clear All',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                        fontFamily: 'PolySans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Search Results List
            Obx(() {
              // Watch the reactive filtered contacts list
              // Access length first to ensure reactivity triggers on any change
              final contactList = controller.filteredContacts.toList();
              
              if (contactList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textGray.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No contacts found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGray,
                            fontFamily: 'PolySans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGray.withValues(alpha: 0.7),
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contact = contactList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SavedContactItem(
                          key: ValueKey(contact.id),
                          contact: contact,
                        ),
                      );
                    },
                    childCount: contactList.length,
                  ),
                ),
              );
            }),
            ],
          ),
        ),
      ),
    );
  }
}

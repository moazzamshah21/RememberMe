import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/search_controller.dart' as app;
import 'package:rememberme/app/controllers/contacts_controller.dart';
import 'package:rememberme/widgets/customAppbar.dart';
import 'package:rememberme/widgets/saved_contact_item.dart';

class SearchScreen extends GetView<app.AppSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<app.AppSearchController>();
    
    // Ensure filtered contacts are updated when screen is built
    // This ensures real-time updates work even if ContactsController loads data after screen init
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
                child: Stack(
                  children: [
                    Center(
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
                    Positioned(
                      right: -5,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => controller.showFilterModal(),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/filter_btn.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          ];
        },
        body: Column(
          children: [
            // Search Input Field
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: AppColors.white,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(
                  //   color: Colors.grey[300]!,
                  //   width: 1,
                  // ),
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
                    // Update search query reactively - this triggers ever() listener
                    controller.searchQuery.value = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, profession, location...',
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

            // Filter Tags - Use Obx for reactive selection state
            Obx(() {
              // Watch contacts to update filter tags reactively
              if (Get.isRegistered<ContactsController>()) {
                final contactsController = Get.find<ContactsController>();
                contactsController.contacts.length; // Watch contacts list
              }
              
              final filterTags = controller.getFilterTags();
              if (filterTags.isEmpty) return const SizedBox.shrink();
              // Access observable directly for selection state
              final selectedTag = controller.selectedFilterTag.value;
              return Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterTags.length,
                  itemBuilder: (context, index) {
                    final tag = filterTags[index];
                    final isSelected = selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          controller.setFilterTag(isSelected ? null : tag);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF2F4FC).withOpacity(0.6) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(55),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
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

            // Section Header with Active Filters Indicator
            Obx(() {
              final selectedTag = controller.selectedFilterTag.value;
              final genderFilter = controller.selectedGenderFilter.value;
              final ethnicityFilter = controller.selectedEthnicityFilter.value;
              final industryFilter = controller.selectedIndustryFilter.value;
              
              final hasActiveFilters = genderFilter != null || 
                                      ethnicityFilter != null || 
                                      industryFilter != null;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTag ?? 'All',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    if (hasActiveFilters)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Filters Active',
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
                  ],
                ),
              );
            }),

            // Search Results List - Use Obx for real-time updates
            Expanded(
              child: Obx(() {
                // Watch the reactive filtered contacts list directly
                // Accessing .value or .length will trigger rebuilds when the list changes
                final filteredContacts = controller.filteredContacts;
                
                // Watch all dependencies to ensure updates
                final searchQuery = controller.searchQuery.value;
                final genderFilter = controller.selectedGenderFilter.value;
                final ethnicityFilter = controller.selectedEthnicityFilter.value;
                final industryFilter = controller.selectedIndustryFilter.value;
                final filterTag = controller.selectedFilterTag.value;
                
                // Watch contacts list for real-time updates from Firebase
                // This is critical - accessing the contacts list ensures we watch it
                int contactsCount = 0;
                if (Get.isRegistered<ContactsController>()) {
                  final contactsController = Get.find<ContactsController>();
                  // Accessing the list and length ensures we watch it reactively
                  contactsCount = contactsController.contacts.length;
                  // Access the list itself to ensure we catch any changes
                  final contactsList = contactsController.contacts;
                  // Use the list to trigger reactivity
                  if (contactsList.isNotEmpty) {
                    contactsList.first; // Access first item to watch the list
                  }
                }
                
                // Get the current filtered contacts list - access .value to trigger reactivity
                // Also access length to ensure we watch the list properly
                final filteredCount = filteredContacts.length;
                final contactList = filteredContacts.toList();
                
                if (contactList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textGray.withOpacity(0.5),
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
                            color: AppColors.textGray.withOpacity(0.7),
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    controller.refreshFilteredContacts();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      final contact = contactList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SavedContactItem(contact: contact),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

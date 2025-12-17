import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/search_controller.dart' as app;
import 'package:rememberme/widgets/customAppbar.dart';
import 'package:rememberme/widgets/saved_contact_item.dart';

class SearchScreen extends GetView<app.AppSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<app.AppSearchController>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomAppBar(
              appBarContent: Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
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
                      right: 0,
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
                  onChanged: (_) => controller.update(),
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(
                      color: AppColors.textGray,
                      fontFamily: 'PolySans',
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
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

            // Section Header
            Obx(() {
              // Directly access observable variable
              final selectedTag = controller.selectedFilterTag.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedTag ?? 'All',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      fontFamily: 'PolySans',
                    ),
                  ),
                ),
              );
            }),

            // Search Results List - Use GetBuilder for real-time updates
            Expanded(
              child: GetBuilder<app.AppSearchController>(
                builder: (ctrl) {
                  final filteredContacts = ctrl.getFilteredContacts();
                  return filteredContacts.isEmpty
                      ? Center(
                          child: Text(
                            'No contacts found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textGray,
                              fontFamily: 'PolySans',
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            return SavedContactItem(contact: contact);
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

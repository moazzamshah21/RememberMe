// screens/contact_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/contact_detail_controller.dart';
import 'package:rememberme/app/models/contact_model.dart';

class ContactDetailScreen extends GetView<ContactDetailController> {
  final Contact contact;
  
  const ContactDetailScreen({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with contact - use a unique tag per contact
    final tag = contact.id.toString();
    final controller = Get.put(ContactDetailController(), tag: tag);
    // Always set the contact to ensure it's up to date
    if (controller.contact == null || controller.contact!.id != contact.id) {
      controller.setContact(contact);
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // Top image section
              SliverToBoxAdapter(
                child: Container(
                  height: 400,
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      // Image Carousel with bottom border radius
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: SizedBox(
                          height: 400,
                          child: PageView.builder(
                            controller: controller.pageController,
                            itemCount: controller.profileImages.length,
                            onPageChanged: controller.changeImageIndex,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  child: Image.asset(
                                    controller.profileImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.primaryBlue,
                                        child: Center(
                                          child: Text(
                                            contact.name.split(' ').map((n) => n[0]).join(),
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Page indicators
                      Obx(() {
                        final ctrl = Get.find<ContactDetailController>(tag: tag);
                        return Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              ctrl.profileImages.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ctrl.currentImageIndex.value == index 
                                      ? AppColors.white 
                                      : AppColors.whiteWithOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              // Main content section
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Name at top
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Text(
                          contact.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ),
                      
                      // Notes Section with Read More - Edit icon outside field
                      Obx(() {
                        // Only access observable variables directly in Obx
                        final ctrl = Get.find<ContactDetailController>(tag: tag);
                        final isExpanded = ctrl.isNotesExpanded.value;
                        return _buildNotesFieldWithEdit(
                          content: contact.notes,
                          isExpanded: isExpanded,
                          onExpandToggle: ctrl.toggleNotesExpansion,
                        );
                      }),
                      
                      const SizedBox(height: 20),
                      
                      // Company
                      _buildFieldWithEdit(
                        title: "Company",
                        content: contact.company,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Gender
                      _buildFieldWithEdit(
                        title: "Gender",
                        content: contact.gender,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Age Range
                      _buildFieldWithEdit(
                        title: "Age Range",
                        content: contact.ageRange,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Characteristics
                      _buildFieldWithEdit(
                        title: "Characteristics",
                        content: contact.characteristics,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Ethnicity
                      _buildFieldWithEdit(
                        title: "Ethnicity",
                        content: contact.ethnicity,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Industry
                      _buildFieldWithEdit(
                        title: "Industry",
                        content: contact.industry,
                      ),
                      
                      // Bottom spacing for back button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Back button at top left
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(102),
                  // gradient: const LinearGradient(
                  //   begin: Alignment.centerLeft,
                  //   end: Alignment.centerRight,
                  //   colors: [
                  //     Color(0xFF00BDE8),
                  //     Color(0xFF00FFD0),
                  //   ],
                  // ),
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBlackHeavy,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          
          // Favorite button at top right
          GetBuilder<ContactDetailController>(
            tag: tag,
            builder: (ctrl) => Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => ctrl.toggleFavorite(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(102),
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBlackHeavy,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      (ctrl.contact?.isFavorite ?? contact.isFavorite) ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.favoriteRed,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Back Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.lightBlue,
                      AppColors.cyan,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBlackHeavy,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered Text
                    Text(
                      "Back",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PolySans',
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    // Icon at the start
                    Positioned(
                      left: 20,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Special builder for Notes field with edit icon outside
  Widget _buildNotesFieldWithEdit({
    required String content,
    bool isExpanded = false,
    VoidCallback? onExpandToggle,
  }) {
    final displayText = !isExpanded && content.length > 150
        ? '${content.substring(0, 150)}...'
        : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes Title with Edit Icon on right side
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Notes",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textGray,
                fontFamily: 'PolySans',
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle edit for notes field
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.borderLightGray,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Notes Content Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.veryLightGray,
            border: Border.all(color: AppColors.borderLightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDarkGray,
                    fontFamily: 'PolySans',
                    height: 1.4,
                  ),
                ),
                
                if (content.length > 150)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onExpandToggle,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isExpanded ? "Read Less..." : "Read More...",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                          fontFamily: 'PolySans',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithEdit({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
              fontFamily: 'PolySans',
            ),
          ),
        ),
        
        // Field Content Container with Edit Icon
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.veryLightGray,
            border: Border.all(color: AppColors.borderLightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDarkGray,
                    fontFamily: 'PolySans',
                    height: 1.4,
                  ),
                ),
              ),
              
              // Edit Icon in top-right corner inside the field
              Positioned(
                top: 9,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    // Handle edit for this field
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderLightGray,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
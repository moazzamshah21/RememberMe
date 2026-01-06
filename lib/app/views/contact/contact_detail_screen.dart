// screens/contact_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
    // Always set the contact to ensure it's up to date (this will also set profile images)
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
                          child: Obx(() {
                            final ctrl = Get.find<ContactDetailController>(tag: tag);
                            final images = ctrl.profileImages;
                            final contactName = ctrl.contact?.name ?? contact.name;
                            
                            if (images.isEmpty || (images.length == 1 && images.first == 'assets/images/profilepic.png')) {
                              return Container(
                                color: AppColors.primaryBlue,
                                child: Center(
                                  child: Text(
                                    contactName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return PageView.builder(
                              controller: ctrl.pageController,
                              itemCount: images.length,
                              onPageChanged: ctrl.changeImageIndex,
                              itemBuilder: (context, index) {
                                final imageUrl = images[index];
                                final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                    ),
                                    child: isNetworkImage
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: AppColors.primaryBlue,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: AppColors.primaryBlue,
                                                child: Center(
                                                  child: Text(
                                                    contactName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase(),
                                                    style: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 48,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: AppColors.primaryBlue,
                                                child: Center(
                                                  child: Text(
                                                    contactName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase(),
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
                            );
                          }),
                        ),
                      ),
                      
                      // Page indicators and Add Image button
                      Obx(() {
                        final ctrl = Get.find<ContactDetailController>(tag: tag);
                        return Stack(
                          children: [
                            // Page indicators
                            if (ctrl.profileImages.length > 1)
                              Positioned(
                                bottom: 80,
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
                              ),
                            
                            // Add Image button
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: GestureDetector(
                                onTap: () => _showImageSourceDialog(context, tag),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
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
                                  child: Obx(() {
                                    if (ctrl.isUploadingImage.value) {
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                          ),
                                        ),
                                      );
                                    }
                                    return const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 28,
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
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
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Text(
                            ctrl.contact?.name ?? contact.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              fontFamily: 'PolySans',
                            ),
                          ),
                        ),
                      ),
                      
                      // Notes Section with Read More - Edit icon outside field
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) {
                          return Obx(() {
                            final isExpanded = ctrl.isNotesExpanded.value;
                            return _buildNotesFieldWithEdit(
                              content: ctrl.contact?.notes ?? contact.notes,
                              isExpanded: isExpanded,
                              onExpandToggle: ctrl.toggleNotesExpansion,
                              onEdit: () => _showEditDialog(context, tag, 'notes', ctrl.contact?.notes ?? contact.notes, ctrl),
                            );
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Company
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => _buildFieldWithEdit(
                          title: "Company",
                          content: ctrl.contact?.company ?? contact.company,
                          onEdit: () => _showEditDialog(context, tag, 'company', ctrl.contact?.company ?? contact.company, ctrl),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Gender
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => _buildFieldWithEdit(
                          title: "Gender",
                          content: ctrl.contact?.gender ?? contact.gender,
                          onEdit: () => _showEditDialog(context, tag, 'gender', ctrl.contact?.gender ?? contact.gender, ctrl),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Age Range
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => _buildFieldWithEdit(
                          title: "Age Range",
                          content: ctrl.contact?.ageRange ?? contact.ageRange,
                          onEdit: () => _showEditDialog(context, tag, 'ageRange', ctrl.contact?.ageRange ?? contact.ageRange, ctrl),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Characteristics
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => _buildFieldWithEdit(
                          title: "Characteristics",
                          content: ctrl.contact?.characteristics ?? contact.characteristics,
                          onEdit: () => _showEditDialog(context, tag, 'characteristics', ctrl.contact?.characteristics ?? contact.characteristics, ctrl),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Ethnicity
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => _buildFieldWithEdit(
                          title: "Ethnicity",
                          content: ctrl.contact?.ethnicity ?? contact.ethnicity,
                          onEdit: () => _showEditDialog(context, tag, 'ethnicity', ctrl.contact?.ethnicity ?? contact.ethnicity, ctrl),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Industry
                      GetBuilder<ContactDetailController>(
                        tag: tag,
                        builder: (ctrl) => _buildFieldWithEdit(
                          title: "Industry",
                          content: ctrl.contact?.industry ?? contact.industry,
                          onEdit: () => _showEditDialog(context, tag, 'industry', ctrl.contact?.industry ?? contact.industry, ctrl),
                        ),
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
          
          // Bottom Share Button
          GetBuilder<ContactDetailController>(
            tag: tag,
            builder: (ctrl) => Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  ctrl.shareContact();
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
                        "Share",
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
                          Icons.share_rounded,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, String tag) {
    final controller = Get.find<ContactDetailController>(tag: tag);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                title: const Text('Choose from Gallery (Multi-select)'),
                subtitle: Obx(() {
                  final ctrl = Get.find<ContactDetailController>(tag: tag);
                  final currentCount = ctrl.profileImages.where((img) => 
                    img != 'assets/images/profilepic.png' && 
                    !img.startsWith('assets/')
                  ).length;
                  final remaining = ContactDetailController.maxImages - currentCount;
                  return Text(
                    remaining > 0 
                        ? 'Select up to $remaining more image(s)'
                        : 'Maximum ${ContactDetailController.maxImages} images reached',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                      fontFamily: 'PolySans',
                    ),
                  );
                }),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAndAddImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAndAddImage(source: ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String tag, String fieldName, String currentValue, ContactDetailController controller) {
    final TextEditingController textController = TextEditingController(text: currentValue);
    final String fieldTitle = fieldName[0].toUpperCase() + fieldName.substring(1);
    
    // For multi-value fields, show hint
    final bool isMultiValue = fieldName == 'characteristics' || fieldName == 'industry';
    final String hint = isMultiValue ? 'Separate values with commas' : '';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit $fieldTitle',
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontFamily: 'PolySans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteWithOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.whiteWithOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: fieldName == 'notes' ? 5 : (isMultiValue ? 3 : 1),
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontFamily: 'PolySans',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppColors.lightBlue,
                      fontFamily: 'PolySans',
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      final newValue = textController.text.trim();
                      if (newValue.isNotEmpty) {
                        controller.updateField(fieldName, newValue);
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.lightBlue,
                            AppColors.cyan,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PolySans',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontFamily: 'PolySans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Special builder for Notes field with edit icon outside
  Widget _buildNotesFieldWithEdit({
    required String content,
    bool isExpanded = false,
    VoidCallback? onExpandToggle,
    VoidCallback? onEdit,
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
              onTap: onEdit,
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
    VoidCallback? onEdit,
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
                  onTap: onEdit,
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
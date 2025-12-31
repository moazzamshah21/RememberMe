import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/add_contact_controller.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final AddContactController controller = Get.put(AddContactController());
  
  // Edit states
  bool _isEditingMeetingPlace = false;
  final FocusNode _meetingPlaceFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Set default values
    if (controller.selectedDate.value == null) {
      controller.selectedDate.value = DateTime(2025, 1, 16);
    }
    if (controller.meetingPlaceController.text.isEmpty) {
      controller.meetingPlaceController.text = 'Paris, Restaurant';
    }
    if (controller.selectedCharacteristics.isEmpty) {
      controller.selectedCharacteristics.add('Ambitious');
    }
    if (controller.selectedAgeRange.value.isEmpty) {
      controller.selectedAgeRange.value = '10 - 20';
    }
    if (controller.selectedIndustry.value.isEmpty) {
      // Don't set default industry - user must select
    }
    
    // Listen to focus changes
    _meetingPlaceFocusNode.addListener(() {
      if (!_meetingPlaceFocusNode.hasFocus && _isEditingMeetingPlace) {
        setState(() {
          _isEditingMeetingPlace = false;
        });
      }
    });
  }
  
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      fontFamily: 'PolySans',
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontFamily: 'PolySans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(source: ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontFamily: 'PolySans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(source: ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _meetingPlaceFocusNode.dispose();
    // Clean up controller when screen is disposed
    Get.delete<AddContactController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _AddContactAppBarDelegate(),
            ),
          ];
        },
        body: Container(
          color: AppColors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Gradient shadow/glow effect behind the profile picture
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.lightBlue.withValues(alpha: 0.19),
                              AppColors.cyan.withValues(alpha: 0.19),
                            ],
                            stops: [0.0, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightBlue.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 02,
                            ),
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 02,
                            ),
                          ],
                        ),
                      ),
                      // Large profile picture placeholder or selected image
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Obx(() => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.borderLightGray,
                              width: 0,
                            ),
                          ),
                          child: controller.selectedImages.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    controller.selectedImages.first,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: AppColors.textGray,
                                ),
                        )),
                      ),
                      // Small plus button overlay with image
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            _showImageSourceDialog(context);
                          },
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.transparent,
                            ),
                            child: Image.asset(
                              'assets/images/plus.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 60),
                
                // Meeting Details Section - Where you meet?
                Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isEditingMeetingPlace = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Label
                          Text(
                            'Where you meet?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                              fontFamily: 'PolySans',
                            ),
                          ),
                          SizedBox(width: 12),
                          // Value - Editable TextField
                          Expanded(
                            child: _isEditingMeetingPlace
                                ? TextField(
                                    controller: controller.meetingPlaceController,
                                    focusNode: _meetingPlaceFocusNode,
                                    autofocus: true,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                      fontFamily: 'PolySans',
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: (value) {
                                      _meetingPlaceFocusNode.unfocus();
                                      setState(() {
                                        _isEditingMeetingPlace = false;
                                      });
                                    },
                                    onEditingComplete: () {
                                      _meetingPlaceFocusNode.unfocus();
                                      setState(() {
                                        _isEditingMeetingPlace = false;
                                      });
                                    },
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingMeetingPlace = true;
                                      });
                                    },
                                    child: Text(
                                      controller.meetingPlaceController.text.isEmpty 
                                        ? 'Paris, Restaurant' 
                                        : controller.meetingPlaceController.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                        fontFamily: 'PolySans',
                                      ),
                                    ),
                                  ),
                          ),
                          // Edit icon
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingMeetingPlace = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: AppColors.textMediumGray,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 15),
                
                // When
                Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: () => _selectDateRange(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Label
                          Text(
                            'When',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                              fontFamily: 'PolySans',
                            ),
                          ),
                          SizedBox(width: 12),
                          // Value
                          Expanded(
                            child: Obx(() => Text(
                              controller.selectedDate.value == null 
                                ? 'Jan 16, 2025'
                                : _formatDate(controller.selectedDate.value!),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                                fontFamily: 'PolySans',
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Basic Info Section - Inside Container
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBlackLight,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Info',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                          fontFamily: 'PolySans',
                        ),
                      ),
                      SizedBox(height: 15),
                      
                      // Name field
                      _buildInputField(
                        controller: controller.nameController,
                        label: 'Name',
                      ),
                      SizedBox(height: 15),
                      
                      // Gender dropdown
                      Obx(() => _buildDropdownField(
                        label: 'Gender',
                        value: controller.selectedGender.value.isEmpty ? null : controller.selectedGender.value,
                        items: ['Male', 'Female'],
                        onChanged: (String? value) {
                          controller.selectedGender.value = value ?? '';
                        },
                      )),
                    ],
                  ),
                ),
                
                SizedBox(height: 30),
                
                Divider(color: AppColors.borderLightGray, thickness: 1),
                
                SizedBox(height: 30),
                
                // Characteristics Section
                Row(
                  children: [
                    Text(
                      'Characteristics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Multi Select',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        fontFamily: 'PolySans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                
                _buildCharacteristicsChips(),
                
                SizedBox(height: 30),
                
                Divider(color: AppColors.borderLightGray, thickness: 1),
                
                SizedBox(height: 30),
                
                // Ethnicity Section
                Text(
                  'Ethnicity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontFamily: 'PolySans',
                  ),
                ),
                SizedBox(height: 15),
                
                // Ethnicity dropdown
                Obx(() => _buildDropdownField(
                  label: 'Ethnicity',
                  value: controller.selectedEthnicity.value.isEmpty ? null : controller.selectedEthnicity.value,
                  items: _getEthnicityList(),
                  onChanged: (String? value) {
                    controller.selectedEthnicity.value = value ?? '';
                  },
                )),
                
                SizedBox(height: 30),
                
                Divider(color: AppColors.borderLightGray, thickness: 1),
                
                SizedBox(height: 30),
                
                // Age Range Section
                Text(
                  'Age Range',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontFamily: 'PolySans',
                  ),
                ),
                SizedBox(height: 15),
                
                _buildAgeRangeChips(),
                
                SizedBox(height: 30),
                
                Divider(color: AppColors.borderLightGray, thickness: 1),
                
                SizedBox(height: 30),
                
                // Industry Section
                Text(
                  'Industry',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontFamily: 'PolySans',
                  ),
                ),
                SizedBox(height: 15),
                
                _buildIndustryChips(),
                
                SizedBox(height: 30),
                
                Divider(color: AppColors.borderLightGray, thickness: 1),
                
                SizedBox(height: 30),
                
                // Company Name Section
                Text(
                  'Company Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontFamily: 'PolySans',
                  ),
                ),
                SizedBox(height: 15),
                
                _buildInputField(
                  controller: controller.companyNameController,
                  label: 'Company Name',
                ),
                
                SizedBox(height: 30),
                
                // Additional Notes Section
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.borderLightGray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          'Additional Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ),
                      TextField(
                        controller: controller.descriptionController,
                        maxLines: null,
                        minLines: 4,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          hintText: 'Description',
                          hintStyle: TextStyle(
                            color: AppColors.mediumGray,
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Save Button - Full Width
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryTealAlt,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBlackMedium,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() => TextButton(
                    onPressed: controller.isLoading.value ? null : () {
                      controller.saveContact();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : Text(
                            'Save',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontFamily: 'PolySans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  )),
                ),
                
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != controller.selectedDate.value) {
      controller.selectedDate.value = picked;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    
    return '$month $day, $year';
  }

  Widget _buildInputField({required TextEditingController controller, required String label}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGray,
        border: Border.all(color: AppColors.borderLightGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(
                            color: AppColors.mediumGray,
            fontFamily: 'PolySans',
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGray,
        border: Border.all(color: AppColors.borderLightGray),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            label,
            style: TextStyle(
              color: AppColors.mediumGray,
              fontFamily: 'PolySans',
            ),
          ),
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontFamily: 'PolySans',
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textGray,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<String> _getEthnicityList() {
    return [
      'White Catholic',
      'Latino',
      'Hispanic',
      'African American',
      'Black',
      'Asian',
      'Native American',
      'Pacific Islander',
      'Middle Eastern',
      'White',
      'Mixed Race',
      'Other',
    ];
  }

  Widget _buildCharacteristicsChips() {
    List<String> characteristics = [
      'Ambitious',
      'Creative',
      'Compassionate',
      'Courageous',
      'Humble',
      'See More'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: characteristics.map((char) {
            return Obx(() {
              final isSelected = controller.selectedCharacteristics.contains(char);
              return GestureDetector(
                onTap: () {
                  if (char == 'See More') {
                    // Show dialog to add custom characteristic
                    _showAddCharacteristicDialog(context);
                    return;
                  }
                  if (isSelected) {
                    controller.selectedCharacteristics.remove(char);
                  } else {
                    controller.selectedCharacteristics.add(char);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGray : AppColors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.textGray : AppColors.borderLightGray,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    char,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontFamily: 'PolySans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
        // Show custom characteristics if any
        Obx(() {
          final customChars = controller.selectedCharacteristics
              .where((char) => !characteristics.contains(char))
              .toList();
          if (customChars.isEmpty) return SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: customChars.map((char) {
                return GestureDetector(
                  onTap: () {
                    controller.selectedCharacteristics.remove(char);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      border: Border.all(
                        color: AppColors.textGray,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          char,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                            fontFamily: 'PolySans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textGray,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
  
  void _showAddCharacteristicDialog(BuildContext context) {
    controller.customCharacteristicController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Characteristic',
            style: TextStyle(
              fontFamily: 'PolySans',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller.customCharacteristicController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter characteristic',
              hintStyle: TextStyle(
                color: AppColors.mediumGray,
                fontFamily: 'PolySans',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'PolySans',
                  color: AppColors.textGray,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final text = controller.customCharacteristicController.text.trim();
                if (text.isNotEmpty) {
                  controller.selectedCharacteristics.add(text);
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'PolySans',
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgeRangeChips() {
    List<String> ageRanges = [
      '0 - 10',
      '10 - 20',
      '20 - 30',
      '30 - 40',
      '40 - 50',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ageRanges.map((range) {
        return Obx(() {
          final isSelected = controller.selectedAgeRange.value == range;
          return GestureDetector(
            onTap: () {
              controller.selectedAgeRange.value = range;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightGray : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.textGray : AppColors.borderLightGray,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                range,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontFamily: 'PolySans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildIndustryChips() {
    List<String> industries = [
      'Healthcare',
      'Automotive',
      'Technology',
      'Cricketer',
      'Dancer',
      'Inspector',
      'Teacher'
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: industries.map((industry) {
        return Obx(() {
          final isSelected = controller.selectedIndustry.value == industry;
          return GestureDetector(
            onTap: () {
              // Only one industry can be selected - replace previous selection
              controller.selectedIndustry.value = isSelected ? '' : industry;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightGray : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.textGray : AppColors.borderLightGray,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                industry,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontFamily: 'PolySans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}

// Custom AppBar Delegate for Add Contact Screen
class _AddContactAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxExtent,
        minHeight: minExtent,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlackMedium,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Top row with back button and title
            Row(
              children: [
                // Back Icon
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.primaryTealAlt,
                    size: 30,
                  ),
                ),
                // Title - Centered
                Expanded(
                  child: Center(
                    child: Text(
                      'Add Contact Detail',
                      style: TextStyle(
                        color: AppColors.primaryTealAlt,
                        fontSize: 20,
                        fontFamily: 'PolySans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Spacer to balance the back button
                SizedBox(width: 48),
              ],
            ),
          ],
              ),
      ),
    );
  }

  @override
  double get maxExtent => 110.0;

  @override
  double get minExtent => 110.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

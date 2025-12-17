import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/data/contacts_data.dart';
import 'package:rememberme/app/models/contact_model.dart';

class AppSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedFilterTag = RxnString();
  final RxnString selectedFilterCategory = RxnString();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      update(); // Rebuild when search text changes
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setFilterTag(String? tag) {
    selectedFilterTag.value = tag;
    update(); // Trigger GetBuilder rebuild
  }

  void setFilterCategory(String? category) {
    selectedFilterCategory.value = category;
    update(); // Trigger GetBuilder rebuild
  }

  void showFilterModal() {
    Get.bottomSheet(
      _FilterModal(
        selectedCategory: selectedFilterCategory.value,
        onCategorySelected: (category) {
          setFilterCategory(category);
          Get.back();
        },
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  // Get unique filter tags from contacts
  List<String> getFilterTags() {
    final Set<String> tags = {};
    for (var contact in ContactsData.contacts) {
      if (contact.ethnicity.contains('Catholic')) {
        tags.add('Catholic');
      }
      if (contact.ethnicity.contains('Black')) {
        tags.add('Black');
      }
      tags.add(contact.profession);
    }
    return tags.toList();
  }

  // Filter contacts based on search query and selected filter
  List<Contact> getFilteredContacts() {
    List<Contact> contacts = List.from(ContactsData.contacts);
    final searchQuery = searchController.text.toLowerCase().trim();

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      contacts = contacts.where((contact) {
        return contact.name.toLowerCase().contains(searchQuery) ||
            contact.profession.toLowerCase().contains(searchQuery) ||
            contact.location.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Filter by selected filter tag
    final filterTag = selectedFilterTag.value;
    if (filterTag != null && filterTag.isNotEmpty) {
      contacts = contacts.where((contact) {
        if (filterTag == 'Catholic') {
          return contact.ethnicity.contains('Catholic');
        } else if (filterTag == 'Black') {
          return contact.ethnicity.contains('Black');
        } else {
          return contact.profession == filterTag;
        }
      }).toList();
    }

    return contacts;
  }
}

// Filter Modal Widget
class _FilterModal extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const _FilterModal({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Filter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
                fontFamily: 'PolySans',
              ),
            ),
          ),
          _buildFilterOption('Where', selectedCategory == 'Where', () => onCategorySelected('Where')),
          _buildDivider(),
          _buildFilterOption('Gender', selectedCategory == 'Gender', () => onCategorySelected('Gender')),
          _buildDivider(),
          _buildFilterOption('Ethnicity', selectedCategory == 'Ethnicity', () => onCategorySelected('Ethnicity')),
          _buildDivider(),
          _buildFilterOption('Industry', selectedCategory == 'Industry', () => onCategorySelected('Industry')),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowBlackMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () => onCategorySelected(selectedCategory ?? 'Where'),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontFamily: 'PolySans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
                fontFamily: 'PolySans',
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.lightBlue : AppColors.textGray,
                  width: 2,
                ),
                color: isSelected ? AppColors.lightBlue : AppColors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.borderLightGray,
      thickness: 1,
      height: 1,
    );
  }
}

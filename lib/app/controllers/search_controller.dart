import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/contacts_controller.dart';
import 'package:rememberme/app/models/contact_model.dart';

class AppSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedFilterTag = RxnString();
  final RxnString selectedFilterCategory = RxnString();
  final RxnString selectedGenderFilter = RxnString();
  final RxnString selectedEthnicityFilter = RxnString();
  final RxnString selectedIndustryFilter = RxnString();
  
  // Reactive search query
  final RxString searchQuery = ''.obs;
  
  // Reactive filtered contacts list
  final RxList<Contact> filteredContacts = <Contact>[].obs;

  Worker? _contactsWorker;
  Worker? _searchQueryWorker;
  Worker? _filterTagWorker;
  Worker? _genderFilterWorker;
  Worker? _ethnicityFilterWorker;
  Worker? _industryFilterWorker;

  @override
  void onInit() {
    super.onInit();
    
    // Ensure all filters are cleared on init
    selectedFilterTag.value = null;
    selectedFilterCategory.value = null;
    selectedGenderFilter.value = null;
    selectedEthnicityFilter.value = null;
    selectedIndustryFilter.value = null;
    searchQuery.value = '';
    
    // Listen to search text changes reactively
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    
    // Set up workers to watch all observables for real-time updates
    _setupReactiveWorkers();
    
    // Listen to contacts changes for real-time updates
    _setupContactsListener();
    
    // Initial update after a short delay to ensure ContactsController is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isRegistered<ContactsController>()) {
        _updateFilteredContacts();
      }
    });
  }

  void _setupReactiveWorkers() {
    // Watch search query changes
    _searchQueryWorker = ever(searchQuery, (_) => _updateFilteredContacts());
    
    // Watch filter changes
    _filterTagWorker = ever(selectedFilterTag, (_) => _updateFilteredContacts());
    _genderFilterWorker = ever(selectedGenderFilter, (_) => _updateFilteredContacts());
    _ethnicityFilterWorker = ever(selectedEthnicityFilter, (_) => _updateFilteredContacts());
    _industryFilterWorker = ever(selectedIndustryFilter, (_) => _updateFilteredContacts());
  }
  
  void _setupContactsListener() {
    // Wait a bit for ContactsController to be registered (it's created on HomeScreen)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<ContactsController>()) {
        final contactsController = Get.find<ContactsController>();
        
        // Use ever() to watch contacts list - triggers when list reference changes
        // This will fire when ContactsController updates contacts.value = newList
        _contactsWorker = ever(contactsController.contacts, (List<Contact> contacts) {
          // Update filtered contacts when contacts change
          print('SearchController: Contacts list changed, updating filtered contacts. Count: ${contacts.length}');
          _updateFilteredContacts();
        });
        
        // Initial update
        _updateFilteredContacts();
      } else {
        // Retry if ContactsController isn't registered yet
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.isRegistered<ContactsController>()) {
            final contactsController = Get.find<ContactsController>();
            
            _contactsWorker = ever(contactsController.contacts, (List<Contact> contacts) {
              print('SearchController: Contacts list changed, updating filtered contacts. Count: ${contacts.length}');
              _updateFilteredContacts();
            });
            
            // Initial update
            _updateFilteredContacts();
          } else {
            // If still not registered, try one more time
            Future.delayed(const Duration(milliseconds: 1000), () {
              _setupContactsListener();
            });
          }
        });
      }
    });
  }
  
  void _updateFilteredContacts() {
    if (!Get.isRegistered<ContactsController>()) {
      if (filteredContacts.isNotEmpty) {
        filteredContacts.clear();
        filteredContacts.refresh();
      }
      return;
    }
    
    try {
      final contactsController = Get.find<ContactsController>();
      final allContacts = contactsController.contacts;
      
      print('SearchController: Updating filtered contacts. Total contacts: ${allContacts.length}');
      
      final newContacts = getFilteredContacts();
      
      print('SearchController: Filtered contacts count: ${newContacts.length}');
      print('SearchController: Filtered contact names: ${newContacts.take(10).map((c) => c.name).toList()}');
      
      // Use assignAll to replace the entire list - this is the proper way for RxList
      // assignAll ensures GetX detects the change and updates the UI correctly
      filteredContacts.assignAll(newContacts);
      
      print('SearchController: Filtered contacts updated successfully. List now has ${filteredContacts.length} items');
      print('SearchController: Verified filtered contacts in RxList: ${filteredContacts.map((c) => c.name).toList()}');
    } catch (e, stackTrace) {
      print('Error updating filtered contacts: $e');
      print('Stack trace: $stackTrace');
      filteredContacts.clear();
      filteredContacts.refresh();
    }
  }

  @override
  void onClose() {
    // Dispose workers to prevent memory leaks
    _contactsWorker?.dispose();
    _searchQueryWorker?.dispose();
    _filterTagWorker?.dispose();
    _genderFilterWorker?.dispose();
    _ethnicityFilterWorker?.dispose();
    _industryFilterWorker?.dispose();
    
    searchController.dispose();
    super.onClose();
  }
  
  // Public method to force update (can be called from UI)
  void refreshFilteredContacts() {
    _updateFilteredContacts();
  }

  // Method to ensure contacts are loaded and filtered contacts are updated
  // Call this when the search screen becomes visible
  void onScreenVisible() {
    // Re-setup contacts listener in case ContactsController wasn't ready before
    if (!Get.isRegistered<ContactsController>()) {
      _setupContactsListener();
    } else {
      // Re-setup the listener to ensure it's active
      final contactsController = Get.find<ContactsController>();
      
      // Dispose old worker if exists
      _contactsWorker?.dispose();
      
      // Set up new worker
      _contactsWorker = ever(contactsController.contacts, (List<Contact> contacts) {
        print('SearchController: Screen visible - Contacts list changed, updating filtered contacts. Count: ${contacts.length}');
        _updateFilteredContacts();
      });
      
      // Ensure filtered contacts are up to date immediately
      _updateFilteredContacts();
    }
  }
  
  // Method to reset search and filters completely
  void resetSearch() {
    // Clear search query
    searchController.clear();
    searchQuery.value = '';
    
    // Clear all filters
    clearAllFilters();
    
    // Update filtered contacts
    _updateFilteredContacts();
  }

  void setFilterTag(String? tag) {
    // UI already handles toggle logic, so just set the value directly
    final previousValue = selectedFilterTag.value;
    selectedFilterTag.value = tag;
    
    print('SearchController: Filter tag changed from "$previousValue" to "$tag"');
    
    // Always update when filter tag changes
    _updateFilteredContacts();
  }

  void setFilterCategory(String? category) {
    // Clear previous value and set new one
    final previousValue = selectedFilterCategory.value;
    selectedFilterCategory.value = category;
    
    // Only update if value actually changed
    if (previousValue != category) {
      _updateFilteredContacts();
    }
  }
  
  void setGenderFilter(String? gender) {
    // Clear previous value and set new one
    final previousValue = selectedGenderFilter.value;
    selectedGenderFilter.value = gender;
    
    print('SearchController: setGenderFilter called - previous: "$previousValue", new: "$gender"');
    
    // Always update when gender filter changes
    _updateFilteredContacts();
  }
  
  void setEthnicityFilter(String? ethnicity) {
    // Clear previous value and set new one
    final previousValue = selectedEthnicityFilter.value;
    selectedEthnicityFilter.value = ethnicity;
    
    print('SearchController: setEthnicityFilter called - previous: "$previousValue", new: "$ethnicity"');
    
    // Always update when ethnicity filter changes
    _updateFilteredContacts();
  }
  
  void setIndustryFilter(String? industry) {
    // Clear previous value and set new one
    final previousValue = selectedIndustryFilter.value;
    selectedIndustryFilter.value = industry;
    
    print('SearchController: setIndustryFilter called - previous: "$previousValue", new: "$industry"');
    
    // Always update when industry filter changes
    _updateFilteredContacts();
  }
  
  void clearAllFilters() {
    // Store previous state to check if anything changed
    final hadFilters = selectedFilterTag.value != null ||
                      selectedFilterCategory.value != null ||
                      selectedGenderFilter.value != null ||
                      selectedEthnicityFilter.value != null ||
                      selectedIndustryFilter.value != null;
    
    // Clear all filter values explicitly
    selectedFilterTag.value = null;
    selectedFilterCategory.value = null;
    selectedGenderFilter.value = null;
    selectedEthnicityFilter.value = null;
    selectedIndustryFilter.value = null;
    
    // Always update to ensure UI reflects cleared state
    // This ensures filters are properly disposed
    _updateFilteredContacts();
  }
  
  // Method to clear a specific filter type
  void clearFilter(String filterType) {
    switch (filterType.toLowerCase()) {
      case 'tag':
      case 'profession':
        selectedFilterTag.value = null;
        break;
      case 'gender':
        selectedGenderFilter.value = null;
        break;
      case 'ethnicity':
        selectedEthnicityFilter.value = null;
        break;
      case 'industry':
        selectedIndustryFilter.value = null;
        break;
      case 'category':
        selectedFilterCategory.value = null;
        break;
    }
    _updateFilteredContacts();
  }

  void showFilterModal() {
    Get.bottomSheet(
      _FilterModal(),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  // Get unique filter tags from contacts (for backward compatibility) - Reactive
  List<String> getFilterTags() {
    final Set<String> tags = {};
    if (Get.isRegistered<ContactsController>()) {
      final contactsController = Get.find<ContactsController>();
      for (var contact in contactsController.contacts) {
        if (contact.profession.isNotEmpty) {
          tags.add(contact.profession);
        }
      }
    }
    return tags.toList()..sort();
  }
  
  // Get unique genders from contacts
  List<String> getAvailableGenders() {
    return ['Male', 'Female'];
  }
  
  // Get unique ethnicities from contacts
  List<String> getAvailableEthnicities() {
    final Set<String> ethnicities = {};
    if (Get.isRegistered<ContactsController>()) {
      final contactsController = Get.find<ContactsController>();
      for (var contact in contactsController.contacts) {
        if (contact.ethnicity.isNotEmpty) {
          ethnicities.add(contact.ethnicity);
        }
      }
    }
    return ethnicities.toList()..sort();
  }
  
  // Get unique industries from contacts
  List<String> getAvailableIndustries() {
    final Set<String> industries = {};
    if (Get.isRegistered<ContactsController>()) {
      final contactsController = Get.find<ContactsController>();
      for (var contact in contactsController.contacts) {
        // Industry is stored as first item in industries array
        if (contact.industry.isNotEmpty) {
          // Split by comma and get first industry
          final industryList = contact.industry.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          if (industryList.isNotEmpty) {
            industries.add(industryList.first);
          }
        }
      }
    }
    return industries.toList()..sort();
  }

  // Get filtered contacts - computed reactively
  List<Contact> getFilteredContacts() {
    // Get contacts from ContactsController (which fetches from Firebase in real-time)
    List<Contact> contacts = [];
    if (Get.isRegistered<ContactsController>()) {
      final contactsController = Get.find<ContactsController>();
      // Create a fresh copy of the contacts list - ensure we get all contacts
      // Access the RxList directly and convert to a regular list
      final allContactsFromController = contactsController.contacts;
      // Explicitly convert to list to ensure we get all items
      contacts = allContactsFromController.toList();
      print('SearchController: Retrieved ${allContactsFromController.length} contacts from ContactsController');
      print('SearchController: Contacts list type: ${allContactsFromController.runtimeType}');
    }
    
    // If no contacts, return empty list
    if (contacts.isEmpty) {
      print('SearchController: No contacts available');
      return [];
    }
    
    print('SearchController: Starting with ${contacts.length} contacts');
    print('SearchController: All contact names: ${contacts.map((c) => c.name).toList()}');
    
    // Get current filter values (explicitly check for null/empty)
    final filterTag = selectedFilterTag.value;
    final filterGender = selectedGenderFilter.value;
    final filterEthnicity = selectedEthnicityFilter.value;
    final filterIndustry = selectedIndustryFilter.value;
    final query = searchQuery.value.toLowerCase().trim();
    
    print('SearchController: Filters - Tag: $filterTag, Gender: $filterGender, Ethnicity: $filterEthnicity, Industry: $filterIndustry, Query: $query');

    // Filter by selected filter tag first (profession/category filter)
    // Only apply if filter is not null and not empty
    if (filterTag != null && filterTag.trim().isNotEmpty) {
      final tagFilter = filterTag.trim().toLowerCase();
      final beforeCount = contacts.length;
      contacts = contacts.where((contact) {
        final contactProfession = contact.profession.trim().toLowerCase();
        final matches = contactProfession == tagFilter;
        return matches;
      }).toList();
      print('SearchController: After tag filter ($tagFilter): $beforeCount -> ${contacts.length}');
    }

    // Filter by gender - only if filter is explicitly set
    if (filterGender != null && filterGender.trim().isNotEmpty) {
      final genderFilter = filterGender.trim().toLowerCase();
      final beforeCount = contacts.length;
      
      print('SearchController: Applying gender filter: "$genderFilter"');
      print('SearchController: Total contacts before gender filter: $beforeCount');
      
      // Show sample of contact genders before filtering
      if (contacts.isNotEmpty) {
        print('SearchController: Sample contact genders before filter:');
        for (var i = 0; i < contacts.length && i < 5; i++) {
          final contact = contacts[i];
          final contactGender = contact.gender.trim();
          print('  - ${contact.name}: gender="$contactGender" (lowercase: "${contactGender.toLowerCase()}")');
        }
      }
      
      final originalContacts = List<Contact>.from(contacts);
      contacts = contacts.where((contact) {
        final contactGender = contact.gender.trim();
        
        // Handle empty gender - skip contacts with empty gender when filtering
        if (contactGender.isEmpty) {
          return false;
        }
        
        // Case-insensitive exact match
        final contactGenderLower = contactGender.toLowerCase();
        final matches = contactGenderLower == genderFilter;
        
        return matches;
      }).toList();
      
      print('SearchController: After gender filter ($genderFilter): $beforeCount -> ${contacts.length}');
      if (contacts.isNotEmpty) {
        print('SearchController: Remaining contacts after gender filter:');
        for (var contact in contacts.take(5)) {
          print('  - ${contact.name}: gender="${contact.gender}"');
        }
      } else {
        print('SearchController: WARNING - No contacts match gender filter "$genderFilter"');
        print('SearchController: This might indicate a data issue. Check console logs above for contact genders.');
      }
    }
    
    // Filter by ethnicity - only if filter is explicitly set
    if (filterEthnicity != null && filterEthnicity.trim().isNotEmpty) {
      final ethnicityFilter = filterEthnicity.trim().toLowerCase();
      final beforeCount = contacts.length;
      contacts = contacts.where((contact) {
        final contactEthnicity = contact.ethnicity.trim().toLowerCase();
        return contactEthnicity == ethnicityFilter;
      }).toList();
      print('SearchController: After ethnicity filter ($ethnicityFilter): $beforeCount -> ${contacts.length}');
    }
    
    // Filter by industry - only if filter is explicitly set
    if (filterIndustry != null && filterIndustry.trim().isNotEmpty) {
      final industryFilter = filterIndustry.trim().toLowerCase();
      final beforeCount = contacts.length;
      contacts = contacts.where((contact) {
        if (contact.industry.isEmpty) return false;
        final industryList = contact.industry.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        if (industryList.isEmpty) return false;
        return industryList.any((industry) => 
          industry.trim().toLowerCase() == industryFilter
        );
      }).toList();
      print('SearchController: After industry filter ($industryFilter): $beforeCount -> ${contacts.length}');
    }

    // Filter by search query (applies to name, profession, location, company, etc.)
    // Only apply if query is not empty
    if (query.isNotEmpty) {
      final beforeCount = contacts.length;
      contacts = contacts.where((contact) {
        final nameMatch = contact.name.toLowerCase().contains(query);
        final professionMatch = contact.profession.toLowerCase().contains(query);
        final locationMatch = contact.location.toLowerCase().contains(query);
        final companyMatch = contact.company.toLowerCase().contains(query);
        final genderMatch = contact.gender.toLowerCase().contains(query);
        final characteristicsMatch = contact.characteristics.toLowerCase().contains(query);
        final industryMatch = contact.industry.toLowerCase().contains(query);
        
        return nameMatch || professionMatch || locationMatch || companyMatch || 
               genderMatch || characteristicsMatch || industryMatch;
      }).toList();
      print('SearchController: After search query ($query): $beforeCount -> ${contacts.length}');
    }

    // Sort by date added (newest first)
    contacts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    print('SearchController: Final filtered contacts: ${contacts.length}');
    if (contacts.isNotEmpty) {
      print('SearchController: All filtered contact names: ${contacts.map((c) => c.name).toList()}');
      print('SearchController: First contact: ${contacts.first.name}');
    } else {
      print('SearchController: WARNING - No contacts match the applied filters!');
      print('SearchController: Applied filters - Tag: $filterTag, Gender: $filterGender, Ethnicity: $filterEthnicity, Industry: $filterIndustry, Query: $query');
    }

    return contacts;
  }
}

// Filter Modal Widget - Uses GetX reactive state
class _FilterModal extends GetView<AppSearchController> {
  const _FilterModal();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppSearchController>();
    
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
          
          // Gender Section - Reactive
          Obx(() {
            final selectedCategory = controller.selectedFilterCategory.value;
            final selectedGender = controller.selectedGenderFilter.value;
            if (selectedCategory == 'Gender' || selectedGender != null) {
              return _buildFilterOptionsSection(
                controller,
                'Gender',
                controller.getAvailableGenders(),
                controller.selectedGenderFilter.value,
                (gender) => controller.setGenderFilter(gender),
              );
            } else {
              return _buildFilterOption(
                'Gender',
                selectedCategory == 'Gender',
                () => controller.setFilterCategory('Gender'),
              );
            }
          }),
          
          _buildDivider(),
          
          // Ethnicity Section - Reactive
          Obx(() {
            final selectedCategory = controller.selectedFilterCategory.value;
            final selectedEthnicity = controller.selectedEthnicityFilter.value;
            if (selectedCategory == 'Ethnicity' || selectedEthnicity != null) {
              return _buildFilterOptionsSection(
                controller,
                'Ethnicity',
                controller.getAvailableEthnicities(),
                controller.selectedEthnicityFilter.value,
                (ethnicity) => controller.setEthnicityFilter(ethnicity),
              );
            } else {
              return _buildFilterOption(
                'Ethnicity',
                selectedCategory == 'Ethnicity',
                () => controller.setFilterCategory('Ethnicity'),
              );
            }
          }),
          
          _buildDivider(),
          
          // Industry Section - Reactive
          Obx(() {
            final selectedCategory = controller.selectedFilterCategory.value;
            final selectedIndustry = controller.selectedIndustryFilter.value;
            if (selectedCategory == 'Industry' || selectedIndustry != null) {
              return _buildFilterOptionsSection(
                controller,
                'Industry',
                controller.getAvailableIndustries(),
                controller.selectedIndustryFilter.value,
                (industry) => controller.setIndustryFilter(industry),
              );
            } else {
              return _buildFilterOption(
                'Industry',
                selectedCategory == 'Industry',
                () => controller.setFilterCategory('Industry'),
              );
            }
          }),
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Clear All Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearAllFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 18,
                        fontFamily: 'PolySans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply Button
                Expanded(
                  flex: 2,
                  child: Container(
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
                      onPressed: () {
                        // Force update before closing - filters are already applied via ever() listeners
                        // Just close the modal, the filtered contacts will update automatically
                        Get.back();
                      },
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
              ],
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
  
  Widget _buildFilterOptionsSection(
    AppSearchController controller,
    String label,
    List<String> options,
    String? selectedValue,
    Function(String?) onSelected,
  ) {
    return Obx(() {
      // Watch contacts to update options reactively
      if (Get.isRegistered<ContactsController>()) {
        final contactsController = Get.find<ContactsController>();
        contactsController.contacts.length; // Watch contacts list
      }
      
      // Re-fetch options reactively
      List<String> reactiveOptions = options;
      if (label == 'Ethnicity') {
        reactiveOptions = controller.getAvailableEthnicities();
      } else if (label == 'Industry') {
        reactiveOptions = controller.getAvailableIndustries();
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: 'PolySans',
                  ),
                ),
                if (selectedValue != null)
                  GestureDetector(
                    onTap: () => onSelected(null),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                        fontFamily: 'PolySans',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (reactiveOptions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'No options available',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                  fontFamily: 'PolySans',
                ),
              ),
            )
          else
            ...reactiveOptions.map((option) {
              final isSelected = selectedValue == option;
              return InkWell(
                onTap: () => onSelected(isSelected ? null : option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: const TextStyle(
                          fontSize: 18,
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
            }).toList(),
        ],
      );
    });
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.borderLightGray,
      thickness: 1,
      height: 1,
    );
  }
}

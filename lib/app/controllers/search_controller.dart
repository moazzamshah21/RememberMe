import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rememberme/app/models/contact_model.dart';

class AppSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Multi-select industries
  final RxSet<String> selectedIndustries = <String>{}.obs;
  
  // Reactive search query
  final RxString searchQuery = ''.obs;
  
  // Reactive filtered contacts list
  final RxList<Contact> filteredContacts = <Contact>[].obs;
  
  // All contacts from Firebase
  final RxList<Contact> allContacts = <Contact>[].obs;
  
  StreamSubscription<QuerySnapshot>? _contactsSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Clear filters on init
    selectedIndustries.clear();
    searchQuery.value = '';
    
    // Set up Firebase listener
    _setupRealtimeListener();
    
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupRealtimeListener();
      } else {
        _contactsSubscription?.cancel();
        allContacts.clear();
        filteredContacts.clear();
      }
    });
    
    // Watch for search query changes - update immediately as user types
    // Previous results are cleared inside _updateFilteredContacts()
    ever(searchQuery, (_) {
      _updateFilteredContacts();
    });
    
    // Watch for industry changes - RxSet changes trigger this
    // Note: We also call _updateFilteredContacts() manually in toggle/clear methods for immediate feedback
    ever(selectedIndustries, (_) {
      _updateFilteredContacts();
    });
    
    // Watch for contacts changes from Firebase
    ever(allContacts, (_) {
      _updateFilteredContacts();
    });
    
    // Initial update after a short delay to ensure listeners are set up
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateFilteredContacts();
    });
  }

  void _setupRealtimeListener() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      allContacts.clear();
      filteredContacts.clear();
      return;
    }
    
    // Cancel existing subscription if any
    _contactsSubscription?.cancel();
    
    try {
      // Set up real-time listener
      Query baseQuery = _firestore
          .collection('contacts')
          .where('userId', isEqualTo: currentUser.uid);
      
      // Try with orderBy first
      Query orderedQuery = baseQuery.orderBy('createdAt', descending: true);
      
      _contactsSubscription = orderedQuery.snapshots().listen(
        (QuerySnapshot snapshot) {
          try {
            final contactsList = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _documentToContact(doc.id, data);
            }).toList();
            
            allContacts.value = contactsList;
            // _updateFilteredContacts() will be called by ever(allContacts) listener
            debugPrint('Search: Real-time update: ${contactsList.length} contacts');
          } catch (e) {
            debugPrint('Error processing snapshot: $e');
          }
        },
        onError: (error) {
          // If orderBy fails (index not created), try without orderBy
          final errorString = error.toString().toLowerCase();
          if (errorString.contains('index') || errorString.contains('requires an index')) {
            debugPrint('OrderBy failed, falling back to query without orderBy: $error');
            _contactsSubscription?.cancel();
            
            // Retry without orderBy
            _contactsSubscription = baseQuery.snapshots().listen(
              (QuerySnapshot snapshot) {
                try {
                  final contactsList = snapshot.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _documentToContact(doc.id, data);
                  }).toList();
                  
                  // Sort by date since we didn't use orderBy
                  contactsList.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
                  
                  allContacts.value = contactsList;
                  // _updateFilteredContacts() will be called by ever(allContacts) listener
                  debugPrint('Search: Real-time update (no orderBy): ${contactsList.length} contacts');
                } catch (e) {
                  debugPrint('Error processing snapshot: $e');
                }
              },
              onError: (error) {
                debugPrint('Error in real-time listener: $error');
              },
            );
          } else {
            debugPrint('Error in real-time listener: $error');
          }
        },
      );
    } catch (e) {
      debugPrint('Error setting up real-time listener: $e');
    }
  }
  
  void _updateFilteredContacts() {
    try {
      final selectedIndustriesList = selectedIndustries.toList();
      final query = searchQuery.value.trim();
      final queryLower = query.toLowerCase();
      
      // Start with a fresh copy of all contacts (no caching)
      var filtered = List<Contact>.from(allContacts);
      
      // Filter by selected industries (multi-select OR logic - show contacts matching ANY selected industry)
      if (selectedIndustriesList.isNotEmpty) {
        // Normalize selected industries to lowercase for comparison
        final normalizedSelected = selectedIndustriesList.map((s) => s.trim().toLowerCase()).toSet();
        
        filtered = filtered.where((contact) {
          // Skip contacts with empty industry
          if (contact.industry.trim().isEmpty) {
            return false;
          }
          
          // Get all industries from the contact and normalize them
          // Handle both comma-separated strings and potential list formats
          final industryList = contact.industry
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) => e.toLowerCase())
              .toList();
          
          if (industryList.isEmpty) {
            return false;
          }
          
          // Check if any of the contact's industries match any selected industry
          final matches = industryList.any((industry) {
            final normalizedIndustry = industry.trim().toLowerCase();
            return normalizedSelected.contains(normalizedIndustry);
          });
          
          // Debug: Log each contact being filtered
          if (selectedIndustriesList.length == 1) {
            debugPrint('Filter check: ${contact.name} | Industries: "${contact.industry}" | Split: $industryList | Selected: $normalizedSelected | Matches: $matches');
          }
          
          return matches;
        }).toList();
      }

      // Filter by name search - apply after industry filter
      if (queryLower.isNotEmpty) {
        filtered = filtered.where((contact) {
          return contact.name.toLowerCase().contains(queryLower);
        }).toList();
      }

      // Sort by date added (newest first)
      filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

      // Always assign fresh results - clear first, then add all to ensure proper reactivity
      filteredContacts.clear();
      filteredContacts.addAll(filtered);
      // Force refresh to trigger UI update
      filteredContacts.refresh();
      
      // Debug output when filtering
      if (selectedIndustriesList.isNotEmpty || queryLower.isNotEmpty) {
        debugPrint('=== FILTER RESULTS ===');
        debugPrint('Query: "$query"');
        debugPrint('Selected: ${selectedIndustriesList.join(", ")}');
        debugPrint('Total contacts: ${allContacts.length}');
        debugPrint('Filtered contacts: ${filtered.length}');
        debugPrint('All contacts details:');
        for (var contact in allContacts) {
          debugPrint('  - ${contact.name} | profession: "${contact.profession}" | industries: "${contact.industry}"');
        }
        if (filtered.isNotEmpty) {
          debugPrint('Filtered results:');
          for (var contact in filtered) {
            debugPrint('  - ${contact.name} | profession: "${contact.profession}" | industries: "${contact.industry}"');
          }
        } else {
          debugPrint('No contacts match the filter');
        }
        debugPrint('=====================');
      }
    } catch (e) {
      debugPrint('Error updating filtered contacts: $e');
      filteredContacts.clear();
    }
  }

  @override
  void onClose() {
    _contactsSubscription?.cancel();
    _authSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
  
  void refreshFilteredContacts() {
    _setupRealtimeListener();
  }

  void onScreenVisible() {
    // Force refresh when screen becomes visible
    _setupRealtimeListener();
  }
  
  void resetSearch() {
    searchController.clear();
    searchQuery.value = '';
    selectedIndustries.clear();
    selectedIndustries.refresh();
    // Clear filtered results immediately and show all contacts
    filteredContacts.clear();
    filteredContacts.assignAll(allContacts);
  }

  void toggleIndustry(String industry) {
    if (selectedIndustries.contains(industry)) {
      selectedIndustries.remove(industry);
    } else {
      selectedIndustries.add(industry);
    }
    // Force refresh and update
    selectedIndustries.refresh();
    _updateFilteredContacts();
  }

  void clearAllFilters() {
    selectedIndustries.clear();
    selectedIndustries.refresh();
    searchController.clear();
    searchQuery.value = '';
    // Clear filtered results immediately and show all contacts
    filteredContacts.clear();
    filteredContacts.assignAll(allContacts);
  }
  
  void clearSearchQuery() {
    searchController.clear();
    searchQuery.value = '';
    // Clear filtered results immediately
    filteredContacts.clear();
    // Show all contacts when search is cleared
    filteredContacts.assignAll(allContacts);
  }
  
  void updateSearchQuery(String value) {
    searchQuery.value = value;
    // _updateFilteredContacts() will be called by ever() listener
  }
  
  void clearIndustry(String industry) {
    selectedIndustries.remove(industry);
    selectedIndustries.refresh();
    _updateFilteredContacts();
  }

  // Get unique industries from contacts for tabs
  List<String> getAvailableIndustries() {
    final Set<String> industries = {};
    for (var contact in allContacts) {
      if (contact.industry.isNotEmpty) {
        // Split by comma and get all industries
        final industryList = contact.industry.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        for (var industry in industryList) {
          industries.add(industry);
        }
      }
    }
    return industries.toList()..sort();
  }
  
  Contact _documentToContact(String id, Map<String, dynamic> data) {
    // Convert Firestore data to Contact model
    final meetingDate = data['meetingDate'] as Timestamp?;
    final createdAt = data['createdAt'] as Timestamp?;
    
    // Determine time period based on meeting date or created date
    final dateToUse = meetingDate?.toDate() ?? createdAt?.toDate() ?? DateTime.now();
    final timePeriod = _getTimePeriod(dateToUse);
    
    // Get profession from industries (first industry or empty)
    final industries = data['industries'] as List<dynamic>? ?? [];
    final profession = industries.isNotEmpty ? industries.first.toString() : 'Professional';
    
    // Get location from meeting place
    final location = data['meetingPlace'] as String? ?? '';
    
    // Format characteristics
    final characteristicsList = data['characteristics'] as List<dynamic>? ?? [];
    final characteristics = characteristicsList.join(', ');
    
    // Format industries
    final industriesString = industries.join(', ');
    
    return Contact(
      id: id,
      timePeriod: timePeriod,
      profession: profession,
      ageRange: data['ageRange'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown',
      location: location,
      dateAdded: createdAt?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] as bool? ?? false,
      notes: data['description'] as String? ?? '',
      company: data['companyName'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      characteristics: characteristics,
      ethnicity: data['ethnicity'] as String? ?? '',
      industry: industriesString,
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
    );
  }
  
  String _getTimePeriod(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Recently Added';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays <= 7) {
      return 'Last 7 Days';
    } else if (difference.inDays <= 30) {
      return 'Last 30 Days';
    } else {
      return 'Older';
    }
  }
}

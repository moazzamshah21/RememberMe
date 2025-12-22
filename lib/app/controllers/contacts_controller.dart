import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rememberme/app/models/contact_model.dart';

class ContactsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<Contact> contacts = <Contact>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  StreamSubscription<QuerySnapshot>? _contactsSubscription;
  StreamSubscription<User?>? _authSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _setupRealtimeListener();
    
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupRealtimeListener();
      } else {
        _contactsSubscription?.cancel();
        contacts.clear();
      }
    });
  }
  
  @override
  void onClose() {
    _contactsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
  
  void _setupRealtimeListener() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      contacts.clear();
      return;
    }
    
    // Cancel existing subscription if any
    _contactsSubscription?.cancel();
    
    isLoading.value = true;
    errorMessage.value = '';
    
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
            
            contacts.value = contactsList;
            isLoading.value = false;
            print('Real-time update: ${contactsList.length} contacts for user ${currentUser.uid}');
          } catch (e) {
            print('Error processing snapshot: $e');
            errorMessage.value = 'Error processing contacts: ${e.toString()}';
            isLoading.value = false;
          }
        },
        onError: (error) {
          // If orderBy fails (index not created), try without orderBy
          final errorString = error.toString().toLowerCase();
          if (errorString.contains('index') || errorString.contains('requires an index')) {
            print('OrderBy failed, falling back to query without orderBy: $error');
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
                  
                  contacts.value = contactsList;
                  isLoading.value = false;
                  print('Real-time update (no orderBy): ${contactsList.length} contacts for user ${currentUser.uid}');
                } catch (e) {
                  print('Error processing snapshot: $e');
                  errorMessage.value = 'Error processing contacts: ${e.toString()}';
                  isLoading.value = false;
                }
              },
              onError: (error) {
                print('Error in real-time listener: $error');
                errorMessage.value = 'Failed to load contacts: ${error.toString()}';
                isLoading.value = false;
              },
            );
          } else {
            print('Error in real-time listener: $error');
            errorMessage.value = 'Failed to load contacts: ${error.toString()}';
            isLoading.value = false;
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to setup listener: ${e.toString()}';
      print('Error setting up real-time listener: $e');
    }
  }
  
  Future<void> loadContacts() async {
    // This method is kept for backward compatibility but now uses real-time listener
    _setupRealtimeListener();
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
  
  Map<String, List<Contact>> getContactsGroupedByTimePeriod() {
    final Map<String, List<Contact>> groupedContacts = {};
    
    for (var contact in contacts) {
      if (!groupedContacts.containsKey(contact.timePeriod)) {
        groupedContacts[contact.timePeriod] = [];
      }
      groupedContacts[contact.timePeriod]!.add(contact);
    }
    
    // Sort contacts within each group by date
    groupedContacts.forEach((key, value) {
      value.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    });
    
    return groupedContacts;
  }
  
  List<String> getTimePeriods() {
    const List<String> order = [
      'Recently Added',
      'Yesterday',
      'Last 7 Days',
      'Last 30 Days',
      'Older'
    ];
    
    final periods = contacts.map((contact) => contact.timePeriod).toSet();
    return order.where((period) => periods.contains(period)).toList();
  }
  
  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    try {
      // Update local contact immediately for instant UI feedback
      final contactIndex = contacts.indexWhere((c) => c.id == contactId);
      if (contactIndex != -1) {
        contacts[contactIndex].isFavorite = isFavorite;
        contacts.refresh(); // Trigger reactive updates
      }
      
      // Update in Firestore - real-time listener will automatically update the list
      await _firestore
          .collection('contacts')
          .doc(contactId)
          .update({
            'isFavorite': isFavorite,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      // The real-time listener will automatically update contacts list,
      // which will trigger FavoritesController to update via ever()
    } catch (e) {
      print('Error updating favorite: $e');
      
      // Revert local change on error
      final contactIndex = contacts.indexWhere((c) => c.id == contactId);
      if (contactIndex != -1) {
        contacts[contactIndex].isFavorite = !isFavorite;
        contacts.refresh();
      }
      
      Get.snackbar(
        'Error',
        'Failed to update favorite status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> refreshContacts() async {
    // Real-time listener will automatically update, but we can trigger a refresh
    _setupRealtimeListener();
  }
}

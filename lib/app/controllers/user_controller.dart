import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxString userName = 'User'.obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserName();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadUserName();
      } else {
        userName.value = 'User';
      }
    });
  }
  
  Future<void> loadUserName() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      userName.value = 'User';
      return;
    }
    
    try {
      isLoading.value = true;
      
      // First try to get from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        final name = data?['name'] as String? ?? 
                    data?['displayName'] as String? ?? 
                    currentUser.displayName ?? 
                    currentUser.email?.split('@')[0] ?? 
                    'User';
        userName.value = name;
      } else {
        // Fallback to Firebase Auth displayName or email
        userName.value = currentUser.displayName ?? 
                        currentUser.email?.split('@')[0] ?? 
                        'User';
      }
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      // Fallback to Firebase Auth displayName or email
      final currentUser = _auth.currentUser;
      userName.value = currentUser?.displayName ?? 
                      currentUser?.email?.split('@')[0] ?? 
                      'User';
      print('Error loading user name: $e');
    }
  }
  
  String getDisplayName() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 'User';
    
    // Return the first name if full name exists, otherwise return the full name or email
    final name = userName.value;
    if (name != 'User' && name.contains(' ')) {
      return name.split(' ')[0];
    }
    return name;
  }
}

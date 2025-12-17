import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/controllers/favorites_controller.dart';
import 'package:rememberme/app/models/contact_model.dart';

class ContactDetailController extends GetxController {
  Contact? _contact;
  final RxBool isNotesExpanded = false.obs;
  final RxInt currentImageIndex = 0.obs;
  late final PageController pageController;
  
  final List<String> profileImages = [
    'assets/images/profilepic.png',
    'assets/images/profilepic.png',
    'assets/images/profilepic.png',
  ];

  Contact? get contact => _contact;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.98);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void setContact(Contact contactData) {
    _contact = contactData;
    update();
  }

  void toggleNotesExpansion() {
    isNotesExpanded.value = !isNotesExpanded.value;
  }

  void changeImageIndex(int index) {
    currentImageIndex.value = index;
  }

  void toggleFavorite() {
    if (contact != null) {
      contact!.isFavorite = !contact!.isFavorite;
      update();
      // Notify FavoritesController to refresh the list
      if (Get.isRegistered<FavoritesController>()) {
        Get.find<FavoritesController>().loadFavoriteContacts();
      }
    }
  }
}

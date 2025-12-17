import 'package:get/get.dart';
import 'package:rememberme/app/data/contacts_data.dart';
import 'package:rememberme/app/models/contact_model.dart';

class FavoritesController extends GetxController {
  final RxList<Contact> favoriteContacts = <Contact>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavoriteContacts();
  }

  void loadFavoriteContacts() {
    final newFavorites = ContactsData.contacts
        .where((contact) => contact.isFavorite)
        .toList();
    // Sort by date added (newest first)
    newFavorites.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    favoriteContacts.value = newFavorites;
  }

  Future<void> refreshFavorites() async {
    loadFavoriteContacts();
  }
}

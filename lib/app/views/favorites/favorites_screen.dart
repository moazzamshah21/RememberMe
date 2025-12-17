import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/favorites_controller.dart';
import 'package:rememberme/widgets/customAppbar.dart';
import 'package:rememberme/widgets/saved_contact_item.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh favorites when screen is built (when user navigates to this tab)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavoriteContacts();
    });
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomAppBar(
              appBarContent: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (commented out like in search screen)
                      // GestureDetector(
                      //   onTap: () {
                      //     if (Navigator.canPop(context)) {
                      //       Navigator.pop(context);
                      //     }
                      //   },
                      //   child: Container(
                      //     width: 40,
                      //     height: 40,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Center(
                      //       child: Icon(
                      //         Icons.arrow_back,
                      //         color: Colors.grey[800],
                      //         size: 20,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Title
                      Expanded(
                        child: Center(
                          child: Text(
                            'Favorites',
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontSize: 32,
                              fontFamily: 'PolySans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Spacer to balance the layout (no filter icon needed for favorites)
                      SizedBox(width: 50),
                    ],
                  ),
                ),
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          ];
        },
        body: Obx(() => Container(
          color: AppColors.white,
          child: controller.favoriteContacts.isEmpty
              ? SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: AppColors.textGray,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGray,
                                fontFamily: 'PolySans',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap the heart icon on any contact\nto add it to favorites',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGray,
                                fontFamily: 'PolySans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.refreshFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: controller.favoriteContacts.length,
                    itemBuilder: (context, index) {
                      return SavedContactItem(contact: controller.favoriteContacts[index]);
                    },
                  ),
                ),
        )),
      ),
    );
  }
}

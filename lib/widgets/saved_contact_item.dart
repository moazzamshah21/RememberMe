// // widgets/saved_contact_item.dart
// import 'package:flutter/material.dart';
// import 'package:rememberme/app/models/contact_model.dart';

// class SavedContactItem extends StatefulWidget {
//   final Contact contact;
  
//   const SavedContactItem({
//     super.key,
//     required this.contact,
//   });

//   @override
//   State<SavedContactItem> createState() => _SavedContactItemState();
// }

// class _SavedContactItemState extends State<SavedContactItem> {
//   late Contact contact;

//   @override
//   void initState() {
//     super.initState();
//     contact = widget.contact;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.09),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile Picture with Favorite Icon
//           Stack(
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: const Color(0xFFE0E0E0),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.asset(
//                     'assets/images/profilepic.png',
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: const Color(0xFF025786),
//                         child: Center(
//                           child: Text(
//                             contact.name.split(' ').map((n) => n[0]).join(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               // Favorite Icon positioned on top-right corner of profile pic
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       contact.isFavorite = !contact.isFavorite;
//                     });
//                   },
//                   child: Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 3,
//                           offset: const Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Icon(
//                         contact.isFavorite ? Icons.favorite : Icons.favorite_border,
//                         color: contact.isFavorite ? Colors.red : const Color(0xFF666666),
//                         size: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(width: 12),
          
//           // Contact Info
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Profession and Age Row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         contact.profession,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF525252),
//                           fontFamily: 'PolySans',
//                         ),
//                       ),
//                       Text(
//                         contact.ageRange,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF4B4F63),
//                           fontFamily: 'PolySans',
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
                  
//                   // Name
//                   Text(
//                     contact.name,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                       fontFamily: 'PolySans',
//                     ),
//                   ),
//                   const SizedBox(height: 6),
                  
//                   // Location
//                   Text(
//                     contact.location,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                       color: Color(0xFF373B51),
//                       fontFamily: 'PolySans',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// widgets/saved_contact_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/favorites_controller.dart';
import 'package:rememberme/app/models/contact_model.dart';
import 'package:rememberme/app/views/contact/contact_detail_screen.dart';

class SavedContactItem extends StatefulWidget {
  final Contact contact;
  
  const SavedContactItem({
    super.key,
    required this.contact,
  });

  @override
  State<SavedContactItem> createState() => _SavedContactItemState();
}

class _SavedContactItemState extends State<SavedContactItem> {
  late Contact contact;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactDetailScreen(contact: contact),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlackLight,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture with Favorite Icon
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.lightGray,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/profilepic.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF025786),
                          child: Center(
                            child: Text(
                              contact.name.split(' ').map((n) => n[0]).join(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Favorite Icon positioned on top-right corner of profile pic
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        contact.isFavorite = !contact.isFavorite;
                      });
                      // Notify FavoritesController to refresh the list
                      if (Get.isRegistered<FavoritesController>()) {
                        Get.find<FavoritesController>().loadFavoriteContacts();
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowBlackMedium,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: contact.isFavorite ? AppColors.favoriteRed : AppColors.favoriteGray,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Contact Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profession and Age Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contact.profession,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                          fontFamily: 'PolySans',
                        ),
                      ),
                      Row(
                        children: [
                          if (contact.gender.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Image.asset(
                                contact.gender.toLowerCase() == 'male'
                                    ? 'assets/images/male.png'
                                    : 'assets/images/female.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox.shrink();
                                },
                              ),
                            ),
                          Text(
                            contact.ageRange,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray,
                              fontFamily: 'PolySans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Name
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'PolySans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Location
                  Text(
                    contact.location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGray,
                      fontFamily: 'PolySans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
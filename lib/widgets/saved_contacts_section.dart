// // widgets/saved_contacts_section.dart
// import 'package:flutter/material.dart';
// import 'package:rememberme/app/data/contacts_data.dart';
// import 'package:rememberme/widgets/saved_contact_item.dart';

// class SavedContactsSection extends StatelessWidget {
//   const SavedContactsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Get contacts grouped by time period
//     final groupedContacts = ContactsData.getContactsGroupedByTimePeriod();
    
//     // Get all time periods in order
//     final timePeriods = ContactsData.getTimePeriods();
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Generate sections for each time period
//         for (var timePeriod in timePeriods) ...[
//           // Section Header
//           Padding(
//             padding: EdgeInsets.only(bottom: 12, top: timePeriod == timePeriods.first ? 0 : 24),
//             child: Text(
//               timePeriod,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF025786),
//                 fontFamily: 'PolySans',
//               ),
//             ),
//           ),
          
//           // Contact Items for this time period
//           if (groupedContacts.containsKey(timePeriod) && 
//               groupedContacts[timePeriod]!.isNotEmpty)
//             ...groupedContacts[timePeriod]!.map((contact) => 
//               SavedContactItem(contact: contact)
//             ).toList(),
          
//           // Empty state if no contacts for this time period
//           if (!groupedContacts.containsKey(timePeriod) || 
//               groupedContacts[timePeriod]!.isEmpty)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 40),
//               decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.white,
//               ),
//               child: Center(
//                 child: Text(
//                   "No contacts saved in the $timePeriod",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: const Color(0xFF999999),
//                     fontFamily: 'PolySans',
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ],
//     );
//   }
// }

// widgets/saved_contacts_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/contacts_controller.dart';
import 'package:rememberme/widgets/saved_contact_item.dart';

class SavedContactsSection extends StatelessWidget {
  const SavedContactsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Use find if exists, otherwise put - ensures we use the same instance as HomeScreen
    final ContactsController controller = Get.isRegistered<ContactsController>()
        ? Get.find<ContactsController>()
        : Get.put(ContactsController());
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadContacts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      
      if (controller.contacts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'No contacts found. Add your first contact!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGray,
                fontFamily: 'PolySans',
              ),
            ),
          ),
        );
      }
      
      // Get contacts grouped by time period
      final groupedContacts = controller.getContactsGroupedByTimePeriod();
      
      // Only show sections that have contacts
      final timePeriods = controller.getTimePeriods()
          .where((period) => groupedContacts.containsKey(period) && groupedContacts[period]!.isNotEmpty)
          .toList();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generate sections for each time period that has contacts
          for (var timePeriod in timePeriods) ...[
            // Section Header
            Padding(
              padding: EdgeInsets.only(
                bottom: 12,
                top: timePeriod == timePeriods.first ? 0 : 24,
              ),
              child: Text(
                timePeriod,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF025786),
                  fontFamily: 'PolySans',
                ),
              ),
            ),
            
            // Contact Items for this time period
            ...groupedContacts[timePeriod]!.map((contact) => 
              SavedContactItem(contact: contact)
            ).toList(),
          ],
        ],
      );
    });
  }
}
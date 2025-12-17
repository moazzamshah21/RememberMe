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
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/data/contacts_data.dart';
import 'package:rememberme/widgets/saved_contact_item.dart';

class SavedContactsSection extends StatelessWidget {
  const SavedContactsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Get contacts grouped by time period
    final groupedContacts = ContactsData.getContactsGroupedByTimePeriod();
    
    // Only show sections that have contacts (except "Recently Added" and "Yesterday" which are in the screenshot)
    final timePeriods = ContactsData.getTimePeriods()
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
  }
}
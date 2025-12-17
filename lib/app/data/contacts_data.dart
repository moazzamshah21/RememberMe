// // // data/contacts_data.dart

// // import 'package:rememberme/app/models/contact_model.dart';

// // class ContactsData {
// //   static final List<Contact> contacts = [
// //     Contact(
// //       id: '1',
// //       timePeriod: 'Recently Added',
// //       profession: 'Neurologist',
// //       ageRange: '30-40',
// //       name: 'Dr. Kalvin Mathew',
// //       location: 'Paris, St. Joseph Hospital.',
// //       dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
// //     ),
// //     Contact(
// //       id: '2',
// //       timePeriod: 'Recently Added',
// //       profession: 'Gym Trainer',
// //       ageRange: '20-30',
// //       name: 'Dr. Kalvin Mathew',
// //       location: 'Brazil, Danza Kaduro Gym.',
// //       dateAdded: DateTime.now().subtract(const Duration(hours: 4)),
// //     ),
// //     Contact(
// //       id: '3',
// //       timePeriod: 'Yesterday',
// //       profession: 'Neurologist',
// //       ageRange: '30-50',
// //       name: 'Dr. Kalvin Mathew',
// //       location: 'Paris, St. Joseph Hospital.',
// //       dateAdded: DateTime.now().subtract(const Duration(days: 1)),
// //     ),
// //     Contact(
// //       id: '4',
// //       timePeriod: 'Last 7 Days',
// //       profession: 'Cardiologist',
// //       ageRange: '40-50',
// //       name: 'Dr. Sarah Johnson',
// //       location: 'London, Royal Hospital.',
// //       dateAdded: DateTime.now().subtract(const Duration(days: 3)),
// //     ),
// //     Contact(
// //       id: '5',
// //       timePeriod: 'Last 7 Days',
// //       profession: 'Dentist',
// //       ageRange: '35-45',
// //       name: 'Dr. Michael Chen',
// //       location: 'New York, Dental Care Center.',
// //       dateAdded: DateTime.now().subtract(const Duration(days: 5)),
// //     ),
// //   ];

// //   // Method to get contacts grouped by time period
// //   static Map<String, List<Contact>> getContactsGroupedByTimePeriod() {
// //     final Map<String, List<Contact>> groupedContacts = {};
    
// //     // Sort contacts by date (newest first)
// //     contacts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
// //     // Group by time period
// //     for (var contact in contacts) {
// //       if (!groupedContacts.containsKey(contact.timePeriod)) {
// //         groupedContacts[contact.timePeriod] = [];
// //       }
// //       groupedContacts[contact.timePeriod]!.add(contact);
// //     }
    
// //     // Define the order of sections
// //     const List<String> sectionOrder = [
// //       'Recently Added',
// //       'Yesterday',
// //       'Last 7 Days',
// //     ];
    
// //     // Reorder the map according to section order
// //     final Map<String, List<Contact>> orderedMap = {};
// //     for (var section in sectionOrder) {
// //       if (groupedContacts.containsKey(section)) {
// //         orderedMap[section] = groupedContacts[section]!;
// //       }
// //     }
    
// //     return orderedMap;
// //   }

// //   // Method to get all time periods (sections)
// //   static List<String> getTimePeriods() {
// //     final periods = contacts.map((contact) => contact.timePeriod).toSet();
// //     // Define the order
// //     const List<String> order = ['Recently Added', 'Yesterday', 'Last 7 Days'];
// //     return order.where((period) => periods.contains(period)).toList();
// //   }

// //   // Method to get contacts for a specific time period
// //   static List<Contact> getContactsByTimePeriod(String timePeriod) {
// //     return contacts
// //         .where((contact) => contact.timePeriod == timePeriod)
// //         .toList();
// //   }
// // }

// // app/data/contacts_data.dart
// import 'package:rememberme/app/models/contact_model.dart';

// class ContactsData {
//   static final List<Contact> contacts = [
//     Contact(
//       id: '1',
//       timePeriod: 'Recently Added',
//       profession: 'Neurologist',
//       ageRange: '30-40',
//       name: 'Dr. Kalvin Mathew',
//       location: 'Paris, St. Joseph Hospital.',
//       dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
//     ),
//     Contact(
//       id: '2',
//       timePeriod: 'Recently Added',
//       profession: 'Gym Trainer',
//       ageRange: '20-30',
//       name: 'Dr. Kalvin Mathew',
//       location: 'Brazil, Danza Kaduro Gym.',
//       dateAdded: DateTime.now().subtract(const Duration(hours: 4)),
//     ),
//     Contact(
//       id: '3',
//       timePeriod: 'Yesterday',
//       profession: 'Neurologist',
//       ageRange: '30-50',
//       name: 'Dr. Kalvin Mathew',
//       location: 'Paris, St. Joseph Hospital.',
//       dateAdded: DateTime.now().subtract(const Duration(days: 1)),
//     ),
//   ];

//   // Method to get contacts grouped by time period
//   static Map<String, List<Contact>> getContactsGroupedByTimePeriod() {
//     final Map<String, List<Contact>> groupedContacts = {};
    
//     // Sort contacts by date (newest first)
//     contacts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
//     // Group by time period
//     for (var contact in contacts) {
//       if (!groupedContacts.containsKey(contact.timePeriod)) {
//         groupedContacts[contact.timePeriod] = [];
//       }
//       groupedContacts[contact.timePeriod]!.add(contact);
//     }
    
//     // Define the order of sections
//     const List<String> sectionOrder = [
//       'Recently Added',
//       'Yesterday',
//       'Last 7 Days',
//     ];
    
//     // Reorder the map according to section order
//     final Map<String, List<Contact>> orderedMap = {};
//     for (var section in sectionOrder) {
//       if (groupedContacts.containsKey(section)) {
//         orderedMap[section] = groupedContacts[section]!;
//       }
//     }
    
//     return orderedMap;
//   }

//   // Method to get all time periods (sections)
//   static List<String> getTimePeriods() {
//     final periods = contacts.map((contact) => contact.timePeriod).toSet();
//     // Define the order
//     const List<String> order = ['Recently Added', 'Yesterday', 'Last 7 Days'];
//     return order.where((period) => periods.contains(period)).toList();
//   }

//   // Method to get contacts for a specific time period
//   static List<Contact> getContactsByTimePeriod(String timePeriod) {
//     return contacts
//         .where((contact) => contact.timePeriod == timePeriod)
//         .toList();
//   }
// }

// app/data/contacts_data.dart
import 'package:rememberme/app/models/contact_model.dart';

class ContactsData {
  static final List<Contact> contacts = [
    Contact(
      id: '1',
      timePeriod: 'Recently Added',
      profession: 'Neurologist',
      ageRange: '30-40',
      name: 'Dr. Kalvin Mathew',
      location: 'Paris, St. Joseph Hospital.',
      dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
      notes: "Specializes in neurological disorders. Very professional and attentive tofffff details. Has extensive experience in treating migraines and epilepsy. Specializes in neurological disorders. Very professional and attentive to details. Has extensive experience in treating migraines and epilepsy.",
      company: "St. Joseph Hospital",
      gender: "Male",
      characteristics: "Ambitious, Humble, Honest, Skillfull",
      ethnicity: "White Catholic",
      industry: "Health Care",
    ),
    Contact(
      id: '2',
      timePeriod: 'Recently Added',
      profession: 'Gym Trainer',
      ageRange: '20-30',
      name: 'Dr. Kalvin Mathew',
      location: 'Brazil, Danza Kaduro Gym.',
      dateAdded: DateTime.now().subtract(const Duration(hours: 4)),
      notes: "Expert in fitness training and nutrition. Helps clients achieve their fitness goals through customized workout plans.",
      company: "Danza Kaduro Gym",
      gender: "Male",
      characteristics: "Energetic, Motivational, Patient, Knowledgeable",
      ethnicity: "Latino",
      industry: "Fitness & Wellness",
    ),
    Contact(
      id: '3',
      timePeriod: 'Yesterday',
      profession: 'Neurologist',
      ageRange: '30-50',
      name: 'Dr. Kalvin Mathew',
      location: 'Paris, St. Joseph Hospital.',
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      notes: "Senior neurologist with 15+ years of experience. Published several research papers on neurodegenerative diseases.",
      company: "St. Joseph Hospital",
      gender: "Male",
      characteristics: "Experienced, Knowledgeable, Compassionate, Dedicated",
      ethnicity: "White Catholic",
      industry: "Health Care",
    ),
  ];

  // Rest of the methods remain the same...
  static Map<String, List<Contact>> getContactsGroupedByTimePeriod() {
    final Map<String, List<Contact>> groupedContacts = {};
    
    contacts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    for (var contact in contacts) {
      if (!groupedContacts.containsKey(contact.timePeriod)) {
        groupedContacts[contact.timePeriod] = [];
      }
      groupedContacts[contact.timePeriod]!.add(contact);
    }
    
    const List<String> sectionOrder = [
      'Recently Added',
      'Yesterday',
      'Last 7 Days',
    ];
    
    final Map<String, List<Contact>> orderedMap = {};
    for (var section in sectionOrder) {
      if (groupedContacts.containsKey(section)) {
        orderedMap[section] = groupedContacts[section]!;
      }
    }
    
    return orderedMap;
  }

  static List<String> getTimePeriods() {
    final periods = contacts.map((contact) => contact.timePeriod).toSet();
    const List<String> order = ['Recently Added', 'Yesterday', 'Last 7 Days'];
    return order.where((period) => periods.contains(period)).toList();
  }

  static List<Contact> getContactsByTimePeriod(String timePeriod) {
    return contacts
        .where((contact) => contact.timePeriod == timePeriod)
        .toList();
  }
}
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
      dateAdded: DateTime.now().subtract(const Duration(days:1)),
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
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
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
    Contact(
      id: '3',
      timePeriod: 'Yesterday',
      profession: 'Neurologist',
      ageRange: '30-50',
      name: 'Dr. Kara Mathew',
      location: 'London, St. Joseph Hospital.',
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      notes: "Senior neurologist with 15+ years of experience. Published several research papers on neurodegenerative diseases.",
      company: "St. Joseph Hospital",
      gender: "Female",
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
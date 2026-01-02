// app/models/contact_model.dart
class Contact {
  final String id;
  final String timePeriod;
  final String profession;
  String ageRange;
  final String name;
  final String location;
  final DateTime dateAdded;
  final DateTime updatedAt;
  bool isFavorite;
  String notes;
  String company;
  String gender;
  String characteristics;
  String ethnicity;
  String industry;
  String profileImageUrl;
  List<String> imageUrls;

  Contact({
    required this.id,
    required this.timePeriod,
    required this.profession,
    required this.ageRange,
    required this.name,
    required this.location,
    required this.dateAdded,
    required this.updatedAt,
    this.isFavorite = false,
    this.notes = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.",
    this.company = "Lorem Ipsum . Pvt. Ltd",
    this.gender = "Male",
    this.characteristics = "Ambitious, Humble, Honest, Skillfull",
    this.ethnicity = "White Catholic",
    this.industry = "Health Care",
    this.profileImageUrl = "",
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];
}
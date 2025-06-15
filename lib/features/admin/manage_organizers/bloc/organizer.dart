class Organizer {
  Organizer({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      displayName: json['displayName'] as String,
    );
  }
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
}

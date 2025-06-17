class Aboutme {
  Aboutme({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.isVerified,
    required this.creationDate,
  });

  factory Aboutme.fromJson(Map<String, dynamic> json) {
    return Aboutme(
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      displayName: json['displayName'] as String,
      isVerified: json['isVerified'] as bool,
      creationDate: DateTime.parse(json['creationDate'] as String),
    );
  }
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final bool isVerified;
  final DateTime creationDate;
}

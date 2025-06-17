class CustomerAboutme {
  CustomerAboutme({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.creationDate,
  });

  factory CustomerAboutme.fromJson(Map<String, dynamic> json) {
    return CustomerAboutme(
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
    );
  }
  final String email;
  final String firstName;
  final String lastName;
  final DateTime creationDate;
}

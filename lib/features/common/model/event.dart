class Event {
  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.image,
  });

  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  final String image;
}

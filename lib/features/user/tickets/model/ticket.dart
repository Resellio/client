class Ticket {
  const Ticket({
    required this.ticketId,
    required this.eventName,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.used,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'] as String,
      eventName: json['eventName'] as String,
      eventStartDate: DateTime.parse(json['eventStartDate'] as String),
      eventEndDate: DateTime.parse(json['eventEndDate'] as String),
      used: json['used'] as bool,
    );
  }

  final String ticketId;
  final String eventName;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final bool used;

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'eventName': eventName,
      'eventStartDate': eventStartDate.toIso8601String(),
      'eventEndDate': eventEndDate.toIso8601String(),
      'used': used,
    };
  }
}

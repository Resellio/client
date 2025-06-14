import 'package:resellio/features/common/model/event.dart';

class OrganizerEventDetails {
  const OrganizerEventDetails({
    required this.event,
    required this.revenue,
    required this.sold,
  });

  factory OrganizerEventDetails.fromJson(Map<String, dynamic> data) {
    return OrganizerEventDetails(
      event: Event.fromJson(data['eventDetails'] as Map<String, dynamic>),
      revenue: data['revenue'] as double,
      sold: data['soldTicketsCount'] as int,
    );
  }

  final Event event;
  final double revenue;
  final int sold;
}

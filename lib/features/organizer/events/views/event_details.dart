import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrganizerEventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData = const {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "Summer Music Festival 2025",
    "description":
        "Join us for an unforgettable evening of live music featuring top artists from around the world. Experience amazing performances, delicious food, and great company under the stars. This outdoor festival promises to be the highlight of your summer with multiple stages, art installations, and interactive experiences for all ages.",
    "startDate": "2025-07-15T18:00:00.000Z",
    "endDate": "2025-07-15T23:30:00.000Z",
    "minimumAge": 16,
    "categories": [
      {"name": "Music"},
      {"name": "Festival"},
      {"name": "Outdoor"},
      {"name": "Entertainment"}
    ],
    "ticketTypes": [
      {
        "id": "ticket-1",
        "description": "Early Bird General Admission",
        "price": 75,
        "currency": "USD",
        "availableFrom": "2025-06-01T10:00:00.000Z",
        "amountAvailable": 500
      },
      {
        "id": "ticket-2",
        "description": "VIP Experience Package",
        "price": 150,
        "currency": "USD",
        "availableFrom": "2025-06-01T10:00:00.000Z",
        "amountAvailable": 100
      },
      {
        "id": "ticket-3",
        "description": "Student Discount",
        "price": 45,
        "currency": "USD",
        "availableFrom": "2025-06-15T10:00:00.000Z",
        "amountAvailable": 200
      }
    ],
    "status": 1, // Published
    "address": {
      "country": "United States",
      "city": "Los Angeles",
      "postalCode": "90210",
      "street": "Sunset Boulevard",
      "houseNumber": 1234,
      "flatNumber": 0
    }
  };
  final String eventId;

  const OrganizerEventDetailsScreen({Key? key, required this.eventId})
      : super(key: key);

  @override
  State<OrganizerEventDetailsScreen> createState() =>
      _OrganizerEventDetailsScreenState();
}

class _OrganizerEventDetailsScreenState
    extends State<OrganizerEventDetailsScreen> {
  late Map<String, dynamic> event;

  @override
  void initState() {
    super.initState();
    event = widget.eventData;
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String getEventStatusText(int status) {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Published';
      case 2:
        return 'Cancelled';
      case 3:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
              'Are you sure you want to delete this event? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent() {
    // TODO: Implement delete API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final address = event['address'] as Map<String, dynamic>?;
    final categories = event['categories'] as List<dynamic>?;
    final ticketTypes = event['ticketTypes'] as List<dynamic>?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event['name'] as String ?? 'Unnamed Event',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: getStatusColor(event['status'] as int ?? 0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            getEventStatusText(event['status'] as int ?? 0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event['description'] as String ??
                          'No description available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Event Statistics Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Revenue', '\$2,340',
                              Icons.attach_money, Colors.purple),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Tickets Sold', '89',
                              Icons.confirmation_number, Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Event Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.calendar_today, 'Start Date',
                        formatDate(event['startDate'] as String ?? '')),
                    _buildInfoRow(Icons.calendar_today, 'End Date',
                        formatDate(event['endDate'] as String ?? '')),
                    _buildInfoRow(Icons.person, 'Minimum Age',
                        '${event['minimumAge'] ?? 0} years'),
                    if (categories != null && categories.isNotEmpty)
                      _buildCategoriesRow(categories),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address Card
            if (address != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${address['street'] ?? ''} ${address['houseNumber'] ?? ''}${address['flatNumber'] != null && address['flatNumber'] != 0 ? '/${address['flatNumber']}' : ''}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${address['postalCode'] ?? ''} ${address['city'] ?? ''}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  address['country'] as String ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Ticket Types Card
            if (ticketTypes != null && ticketTypes.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket Types',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...ticketTypes
                          .map((ticket) => _buildTicketTypeCard(
                              ticket as Map<String, dynamic>))
                          .toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(List<dynamic> categories) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.category, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          const Text(
            'Categories: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categories.map((category) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category['name'] as String ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTypeCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket['description'] as String ?? 'Ticket',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${ticket['price'] ?? 0} ${ticket['currency'] ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available: ${ticket['amountAvailable'] ?? 0}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (ticket['availableFrom'] != null)
                Text(
                  'From: ${formatDate(ticket['availableFrom'] as String)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

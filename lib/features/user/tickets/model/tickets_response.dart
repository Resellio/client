import 'package:resellio/features/user/tickets/model/pagination_details.dart';
import 'package:resellio/features/user/tickets/model/ticket.dart';

class TicketsResponse {
  const TicketsResponse({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.paginationDetails,
  });

  factory TicketsResponse.fromJson(Map<String, dynamic> json) {
    return TicketsResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => Ticket.fromJson(item as Map<String, dynamic>))
          .toList(),
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      paginationDetails: PaginationDetails.fromJson(
        json['paginationDetails'] as Map<String, dynamic>,
      ),
    );
  }

  final List<Ticket> data;
  final int pageNumber;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final PaginationDetails paginationDetails;

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((ticket) => ticket.toJson()).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
      'paginationDetails': paginationDetails.toJson(),
    };
  }
}

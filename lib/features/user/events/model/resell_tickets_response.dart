import 'package:resellio/features/user/events/model/resell_ticket.dart';
import 'package:resellio/features/user/tickets/model/pagination_details.dart';

class ResellTicketsResponse {
  const ResellTicketsResponse({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.paginationDetails,
  });

  factory ResellTicketsResponse.fromJson(Map<String, dynamic> json) {
    return ResellTicketsResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => ResellTicket.fromJson(item as Map<String, dynamic>))
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

  final List<ResellTicket> data;
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

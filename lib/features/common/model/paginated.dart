import 'package:equatable/equatable.dart';

class PaginatedData<T> extends Equatable {
  const PaginatedData({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.paginationDetails,
  });

  factory PaginatedData.fromJson(
      Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return PaginatedData<T>(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      paginationDetails: PaginationDetails.fromJson(
        json['paginationDetails'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final PaginationDetails paginationDetails;

  @override
  List<Object?> get props => [
        data,
        pageNumber,
        pageSize,
        hasNextPage,
        hasPreviousPage,
        paginationDetails,
      ];
}

class PaginationDetails extends Equatable {
  const PaginationDetails({
    required this.maxPageNumber,
    required this.allElementsCount,
  });

  factory PaginationDetails.fromJson(Map<String, dynamic> json) {
    return PaginationDetails(
      maxPageNumber: json['maxPageNumber'] as int? ?? 0,
      allElementsCount: json['allElementsCount'] as int? ?? 0,
    );
  }

  final int maxPageNumber;
  final int allElementsCount;

  @override
  List<Object?> get props => [maxPageNumber, allElementsCount];
}

class PaginationDetails {
  const PaginationDetails({
    required this.maxPageNumber,
    required this.allElementsCount,
  });

  factory PaginationDetails.fromJson(Map<String, dynamic> json) {
    return PaginationDetails(
      maxPageNumber: json['maxPageNumber'] as int,
      allElementsCount: json['allElementsCount'] as int,
    );
  }

  final int maxPageNumber;
  final int allElementsCount;

  Map<String, dynamic> toJson() {
    return {
      'maxPageNumber': maxPageNumber,
      'allElementsCount': allElementsCount,
    };
  }
}

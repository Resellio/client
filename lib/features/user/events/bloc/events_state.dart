import 'package:equatable/equatable.dart';

enum EventsStatus { initial, loading, loadingMore, success, failure }

class EventsState extends Equatable {
  final EventsStatus status;
  final List<GetEventResponseDto> events;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;

  const EventsState({
    this.status = EventsStatus.initial,
    this.events = const <GetEventResponseDto>[],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.errorMessage,
  });

  EventsState copyWith({
    EventsStatus? status,
    List<GetEventResponseDto>? events,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, events, hasReachedMax, currentPage, errorMessage];
}

class PaginatedData<T> extends Equatable {
  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final PaginationDetails paginationDetails;

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
  final int maxPageNumber;
  final int allElementsCount;

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

  @override
  List<Object?> get props => [maxPageNumber, allElementsCount];
}

class GetEventResponseDto extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int minimumAge;
  final double minimumPrice;
  final double maximumPrice;
  final List<CategoryDto> categories;
  final int status;
  final AddressDto address;

  const GetEventResponseDto({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.minimumAge,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.categories,
    required this.status,
    required this.address,
  });

  factory GetEventResponseDto.fromJson(Map<String, dynamic> json) {
    return GetEventResponseDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      minimumAge: json['minimumAge'] as int? ?? 0,
      minimumPrice: (json['minimumPrice'] as num?)?.toDouble() ?? 0.0,
      maximumPrice: (json['maximumPrice'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((cat) =>
                  CategoryDto.fromJson(cat as Map<String, dynamic>? ?? {}))
              .toList() ??
          [],
      status: json['status'] as int? ?? 0,
      address:
          AddressDto.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        minimumAge,
        minimumPrice,
        maximumPrice,
        categories,
        status,
        address,
      ];
}

class CategoryDto extends Equatable {
  final String name;

  const CategoryDto({required this.name});

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      name: json['name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [name];
}

class AddressDto extends Equatable {
  final String country;
  final String city;
  final String postalCode;
  final String street;
  final int houseNumber;
  final int flatNumber;

  const AddressDto({
    required this.country,
    required this.city,
    required this.postalCode,
    required this.street,
    required this.houseNumber,
    required this.flatNumber,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      street: json['street'] as String? ?? '',
      houseNumber: json['houseNumber'] as int? ?? 0,
      flatNumber: json['flatNumber'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [country, city, postalCode, street, houseNumber, flatNumber];
}

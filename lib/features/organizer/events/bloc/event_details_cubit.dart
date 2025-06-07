import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/organizer/events/bloc/event_details_state.dart';
import 'package:resellio/features/common/model/Event/event_details.dart';
import 'package:resellio/features/common/model/address.dart';

class OrganizerEventDetailsCubit extends Cubit<OrganizerEventDetailsState> {
  OrganizerEventDetailsCubit(/*{required this.apiService}*/)
      : super(OrganizerEventDetailsInitialState());
  //final ApiService apiService;

  Future<void> fetchEventDetails(String token, String eventId) async {
    emit(OrganizerEventDetailsLoadingState());
    await Future.delayed(Duration(seconds: 1));
    emit(OrganizerEventDetailsLoadedState(
        eventDetails: OrganizerEventDetails.fromJson({
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
    })));
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/event.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit() : super(EventsInitial());

  Future<void> getEvents() async {
    emit(EventsLoading());
    try {
      final event = Event(
        id: '1',
        name: 'Event 1',
        description: 'Description 1',
        date: DateTime.now(),
        location: 'Location 1',
        image:
            'https://images.pexels.com/photos/1054655/pexels-photo-1054655.jpeg',
      );

      final events = List.generate(10, (index) => event);

      await Future<void>.delayed(const Duration(seconds: 1));

      emit(EventsLoaded(events));
    } catch (err) {
      emit(EventsError(err.toString()));
    }
  }
}

sealed class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  const EventsLoaded(this.events);

  final List<Event> events;

  @override
  List<Object> get props => [events];
}

class EventsError extends EventsState {
  const EventsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

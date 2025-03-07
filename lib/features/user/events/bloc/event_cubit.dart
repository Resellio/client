import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/event.dart';

class EventCubit extends Cubit<EventState> {
  EventCubit() : super(EventInitial());

  Future<void> getEvents() async {
    emit(EventLoading());
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
      await Future.delayed(const Duration(seconds: 1));
      emit(EventLoaded(event));
    } catch (err) {
      emit(EventError(err.toString()));
    }
  }
}

sealed class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  const EventLoaded(this.event);

  final Event event;

  @override
  List<Object> get props => [event];
}

class EventError extends EventState {
  const EventError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

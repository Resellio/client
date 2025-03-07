import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/user/events/bloc/event_cubit.dart';
import 'package:resellio/features/common/widgets/event_card.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: const _EventScreen(),
    );
  }
}

class _EventScreen extends StatelessWidget {
  const _EventScreen();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventCubit()..getEvents(),
      child: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          return switch (state) {
            EventInitial() => const Center(child: CircularProgressIndicator()),
            EventLoading() => const Center(child: CircularProgressIndicator()),
            EventLoaded(:final event) => SingleChildScrollView(
                child: EventCard(event: event),
              ),
            EventError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }
}

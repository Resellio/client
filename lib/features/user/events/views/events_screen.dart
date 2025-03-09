import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/widgets/event_card.dart';
import 'package:resellio/features/user/events/bloc/event_cubit.dart';
import 'package:resellio/routes/routes.dart';

class CustomerEventsScreen extends StatelessWidget {
  const CustomerEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: const _CustomerEventsScreen(),
    );
  }
}

class _CustomerEventsScreen extends StatelessWidget {
  const _CustomerEventsScreen();

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
                child: EventCard(
                  event: event,
                  onTap: () =>
                      CustomerEventDetailRoute(eventId: event.id).go(context),
                ),
              ),
            EventError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }
}

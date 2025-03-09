import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/widgets/event_card.dart';
import 'package:resellio/features/user/events/bloc/event_cubit.dart';
import 'package:resellio/routes/customer_routes.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szukaj')),
      body: const _CustomerSearchScreen(),
    );
  }
}

class _CustomerSearchScreen extends StatelessWidget {
  const _CustomerSearchScreen();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsCubit()..getEvents(),
      child: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          return switch (state) {
            EventInitial() => const Center(child: CircularProgressIndicator()),
            EventsLoading() => const Center(child: CircularProgressIndicator()),
            //
            EventsLoaded(:final events) => SingleChildScrollView(
                child: Column(
                  children: events
                      .map(
                        (event) => EventCard(
                          event: event,
                          onTap: () =>
                              CustomerEventDetailRoute(eventId: event.id)
                                  .go(context),
                        ),
                      )
                      .toList(),
                ),
              ),
            EventsError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }
}

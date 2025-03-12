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

class _CustomerSearchScreen extends StatefulWidget {
  const _CustomerSearchScreen();

  @override
  _CustomerSearchScreenState createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<_CustomerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsCubit()..getEvents(),
      child: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search events...',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) {},
                  ),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 1'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 2'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 3'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 4'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 5'),
                          ),
                        ],
                      ),
                    ),
                  )),
              Expanded(
                child: switch (state) {
                  EventInitial() =>
                    const Center(child: CircularProgressIndicator()),
                  EventsLoading() =>
                    const Center(child: CircularProgressIndicator()),
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
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/admin/manage_organizers/bloc/organizer.dart';
import 'package:resellio/features/admin/manage_organizers/bloc/organizers_cubit.dart';
import 'package:resellio/features/admin/manage_organizers/bloc/organizers_state.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';

class AdminManageOrganizersScreen extends StatelessWidget {
  const AdminManageOrganizersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AdminManageOrganizersContent(),
    );
  }
}

class AdminManageOrganizersContent extends StatefulWidget {
  const AdminManageOrganizersContent({super.key});

  @override
  State<AdminManageOrganizersContent> createState() =>
      _AdminManageOrganizersContentState();
}

class _AdminManageOrganizersContentState
    extends State<AdminManageOrganizersContent> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  final Set<String> _expandedOrganizers = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _toggleExpanded(String organizerEmail) {
    setState(() {
      if (_expandedOrganizers.contains(organizerEmail)) {
        _expandedOrganizers.remove(organizerEmail);
      } else {
        _expandedOrganizers.add(organizerEmail);
      }
    });
  }

  Future<void> _verifyOrganizer(String email) async {
    await context.read<OrganizersCubit>().verifyOrganizer(email);
    if (mounted) {
      if (_expandedOrganizers.contains(email)) {
        _expandedOrganizers.remove(email);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _loadInitialPage() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthorizedAdmin) {
      context.read<OrganizersCubit>().fetchNextPage();
    }
  }

  void _refresh() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthorizedAdmin) {
      context.read<OrganizersCubit>().refresh();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final state = context.read<OrganizersCubit>().state;

    if (currentScroll >= maxScroll * 0.9 &&
        state.status != OrganizersStatus.loading &&
        !state.hasReachedMax) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthorizedAdmin) {
        context.read<OrganizersCubit>().fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizersCubit, OrganizersState>(
      builder: (context, state) {
        if (state.status == OrganizersStatus.initial ||
            (state.status == OrganizersStatus.loading &&
                state.organizers.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == OrganizersStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'Błąd podczas ładowania'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          );
        }

        if (state.organizers.isEmpty) {
          return const Center(
            child: Text('Brak niezweryfikowanych organizatorów'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.organizers.length +
                (state.status == OrganizersStatus.loading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.organizers.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final organizer = state.organizers[index];
              final isExpanded = _expandedOrganizers.contains(organizer.email);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  organizer.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  organizer.email,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _verifyOrganizer(organizer.email),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Verify'),
                          ),
                          IconButton(
                            icon: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onPressed: () => _toggleExpanded(organizer.email),
                          ),
                        ],
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildOrganizerDetails(organizer),
                        ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        );
      },
    );
  }

  Widget _buildOrganizerDetails(Organizer organizer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Name: ${organizer.firstName}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Last Name: ${organizer.lastName}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class OrganizerListTile extends StatelessWidget {
  const OrganizerListTile({super.key, required this.organizer});

  final Organizer organizer;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.account_circle),
      title: Text(organizer.firstName),
      subtitle: Text(organizer.email),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kliknięto: ${organizer.firstName}')),
        );
      },
    );
  }
}

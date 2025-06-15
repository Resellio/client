import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/user/tickets/bloc/ticket_details_cubit.dart';
import 'package:resellio/features/user/tickets/bloc/ticket_details_state.dart';
import 'package:resellio/features/user/tickets/bloc/tickets_cubit.dart';
import 'package:resellio/features/user/tickets/model/ticket_details.dart';

class CustomerTicketScreen extends StatefulWidget {
  const CustomerTicketScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<CustomerTicketScreen> createState() => _CustomerTicketScreenState();
}

class _CustomerTicketScreenState extends State<CustomerTicketScreen> {
  bool _isFullscreen = false;
  final _resellPriceController = TextEditingController();
  final _resellCurrencyController = TextEditingController();

  @override
  void dispose() {
    _resellPriceController.dispose();
    _resellCurrencyController.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showResellDialog(
    BuildContext context,
    TicketDetails ticket,
    ApiService apiService,
    TicketsCubit ticketsCubit,
    TicketDetailsCubit cubit,
  ) {
    _resellPriceController.text = ticket.price.toString();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Odsprzedaj bilet',
          style: TextStyle(fontSize: 20),
        ),
        content: TextField(
          controller: _resellPriceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cena odsprzedaży',
            border: OutlineInputBorder(),
            suffixText: 'PLN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(_resellPriceController.text);
              if (price == null || price <= 0) {
                ErrorSnackBar.show(context, 'Podaj prawidłową cenę');
                return;
              }
              try {
                final response = await apiService.resellTicket(
                  ticketId: widget.ticketId,
                  resellPrice: price,
                  resellCurrency: 'PLN',
                );
                if (context.mounted) {
                  if (response.success) {
                    Navigator.of(context).pop();
                    SuccessSnackBar.show(
                      context,
                      'Bilet został wystawiony na odsprzedaż!',
                    );
                    await cubit.refreshTicketDetails(widget.ticketId);
                    await ticketsCubit.refreshTickets();
                  } else {
                    ErrorSnackBar.show(
                      context,
                      response.message ?? 'Wystąpił błąd',
                    );
                  }
                }
              } catch (err) {
                if (mounted) {
                  ErrorSnackBar.show(this.context, 'Błąd: $err');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Wystaw na sprzedaż'),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(TicketDetails ticket) {
    Uint8List? qrBytes;
    try {
      qrBytes = base64Decode(ticket.qrcode);
    } catch (err) {
      // If it's not base64, assume it's a URL
    }

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _toggleFullscreen,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  _isFullscreen ? MediaQuery.of(context).size.width * 0.8 : 200,
              maxHeight: _isFullscreen
                  ? MediaQuery.of(context).size.height * 0.6
                  : 200,
            ),
            child: qrBytes != null
                ? Image.memory(
                    qrBytes,
                    fit: BoxFit.contain,
                  )
                : CachedNetworkImage(
                    imageUrl: ticket.qrcode,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketDetails(TicketDetails ticket) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.event,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organizator: ${ticket.organizerName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.person,
            'Nazwa na bilecie',
            ticket.nameOnTicket,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.monetization_on,
            'Cena',
            '${ticket.price.toStringAsFixed(2)} ${ticket.currency}',
          ),
          if (ticket.forResell && ticket.resellPrice != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.sell,
              'Cena odsprzedaży',
              '${ticket.resellPrice!.toStringAsFixed(2)} ${ticket.resellCurrency ?? 'PLN'}',
            ),
          ],
          if (ticket.seats != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.event_seat,
              'Miejsca',
              ticket.seats!,
            ),
          ],
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Start',
            dateFormat.format(ticket.startDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.schedule,
            'Koniec',
            dateFormat.format(ticket.endDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.location_on,
            'Lokalizacja',
            '${ticket.address.street} ${ticket.address.houseNumber}, ${ticket.address.postalCode} ${ticket.address.city}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsedTicketSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Bilet został użyty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ten bilet został już zeskanowany i wykorzystany na wydarzeniu.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'Status: Użyty',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFullscreen ? Colors.black : Colors.grey[100],
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: const Text('Szczegóły biletu'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      body: BlocBuilder<TicketDetailsCubit, TicketDetailsState>(
        builder: (context, state) {
          if (state is TicketDetailsLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is TicketDetailsErrorState) {
            return CommonErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<TicketDetailsCubit>()
                  .loadTicketDetails(widget.ticketId),
              showBackButton: false,
            );
          }

          if (state is TicketDetailsLoadedState) {
            final ticket = state.ticketDetails;
            if (_isFullscreen) {
              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GestureDetector(
                          onTap: _toggleFullscreen,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: _buildQRSection(ticket),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      onPressed: _toggleFullscreen,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<TicketDetailsCubit>()
                    .refreshTicketDetails(widget.ticketId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildTicketDetails(ticket),
                    if (!ticket.used) ...[
                      _buildQRSection(ticket),
                      if (ticket.forResell && ticket.resellPrice != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sell,
                                size: 20,
                                color: Colors.orange[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bilet wystawiony na sprzedaż za ${ticket.resellPrice!.toStringAsFixed(2)} ${ticket.resellCurrency ?? 'PLN'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Dotknij kod QR, aby wyświetlić na pełnym ekranie',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!ticket.forResell) ...[
                        Container(
                          margin: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showResellDialog(
                              context,
                              ticket,
                              context.read<ApiService>(),
                              context.read<TicketsCubit>(),
                              context.read<TicketDetailsCubit>(),
                            ),
                            label: const Text(
                              'Odsprzedaj bilet',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                    if (ticket.used) ...[
                      _buildUsedTicketSection(),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

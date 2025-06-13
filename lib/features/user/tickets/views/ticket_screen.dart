import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/user/tickets/bloc/ticket_details_cubit.dart';
import 'package:resellio/features/user/tickets/bloc/ticket_details_state.dart';
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
  ) {
    _resellPriceController.text = ticket.price.toString();
    _resellCurrencyController.text = ticket.currency;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Odsprzedaj bilet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _resellPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cena odsprzedaży',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _resellCurrencyController,
              decoration: const InputDecoration(
                labelText: 'Waluta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
              ),
            ),
          ],
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Podaj prawidłową cenę')),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                final response = await apiService.resellTicket(
                  ticketId: widget.ticketId,
                  resellPrice: price,
                  resellCurrency: _resellCurrencyController.text,
                );
                if (mounted) {
                  if (response.success) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Bilet został wystawiony na odsprzedaż!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(response.message ?? 'Wystąpił błąd'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Błąd: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
    } catch (e) {
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
        child: Column(
          children: [
            Text(
              'Kod QR biletu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toggleFullscreen,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _isFullscreen
                          ? MediaQuery.of(context).size.width * 0.8
                          : 200,
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
            ),
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
          ],
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
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
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
          _buildDetailRow(Icons.person, 'Imię na bilecie', ticket.nameOnTicket),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.monetization_on,
            'Cena',
            '${ticket.price.toStringAsFixed(2)} ${ticket.currency}',
          ),
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
            '${ticket.address.street}, ${ticket.address.city}',
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
    return BlocProvider(
      create: (context) => TicketDetailsCubit(
        apiService: context.read<ApiService>(),
      )..loadTicketDetails(widget.ticketId),
      child: Scaffold(
        backgroundColor: _isFullscreen ? Colors.black : Colors.grey[100],
        appBar: _isFullscreen
            ? null
            : AppBar(
                title: const Text(
                  'Szczegóły biletu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
        body: BlocBuilder<TicketDetailsCubit, TicketDetailsState>(
          builder: (context, state) {
            if (state is TicketDetailsLoadingState) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Ładowanie szczegółów biletu...'),
                  ],
                ),
              );
            }

            if (state is TicketDetailsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Błąd',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<TicketDetailsCubit>()
                            .loadTicketDetails(widget.ticketId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
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
                      top: 40,
                      right: 20,
                      child: IconButton(
                        onPressed: _toggleFullscreen,
                        icon: const Icon(
                          Icons.fullscreen_exit,
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
                        Container(
                          margin: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showResellDialog(
                              context,
                              ticket,
                              context.read<ApiService>(),
                            ),
                            icon: const Icon(Icons.sell),
                            label: const Text(
                              'Odsprzedaj bilet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
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
      ),
    );
  }
}

// shopping_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:resellio/features/common/model/Cart/cart_item.dart';
import 'package:resellio/features/common/model/Cart/new_cart_ticket.dart';
import 'package:resellio/features/common/model/Cart/resell_cart_ticket.dart';

class CustomerShoppingCartScreen extends StatefulWidget {
  const CustomerShoppingCartScreen({super.key});

  @override
  State<CustomerShoppingCartScreen> createState() =>
      _CustomerShoppingCartScreenState();
}

class _CustomerShoppingCartScreenState
    extends State<CustomerShoppingCartScreen> {
  final _mockCartItems = <CartItem>[
    const ResellCartItem(
      ResellCartTicket(
        ticketId: '123e4567-e89b-12d3-a456-426614174000',
        eventName: 'Koncert',
        ticketType: 'VIP',
        organizerName: 'Live Nation',
        originalOwnerEmail: 'jan@example.com',
        price: 150,
        currency: 'PLN',
      ),
    ),
    NewCartItem(
      NewCartTicket(
        ticketTypeId: '987fcdeb-51a2-43d7-8f9e-123456789abc',
        eventName: 'Festiwal Orange',
        ticketType: 'Standard',
        organizerName: 'Orange Polska',
        quantity: 2,
        unitPrice: 80,
        currency: 'PLN',
      ),
    ),
    const ResellCartItem(
      ResellCartTicket(
        ticketId: '456e7890-e12b-34d5-a678-901234567890',
        eventName: 'Kraków Live Festival',
        ticketType: 'Premium',
        organizerName: 'Kraków Events',
        originalOwnerEmail: 'anna@example.com',
        price: 200,
        currency: 'PLN',
      ),
    ),
  ];

  double get _totalPrice {
    return _mockCartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koszyk'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _mockCartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartWithItems(context),
      bottomNavigationBar:
          _mockCartItems.isNotEmpty ? _buildCheckoutBar(context) : null,
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Twój koszyk jest pusty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Dodaj bilety do koszyka, aby kontynuować',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _mockCartItems.length,
            itemBuilder: (context, index) {
              final item = _mockCartItems[index];
              return _buildCartItemCard(context, item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isResell
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isResell ? 'ODSPRZEDAŻ' : 'NOWY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.isResell
                          ? Colors.orange.shade800
                          : Colors.blue.shade800,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(context, index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.eventName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.ticketType,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organizator: ${item.organizerName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!item.isResell)
                  Text(
                    '${(item as NewCartItem).ticket.unitPrice.toStringAsFixed(2)} ${item.currency} × ${(item as NewCartItem).ticket.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  '${item.totalPrice.toStringAsFixed(2)} ${item.currency}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Łącznie:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(2)} PLN',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Przejdź do płatności',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(BuildContext context, int index) {
    setState(() {
      if (!_mockCartItems[index].isResell &&
          (_mockCartItems[index] as NewCartItem).ticket.quantity > 1) {
        (_mockCartItems[index] as NewCartItem).ticket.quantity = 1;
      } else {
        _mockCartItems.removeAt(index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usunięto bilet z koszyka')),
    );
  }

  void _checkout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Przechodzenie do płatności...')),
    );
  }
}

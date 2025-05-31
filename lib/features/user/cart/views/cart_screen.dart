// shopping_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/Cart/cart_item.dart';
import 'package:resellio/features/common/model/Cart/new_cart_ticket.dart';
import 'package:resellio/features/common/model/Cart/resell_cart_ticket.dart';
import 'package:resellio/features/user/cart/bloc/cart_cubit.dart';
import 'package:resellio/features/user/cart/bloc/cart_state.dart';

class CustomerShoppingCartScreen extends StatefulWidget {
  const CustomerShoppingCartScreen({super.key});

  @override
  State<CustomerShoppingCartScreen> createState() =>
      _CustomerShoppingCartScreenState();
}

class _CustomerShoppingCartScreenState
    extends State<CustomerShoppingCartScreen> {
  Map<int, int> _tempQuantities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koszyk'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoadedState) {
            _initializeTempQuantities(state.items);
            return state.items.isEmpty
                ? _buildEmptyCart()
                : _buildCartWithItems(context, state);
          } else if (state is CartErrorState) {
            return const Text('Error');
          }
          return const Text('unknown');
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoadedState && state.items.isNotEmpty) {
            return _buildCheckoutBar(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _initializeTempQuantities(List<CartItem> items) {
    print("initializin");
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (!item.isResell && !_tempQuantities.containsKey(i)) {
        _tempQuantities[i] = (item as NewCartItem).ticket.quantity;
      }
    }
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

  Widget _buildCartWithItems(BuildContext context, CartLoadedState state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _buildCartItemCard(context, item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, int index) {
    final currentQuantity = _tempQuantities[index] ??
        (!item.isResell ? (item as NewCartItem).ticket.quantity : 1);
    final originalQuantity =
        !item.isResell ? (item as NewCartItem).ticket.quantity : 1;
    final hasQuantityChanges = currentQuantity != originalQuantity;
    print(
        "Number $index current q: $currentQuantity and originalq: $originalQuantity");
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
            if (!item.isResell) ...[
              _buildQuantityControls(
                  context, index, currentQuantity, originalQuantity),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!item.isResell)
                  Text(
                    '${(item as NewCartItem).ticket.unitPrice.toStringAsFixed(2)} ${item.currency} × $originalQuantity',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  !item.isResell
                      ? '${((item as NewCartItem).ticket.unitPrice * originalQuantity).toStringAsFixed(2)} ${item.currency}'
                      : '${item.totalPrice.toStringAsFixed(2)} ${item.currency}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (!item.isResell && hasQuantityChanges) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _cancelQuantityChange(index, originalQuantity),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('Anuluj'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentQuantity > 0
                          ? () =>
                              _updateQuantity(context, index, currentQuantity)
                          : () => _removeItem(context, index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentQuantity > 0
                            ? Theme.of(context).primaryColor
                            : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(currentQuantity > 0 ? 'Zaktualizuj' : 'Usuń'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
      BuildContext context, int index, int currentQuantity, int maxQuantity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Text(
            'Ilość:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: currentQuantity > 0
                    ? () => _changeQuantity(index, currentQuantity - 1)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: currentQuantity > 0 ? Colors.red : Colors.grey,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$currentQuantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: currentQuantity < maxQuantity
                    ? () => _changeQuantity(index, currentQuantity + 1)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: currentQuantity < maxQuantity
                      ? Colors.green
                      : Colors.grey,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            'z $maxQuantity',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartLoadedState state) {
    // Calculate total with temp quantities
    double calculatedTotal = 0.0;
    for (int i = 0; i < state.items.length; i++) {
      final item = state.items[i];
      if (item.isResell) {
        calculatedTotal += item.totalPrice;
      } else {
        final newItem = item as NewCartItem;
        final quantity = newItem.ticket.quantity;
        calculatedTotal += newItem.ticket.unitPrice * quantity;
      }
    }

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
                  '${calculatedTotal.toStringAsFixed(2)} PLN',
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

  void _changeQuantity(int index, int newQuantity) {
    setState(() {
      _tempQuantities[index] = newQuantity;
    });
  }

  void _cancelQuantityChange(int index, int originalQuantity) {
    setState(() {
      _tempQuantities[index] = originalQuantity;
    });
  }

  void _updateQuantity(BuildContext context, int index, int newQuantity) {
    context.read<CartCubit>().updateQuantity(index, newQuantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Zaktualizowano ilość na $newQuantity')),
    );
  }

  void _removeItem(BuildContext context, int index) {
    context.read<CartCubit>().removeItem(index);

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

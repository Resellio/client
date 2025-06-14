// shopping_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';

import 'package:resellio/features/user/cart/bloc/cart_cubit.dart';
import 'package:resellio/features/user/cart/bloc/cart_state.dart';
import 'package:resellio/features/user/cart/model/cart_item.dart';
import 'package:resellio/routes/customer_routes.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Koszyk'),
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return switch (state) {
              CartInitialState() =>
                const Center(child: CircularProgressIndicator()),
              CartLoadingState() =>
                const Center(child: CircularProgressIndicator()),
              CartLoadedState() when state.items.isEmpty => _buildEmptyCart(),
              CartLoadedState() => _buildCartWithItems(context, state),
              CartErrorState() => _buildCartError(context, state),
            };
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
      ),
    );
  }

  Widget _buildCartError(BuildContext context, CartErrorState state) {
    return CommonErrorWidget(
      message: state.message,
      onRetry: () => context.read<CartCubit>().fetchCart(),
      showBackButton: false,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Koszyk jest pusty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodaj jakieś bilety do koszyka',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => const CustomerEventsRoute().go(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Szukaj wydarzeń'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartWithItems(BuildContext context, CartLoadedState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _buildCartItemCard(context, item, index);
      },
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
            if (!item.isResell) ...[
              QuantityControlsWidget(
                index: index,
                initialQuantity: (item as NewCartItem).ticket.quantity,
                maxQuantity: item.ticket.quantity,
                onQuantityUpdate: (newQuantity) =>
                    _updateQuantity(context, index, newQuantity),
                onRemoveItem: () => _removeItem(context, index),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!item.isResell)
                  Text(
                    '${(item as NewCartItem).ticket.unitPrice.toStringAsFixed(2)} ${item.currency} × ${item.ticket.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  !item.isResell
                      ? '${((item as NewCartItem).ticket.unitPrice * item.ticket.quantity).toStringAsFixed(2)} ${item.currency}'
                      : '${item.totalPrice.toStringAsFixed(2)} ${item.currency}',
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

  Widget _buildCheckoutBar(BuildContext context, CartLoadedState state) {
    var calculatedTotal = 0.0;
    for (var i = 0; i < state.items.length; i++) {
      final item = state.items[i];
      if (item.isResell) {
        calculatedTotal += item.totalPrice;
      } else {
        final newItem = item as NewCartItem;
        final quantity = newItem.ticket.quantity;
        final itemTotal = newItem.ticket.unitPrice * quantity;
        calculatedTotal += double.parse(itemTotal.toStringAsFixed(2));
      }
    }
    calculatedTotal = double.parse(calculatedTotal.toStringAsFixed(2));

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
              onPressed: () => const CustomerCheckoutRoute().go(context),
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
    );
  }

  void _updateQuantity(BuildContext context, int index, int newQuantity) {
    context.read<CartCubit>().updateQuantity(index, newQuantity);

    SuccessSnackBar.show(context, 'Zaktualizowano ilość na $newQuantity');
  }

  void _removeItem(BuildContext context, int index) {
    context.read<CartCubit>().removeItem(index);

    SuccessSnackBar.show(context, 'Usunięto bilet z koszyka');
  }
}

class QuantityControlsWidget extends StatefulWidget {
  const QuantityControlsWidget({
    super.key,
    required this.index,
    required this.initialQuantity,
    required this.maxQuantity,
    required this.onQuantityUpdate,
    required this.onRemoveItem,
  });

  final int index;
  final int initialQuantity;
  final int maxQuantity;
  final void Function(int) onQuantityUpdate;
  final VoidCallback onRemoveItem;

  @override
  State<QuantityControlsWidget> createState() => _QuantityControlsWidgetState();
}

class _QuantityControlsWidgetState extends State<QuantityControlsWidget> {
  late int _currentQuantity;
  late int _originalQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
    _originalQuantity = widget.initialQuantity;
  }

  @override
  void didUpdateWidget(QuantityControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuantity != oldWidget.initialQuantity) {
      _currentQuantity = widget.initialQuantity;
      _originalQuantity = widget.initialQuantity;
    }
  }

  bool get _hasQuantityChanges => _currentQuantity != _originalQuantity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQuantityControls(),
        if (_hasQuantityChanges) ...[
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildQuantityControls() {
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
                onPressed: _currentQuantity > 0
                    ? () => _changeQuantity(_currentQuantity - 1)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: _currentQuantity > 0 ? Colors.red : Colors.grey,
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
                  '$_currentQuantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentQuantity < widget.maxQuantity
                    ? () => _changeQuantity(_currentQuantity + 1)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _currentQuantity < widget.maxQuantity
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
            'z ${widget.maxQuantity}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelQuantityChange,
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
            onPressed: _currentQuantity > 0
                ? () => widget.onQuantityUpdate(_currentQuantity)
                : widget.onRemoveItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentQuantity > 0
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(_currentQuantity > 0 ? 'Zaktualizuj' : 'Usuń'),
          ),
        ),
      ],
    );
  }

  void _changeQuantity(int newQuantity) {
    setState(() {
      _currentQuantity = newQuantity;
    });
  }

  void _cancelQuantityChange() {
    setState(() {
      _currentQuantity = _originalQuantity;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _onCheckout(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text(
            'Your total is \$${cart.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}. Do you want to proceed to checkout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().clear();
              Navigator.pop(context);
              context.go('/home');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order confirmed! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Checkout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Empty Cart'),
                    content: const Text('Are you sure you want to remove all products?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartProvider>().clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Empty Cart'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Add products to get started!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: Key(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context
                              .read<CartProvider>()
                              .removeProduct(item.product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.product.name} removed'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => context
                                    .read<CartProvider>()
                                    .addProduct(item.product),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Imagen
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        size: 40),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                        style: const TextStyle(
                                            color: AppTheme.accentColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                // Controles cantidad
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      color: AppTheme.accentColor,
                                      onPressed: () => context
                                          .read<CartProvider>()
                                          .removeOne(item.product.id),
                                    ),
                                    Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.add_circle_outline),
                                      color: AppTheme.accentColor,
                                      onPressed: () => context
                                          .read<CartProvider>()
                                          .addProduct(item.product),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Resumen total
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping',
                              style: TextStyle(color: AppTheme.textSecondary)),
                          Text('\$15.000'),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${(cart.totalPrice + 15000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _onCheckout(context, cart),
                          child: const Text('Checkout',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
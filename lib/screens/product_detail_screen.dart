import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/products_data.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = kProducts.firstWhere((p) => p.id == widget.productId);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 60),
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Chip(
                    label: Text(product.category,
                        style: const TextStyle(color: Colors.black)),
                    backgroundColor: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 8),

                  // Nombre
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(' ${product.rating}',
                          style: const TextStyle(fontSize: 16)),
                      Text('  (${product.reviewCount} reviews)',
                          style: const TextStyle(
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Precio
                  Text(
                    '\$${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor),
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 8),

                  // Descripción
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, height: 1.5)),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Selector cantidad
                  const Text('Quantity',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 32),
                        color: AppTheme.accentColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('$_quantity',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add_circle_outline, size: 32),
                        color: AppTheme.accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón agregar al carrito
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartProvider>().addProduct(
                            product, quantity: _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${product.name} added to cart 🛒'),
                            backgroundColor: Colors.green,
                            action: SnackBarAction(
                              label: 'View cart',
                              textColor: Colors.white,
                              onPressed: () => context.go('/cart'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        cart.contains(product.id)
                            ? 'Add more to cart'
                            : 'Add to cart',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
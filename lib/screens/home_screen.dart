import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/products_data.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _navIndex = 0;

  List<Product> get _filteredProducts {
    return kProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Smartphones': return Icons.smartphone;
      case 'Laptops':     return Icons.laptop;
      case 'Audio':       return Icons.headphones;
      case 'Tablets':     return Icons.tablet;
      case 'Wearables':   return Icons.watch;
      case 'Cameras':     return Icons.camera_alt;
      case 'Accessories': return Icons.cable;
      case 'Monitors':    return Icons.monitor;
      default:            return Icons.grid_view;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final featured = kProducts.where((p) => p.isFeatured).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TechStore',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Welcome back!',
                style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12)),
          ],
        ),
        actions: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  onPressed: () => context.go('/cart'),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 12, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$cartCount',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.accentColor, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Featured
            if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 12),
                child: Text('Featured',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: featured.length,
                  itemBuilder: (context, i) => _FeaturedCard(
                    product: featured[i],
                    onTap: () => context.go('/product/${featured[i].id}'),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Categorías
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 12),
              child: Text('Categories',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: kCategories.length,
                itemBuilder: (context, i) {
                  final cat = kCategories[i];
                  final isSelected = cat == _selectedCategory;
                  return _CategoryPill(
                    label: cat,
                    icon: _categoryIcon(cat),
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Products header
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Row(
                children: [
                  const Text('Products',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_filteredProducts.length}',
                        style: const TextStyle(color: AppTheme.accentColor, fontSize: 12)),
                  ),
                ],
              ),
            ),

            _filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.search_off, size: 60, color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 8),
                        Text('No results found',
                            style: TextStyle(color: Colors.white.withOpacity(0.3))),
                      ]),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) => _AnimatedProductCard(
                      product: _filteredProducts[index],
                      index: index,
                      onTap: () => context.go('/product/${_filteredProducts[index].id}'),
                    ),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: (i) {
              setState(() => _navIndex = i);
              if (i == 2) context.go('/cart');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.accentColor,
            unselectedItemColor: Colors.white.withOpacity(0.3),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Saved'),
              BottomNavigationBarItem(
                icon: Stack(children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (cartCount > 0)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppTheme.accentColor, shape: BoxShape.circle),
                      ),
                    ),
                ]),
                activeIcon: const Icon(Icons.shopping_bag),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _FeaturedCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1A1A),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1E1E)),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black.withOpacity(0.6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(product.category,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 3),
                            Text(product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '\$${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: const TextStyle(
                                  color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryPill({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 60,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentColor : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
                  size: 22),
            ),
            const SizedBox(height: 5),
            Text(
              label.length > 6 ? '${label.substring(0, 5)}..' : label,
              style: TextStyle(
                color: isSelected ? AppTheme.accentColor : Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedProductCard extends StatefulWidget {
  final Product product;
  final int index;
  final VoidCallback onTap;
  const _AnimatedProductCard({required this.product, required this.index, required this.onTap});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1A1A),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen con badge
                  Expanded(
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'product-${widget.product.id}',
                          child: Image.network(
                            widget.product.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF242424),
                              child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.white12, size: 36)),
                            ),
                          ),
                        ),
                        // Badge categoría
                        Positioned(
                          top: 8, left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(widget.product.category,
                                style: const TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info + botón +
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${widget.product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                  style: const TextStyle(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Row(children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text('${widget.product.rating}',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white.withOpacity(0.4))),
                                ]),
                              ],
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cart, _) => GestureDetector(
                                onTap: () {
                                  cart.addProduct(widget.product);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('${widget.product.name} added to cart'),
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 30, height: 30,
                                  decoration: BoxDecoration(
                                    color: cart.contains(widget.product.id)
                                        ? AppTheme.accentColor
                                        : const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    cart.contains(widget.product.id) ? Icons.check : Icons.add,
                                    color: cart.contains(widget.product.id)
                                        ? Colors.black
                                        : Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
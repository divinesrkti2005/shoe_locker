import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Map<String, dynamic> shoe) {
    _cartItems.add(shoe);
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> shoe) {
    _cartItems.remove(shoe);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> shoe;
  const ProductDetailsPage({Key? key, required this.shoe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoe['name'] ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
              Center(
                child: Image.network(
                  shoe['image'].toString().startsWith('http')
                      ? shoe['image']
                      : 'http://10.0.2.2:3000/public/uploads/${shoe['image']}',
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              shoe['name'] ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Brand: ${shoe['brand'] ?? ''}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Price: 24${shoe['price'] ?? ''}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              shoe['description'] ?? 'No description.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<CartProvider>().addToCart(shoe);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${shoe['name']} to cart!')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    (shoe['wishlisted'] ?? false) ? Icons.favorite : Icons.favorite_border,
                    color: (shoe['wishlisted'] ?? false) ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    // Wishlist logic will be implemented later
                  },
                  tooltip: 'Add to Wishlist',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
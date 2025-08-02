import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'providers/cart_provider.dart';
import 'payment_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> shoe;
  const ProductDetailsPage({Key? key, required this.shoe}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSize = 0;
  String _selectedColor = '';
  int _quantity = 1;
  bool _isWishlisted = false;
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _relatedProducts = [];
  bool _isLoadingReviews = false;
  bool _isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedColor = widget.shoe['colors']?.isNotEmpty == true 
        ? widget.shoe['colors'][0] 
        : '';
    _isWishlisted = widget.shoe['wishlisted'] ?? false;
    _loadReviews();
    _loadRelatedProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      // Mock reviews data - in real app, this would come from API
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _reviews = [
          {
            'id': '1',
            'user': 'John D.',
            'rating': 5,
            'comment': 'Great shoes! Very comfortable and stylish.',
            'date': '2024-01-15',
          },
          {
            'id': '2',
            'user': 'Sarah M.',
            'rating': 4,
            'comment': 'Good quality, but runs a bit small.',
            'date': '2024-01-10',
          },
          {
            'id': '3',
            'user': 'Mike R.',
            'rating': 5,
            'comment': 'Perfect fit and excellent comfort!',
            'date': '2024-01-05',
          },
        ];
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _loadRelatedProducts() async {
    setState(() => _isLoadingRelated = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/v1/shoes?category=${widget.shoe['category']}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> products = data is List ? data : (data['data'] ?? []);
        setState(() {
          _relatedProducts = products
              .where((product) => product['_id'] != widget.shoe['_id'])
              .take(4)
              .map((product) => Map<String, dynamic>.from(product))
              .toList();
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingRelated = false);
    }
  }

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWishlisted ? 'Added to wishlist!' : 'Removed from wishlist!'),
        backgroundColor: _isWishlisted ? Colors.green : Colors.orange,
      ),
    );
  }

  void _addToCart() {
    try {
      final cartItem = Map<String, dynamic>.from(widget.shoe);
      cartItem['selectedSize'] = _selectedSize;
      cartItem['selectedColor'] = _selectedColor;
      cartItem['quantity'] = _quantity;
      
      // Add to local cart first
      Provider.of<CartProvider>(context, listen: false).addToCart(cartItem);
      
      // Show success message with cart navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.shoe['name']} to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to cart tab in dashboard
              Navigator.of(context).pop(); // Go back to dashboard
              // The cart will be visible in the bottom navigation
            },
          ),
        ),
      );
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _buyNow() {
    try {
      // Prepare the product data for payment
      final productData = Map<String, dynamic>.from(widget.shoe);
      productData['selectedSize'] = _selectedSize;
      productData['selectedColor'] = _selectedColor;
      productData['quantity'] = _quantity;
      
      // Calculate total amount
      final price = (widget.shoe['price'] ?? 0).toDouble();
      final totalAmount = price * _quantity;
      
      // Navigate to payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            product: productData,
            totalAmount: totalAmount,
          ),
        ),
      );
    } catch (e) {
      print('Error in buy now: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing purchase: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageGallery() {
    return Container(
      height: 300,
      child: PageView.builder(
        itemCount: 3, // Mock multiple images
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.shoe['image'] != null && widget.shoe['image'].toString().isNotEmpty
                  ? Image.network(
                      widget.shoe['image'].toString().startsWith('http')
                          ? widget.shoe['image']
                          : 'http://10.0.2.2:3000/public/uploads/${widget.shoe['image']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo() {
    final originalPrice = widget.shoe['originalPrice'] ?? widget.shoe['price'];
    final currentPrice = widget.shoe['price'];
    final hasDiscount = originalPrice > currentPrice;
    final discountPercentage = hasDiscount 
        ? ((originalPrice - currentPrice) / originalPrice * 100).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.shoe['name'] ?? '',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: _isWishlisted ? Colors.red : Colors.grey,
                size: 28,
              ),
              onPressed: _toggleWishlist,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Brand: ${widget.shoe['brand'] ?? ''}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (hasDiscount) ...[
              Text(
                '24${originalPrice}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-$discountPercentage%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '24${currentPrice}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              '4.5',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '(${_reviews.length} reviews)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final sizes = widget.shoe['availableSizes'] ?? [];
    if (sizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Select Size',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ...sizes.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final size = entry.value;
              final isSelected = _selectedSize == index;
              final isAvailable = size['quantity'] > 0;

              return GestureDetector(
                onTap: isAvailable ? () => setState(() => _selectedSize = index) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : null,
                  ),
                  child: Text(
                    '${size['size']}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isAvailable ? Colors.black : Colors.grey),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colors = widget.shoe['colors'] ?? [];
    if (colors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        Text(
          'Select Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ...colors.map<Widget>((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorFromString(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'brown': return Colors.brown;
      default: return Colors.grey;
    }
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: Icon(Icons.remove_circle_outline, 
                color: _quantity > 1 ? Theme.of(context).primaryColor : Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_quantity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Product Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Category', widget.shoe['category'] ?? ''),
        _buildDetailRow('Brand', widget.shoe['brand'] ?? ''),
        _buildDetailRow('Material', widget.shoe['material'] ?? 'N/A'),
        _buildDetailRow('Condition', widget.shoe['condition'] ?? 'New'),
        _buildDetailRow('In Stock', widget.shoe['inStock'] == true ? 'Yes' : 'No'),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.shoe['description'] ?? 'No description available.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews (${_reviews.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full reviews page
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Center(
            child: Text('No reviews yet. Be the first to review!'),
          )
        else
          Column(
            children: _reviews.take(3).map((review) => _buildReviewCard(review)).toList(),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['user'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review['comment'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              review['date'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Related Products',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoadingRelated)
          const Center(child: CircularProgressIndicator())
        else if (_relatedProducts.isEmpty)
          const Center(
            child: Text('No related products found.'),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedProducts.length,
              separatorBuilder: (context, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = _relatedProducts[index];
                return GestureDetector(
                  onTap: () {
                                         Navigator.pushReplacement(
                       context,
                       MaterialPageRoute(
                         builder: (context) => ChangeNotifierProvider(
                           create: (_) => CartProvider(),
                           child: ProductDetailsPage(shoe: product),
                         ),
                       ),
                     );
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: product['image'] != null && product['image'].toString().isNotEmpty
                                ? Image.network(
                                    product['image'].toString().startsWith('http')
                                        ? product['image']
                                        : 'http://10.0.2.2:3000/public/uploads/${product['image']}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey),
                                  )
                                : const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '24${product['price'] ?? ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: 24),
                  _buildSizeSelector(),
                  _buildColorSelector(),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Related'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(child: _buildProductDetails()),
                        SingleChildScrollView(child: _buildReviews()),
                        SingleChildScrollView(child: _buildRelatedProducts()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _buyNow,
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
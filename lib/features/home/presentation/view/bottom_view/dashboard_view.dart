import 'package:flutter/material.dart';
import 'package:shoe_locker/app/shared_pref/shared_pref_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../product_details_page.dart';
import '../profile_page.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const ProfilePage(),
    const AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await SharedPrefService.clearAuthData();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ShoeLocker',
            style: TextStyle(fontFamily: "OpenSans"),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['All', 'Sneakers', 'Running', 'Casual', 'Formal', 'Boots'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late Future<List<dynamic>> _shoesFuture;
  late Future<List<dynamic>> _featuredFuture;
  List<dynamic> _allShoes = [];

  @override
  void initState() {
    super.initState();
    _shoesFuture = fetchShoes();
    _featuredFuture = fetchFeaturedShoes();
  }

  Future<List<dynamic>> fetchShoes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/v1/shoes'));
    print('fetchShoes response: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        _allShoes = data;
        return _allShoes;
      }
      if (data is Map && data['data'] is List) {
        _allShoes = data['data'];
        return _allShoes;
      }
      return [];
    } else {
      throw Exception('Failed to load shoes');
    }
  }

  Future<List<dynamic>> fetchFeaturedShoes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/v1/shoes/featured'));
    print('fetchFeaturedShoes response: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }
      if (data is Map && data['data'] is List) {
        return data['data'];
      }
      return [];
    } else {
      return [];
    }
  }

  List<dynamic> get filteredShoes {
    List<dynamic> shoes = _allShoes;
    if (_selectedCategory != 'All') {
      shoes = shoes.where((shoe) => (shoe['category'] ?? '').toString().toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    if (_searchQuery.isNotEmpty) {
      shoes = shoes.where((shoe) {
        final name = (shoe['name'] ?? '').toString().toLowerCase();
        final brand = (shoe['brand'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) || brand.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return shoes;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onAddToCart(dynamic shoe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${shoe['name']} to cart!')),
    );
  }

  void _onToggleWishlist(dynamic shoe) {
    setState(() {
      shoe['wishlisted'] = !(shoe['wishlisted'] ?? false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(shoe['wishlisted'] ? 'Added to wishlist!' : 'Removed from wishlist!')),
    );
  }

  void _onShoeTap(dynamic shoe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(shoe: shoe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Welcome to ShoeLocker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover the latest trends in footwear',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search shoes by name or brand',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            // Featured Shoes Section
            Text(
              'Featured Shoes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<dynamic>>(
              future: _featuredFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                final featured = snapshot.data!;
                return SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    separatorBuilder: (context, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final shoe = featured[index];
                      return GestureDetector(
                        onTap: () => _onShoeTap(shoe),
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                                child: (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Image.network(
                                          shoe['image'].toString().startsWith('http')
                                              ? shoe['image']
                                              : 'http://10.0.2.2:3000/public/uploads/${shoe['image']}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 60, color: Colors.grey),
                                        ),
                                      )
                                    : const Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shoe['name'] ?? '',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '24${shoe['price'] ?? ''}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor),
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
                );
              },
            ),
            const SizedBox(height: 16),
            // Category/Filter Row
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Main Shoe Grid Section
            Text(
              'All Shoes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<dynamic>>(
              future: _shoesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No shoes found.'));
                }
                // Use filtered shoes for search and category
                final shoes = filteredShoes;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: shoes.length,
                  itemBuilder: (context, index) {
                    final shoe = shoes[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      shoe['image'].toString().startsWith('http')
                                          ? shoe['image']
                                          : 'http://10.0.2.2:3000/public/uploads/${shoe['image']}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 60, color: Colors.grey),
                                    ),
                                  )
                                : const Icon(Icons.image, size: 60, color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        shoe['name'] ?? '',
                                        style: Theme.of(context).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        (shoe['wishlisted'] ?? false) ? Icons.favorite : Icons.favorite_border,
                                        color: (shoe['wishlisted'] ?? false) ? Colors.red : Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () => _onToggleWishlist(shoe),
                                      tooltip: 'Add to Wishlist',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  shoe['brand'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '24${shoe['price'] ?? ''}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _onAddToCart(shoe),
                                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                                  label: const Text('Add to Cart'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<CartProvider>().cartItems;
    if (cartItems.isEmpty) {
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
              'Your Cart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your cart is empty.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shoe = cartItems[index];
        return Card(
          child: ListTile(
            leading: (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
                ? Image.network(
                    shoe['image'].toString().startsWith('http')
                        ? shoe['image']
                        : 'http://10.0.2.2:3000/public/uploads/${shoe['image']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 40, color: Colors.grey),
            title: Text(shoe['name'] ?? ''),
            subtitle: Text('24${shoe['price'] ?? ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<CartProvider>().removeFromCart(shoe);
              },
            ),
          ),
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Profile management coming soon!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ShoeLocker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ShoeLocker is your premier destination for the latest trends in footwear. '
            'We offer a curated collection of shoes from top brands, ensuring quality, '
            'style, and comfort for every step of your journey.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Features:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Wide selection of shoes'),
          const Text('• Secure payment processing'),
          const Text('• Fast and reliable shipping'),
          const Text('• Excellent customer support'),
          const SizedBox(height: 24),
          const Text(
            'Version: 1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 
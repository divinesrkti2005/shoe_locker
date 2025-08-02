import 'package:flutter/material.dart';
import 'package:shoe_locker/app/shared_pref/shared_pref_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../product_details_page.dart';
import '../profile_page.dart';
import '../providers/cart_provider.dart';
import '../payment_page.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
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

class WishlistProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _wishlistItems = [];

  List<Map<String, dynamic>> get wishlistItems => List.unmodifiable(_wishlistItems);

  void addToWishlist(Map<String, dynamic> shoe) {
    if (!_wishlistItems.any((item) => item['_id'] == shoe['_id'])) {
      _wishlistItems.add(shoe);
      notifyListeners();
    }
  }

  void removeFromWishlist(Map<String, dynamic> shoe) {
    _wishlistItems.removeWhere((item) => item['_id'] == shoe['_id']);
    notifyListeners();
  }

  bool isInWishlist(String shoeId) {
    return _wishlistItems.any((item) => item['_id'] == shoeId);
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['All', 'Running', 'Casual', 'Basketball', 'Lifestyle', 'Athletic'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _selectedBrand = 'All';
  String _sortBy = 'Newest';
  
  late Future<List<dynamic>> _shoesFuture;
  late Future<List<dynamic>> _featuredFuture;
  List<dynamic> _allShoes = [];
  List<String> _availableBrands = [];

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
        _extractBrands();
        return _allShoes;
      }
      if (data is Map && data['data'] is List) {
        _allShoes = data['data'];
        _extractBrands();
        return _allShoes;
      }
      return [];
    } else {
      throw Exception('Failed to load shoes');
    }
  }

  void _extractBrands() {
    final brands = _allShoes.map((shoe) => shoe['brand'] ?? '').where((brand) => brand.isNotEmpty).toSet().toList();
    brands.sort();
    setState(() {
      _availableBrands = ['All', ...brands];
    });
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
    
    // Category filter
    if (_selectedCategory != 'All') {
      shoes = shoes.where((shoe) => 
        (shoe['category'] ?? '').toString().toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }
    
    // Brand filter
    if (_selectedBrand != 'All') {
      shoes = shoes.where((shoe) => 
        (shoe['brand'] ?? '').toString().toLowerCase() == _selectedBrand.toLowerCase()
      ).toList();
    }
    
    // Price range filter
    shoes = shoes.where((shoe) {
      final price = (shoe['price'] ?? 0).toDouble();
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      shoes = shoes.where((shoe) {
        final name = (shoe['name'] ?? '').toString().toLowerCase();
        final brand = (shoe['brand'] ?? '').toString().toLowerCase();
        final description = (shoe['description'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || brand.contains(query) || description.contains(query);
      }).toList();
    }
    
    // Sort
    switch (_sortBy) {
      case 'Price: Low to High':
        shoes.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        break;
      case 'Price: High to Low':
        shoes.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
        break;
      case 'Name: A to Z':
        shoes.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        break;
      case 'Name: Z to A':
        shoes.sort((a, b) => (b['name'] ?? '').compareTo(a['name'] ?? ''));
        break;
      default: // Newest
        shoes.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
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

  void _onBrandSelected(String brand) {
    setState(() {
      _selectedBrand = brand;
    });
  }

  void _onPriceRangeChanged(RangeValues values) {
    setState(() {
      _priceRange = values;
    });
  }

  void _onSortByChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }

  void _onAddToCart(dynamic shoe) {
    context.read<CartProvider>().addToCart(shoe);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${shoe['name']} to cart!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  void _onToggleWishlist(dynamic shoe) {
    final wishlistProvider = context.read<WishlistProvider>();
    if (wishlistProvider.isInWishlist(shoe['_id'])) {
      wishlistProvider.removeFromWishlist(shoe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${shoe['name']} from wishlist!')),
      );
    } else {
      wishlistProvider.addToWishlist(shoe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${shoe['name']} to wishlist!')),
      );
    }
  }

  void _onShoeTap(dynamic shoe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => CartProvider(),
          child: ProductDetailsPage(shoe: shoe),
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategory = 'All';
                        _selectedBrand = 'All';
                        _priceRange = const RangeValues(0, 5000);
                        _sortBy = 'Newest';
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Category Filter
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: category == _selectedCategory,
                    onSelected: (_) {
                      setModalState(() => _selectedCategory = category);
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Brand Filter
              if (_availableBrands.isNotEmpty) ...[
                Text(
                  'Brand',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableBrands.map((brand) {
                    return ChoiceChip(
                      label: Text(brand),
                      selected: brand == _selectedBrand,
                      onSelected: (_) {
                        setModalState(() => _selectedBrand = brand);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Price Range Filter
              Text(
                'Price Range',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 5000,
                divisions: 50,
                labels: RangeLabels(
                  '24${_priceRange.start.round()}',
                  '24${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setModalState(() => _priceRange = values);
                },
              ),
              Text(
                '24${_priceRange.start.round()} - 24${_priceRange.end.round()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 24),
              
              // Sort Options
              Text(
                'Sort By',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  'Newest',
                  'Price: Low to High',
                  'Price: High to Low',
                  'Name: A to Z',
                  'Name: Z to A',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() => _sortBy = value);
                  }
                },
              ),
              
              const Spacer(),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
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
          children: <Widget>[
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
            
            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search shoes by name, brand, or description',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Active Filters
            if (_selectedCategory != 'All' || _selectedBrand != 'All' || _searchQuery.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  children: <Widget>[
                    if (_selectedCategory != 'All')
                      Chip(
                        label: Text('Category: $_selectedCategory'),
                        onDeleted: () => _onCategorySelected('All'),
                      ),
                    if (_selectedBrand != 'All')
                      Chip(
                        label: Text('Brand: $_selectedBrand'),
                        onDeleted: () => _onBrandSelected('All'),
                      ),
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text('Search: $_searchQuery'),
                        onDeleted: () => _onSearchChanged(''),
                      ),
                  ],
                ),
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
            
            // Results Count
            FutureBuilder<List<dynamic>>(
              future: _shoesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final filteredCount = filteredShoes.length;
                final totalCount = _allShoes.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Shoes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$filteredCount of $totalCount items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            
            // Main Shoe Grid Section
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
                
                final shoes = filteredShoes;
                if (shoes.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No shoes match your filters'),
                        SizedBox(height: 8),
                        Text('Try adjusting your search criteria'),
                      ],
                    ),
                  );
                }
                
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
                    final wishlistProvider = context.watch<WishlistProvider>();
                    final isWishlisted = wishlistProvider.isInWishlist(shoe['_id']);
                    
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
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
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                                      color: isWishlisted ? Colors.red : Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => _onToggleWishlist(shoe),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
            SizedBox(height: 16),
            Text(
              'Start shopping to add items to your cart!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Calculate total
    double total = 0;
    for (var item in cartItems) {
      final price = (item['price'] ?? 0).toDouble();
      final quantity = (item['quantity'] ?? 1).toInt();
      total += price * quantity;
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shoe = cartItems[index];
              final quantity = shoe['quantity'] ?? 1;
              final price = (shoe['price'] ?? 0).toDouble();
              final itemTotal = price * quantity;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
                            ? Image.network(
                                shoe['image'].toString().startsWith('http')
                                    ? shoe['image']
                                    : 'http://10.0.2.2:3000/public/uploads/${shoe['image']}',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              shoe['name'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Brand: ${shoe['brand'] ?? ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (shoe['selectedSize'] != null)
                              Text(
                                'Size: ${shoe['selectedSize']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            if (shoe['selectedColor'] != null && shoe['selectedColor'].isNotEmpty)
                              Text(
                                'Color: ${shoe['selectedColor']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '24${itemTotal.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: quantity > 1 
                                          ? () {
                                              final updatedShoe = Map<String, dynamic>.from(shoe);
                                              updatedShoe['quantity'] = quantity - 1;
                                              context.read<CartProvider>().removeFromCart(shoe);
                                              context.read<CartProvider>().addToCart(updatedShoe);
                                            }
                                          : null,
                                      icon: Icon(Icons.remove_circle_outline, 
                                        color: quantity > 1 ? Theme.of(context).primaryColor : Colors.grey),
                                      iconSize: 20,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final updatedShoe = Map<String, dynamic>.from(shoe);
                                        updatedShoe['quantity'] = quantity + 1;
                                        context.read<CartProvider>().removeFromCart(shoe);
                                        context.read<CartProvider>().addToCart(updatedShoe);
                                      },
                                      icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Remove Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Item'),
                              content: Text('Are you sure you want to remove ${shoe['name']} from your cart?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<CartProvider>().removeFromCart(shoe);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Checkout Section
        Container(
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '24${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Free',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCheckoutDialog(context, total),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text('Proceed to Checkout (24${total.toStringAsFixed(2)})'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCheckoutDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: 24${total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Payment methods:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Credit Card'),
              ],
            ),
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Bank Transfer'),
              ],
            ),
            Row(
              children: [
                Icon(Icons.payment, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Khalti'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCheckout(context, total);
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, double total) {
    // Get cart items
    final cartItems = context.read<CartProvider>().cartItems;
    
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create a combined product data for payment
    final combinedProduct = {
      'name': 'Cart Items (${cartItems.length})',
      'price': total,
      'quantity': cartItems.length,
      'items': cartItems,
    };

    // Navigate to payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          product: combinedProduct,
          totalAmount: total,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Mock user profile data
    setState(() {
      _userProfile = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '+977 9841234567',
        'address': 'Kathmandu, Nepal',
        'avatar': null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: _userProfile?['avatar'] != null
                      ? ClipOval(
                          child: Image.network(
                            _userProfile!['avatar'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userProfile?['name'] ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?['email'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Edit profile functionality
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Profile Options
          _buildProfileOption(
            icon: Icons.shopping_bag,
            title: 'My Orders',
            subtitle: 'View your order history',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderTrackingScreen(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.favorite,
            title: 'Wishlist',
            subtitle: 'Your saved items',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistScreen(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.location_on,
            title: 'Shipping Address',
            subtitle: 'Manage your addresses',
            onTap: () {
              // Navigate to address management
            },
          ),
          _buildProfileOption(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          _buildProfileOption(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage your notifications',
            onTap: () {
              // Navigate to notifications
            },
          ),
          _buildProfileOption(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Manage your account security',
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          _buildProfileOption(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help
            },
          ),
          const SizedBox(height: 16),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await SharedPrefService.clearAuthData();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistItems = context.watch<WishlistProvider>().wishlistItems;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: wishlistItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Wishlist',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your wishlist is empty.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Start adding items to your wishlist!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shoe = wishlistItems[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (shoe['image'] != null && shoe['image'].toString().isNotEmpty)
                              ? Image.network(
                                  shoe['image'].toString().startsWith('http')
                                      ? shoe['image']
                                      : 'http://10.0.2.2:3000/public/uploads/${shoe['image']}',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shoe['name'] ?? '',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Brand: ${shoe['brand'] ?? ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '24${shoe['price'] ?? ''}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                                context.read<WishlistProvider>().removeFromWishlist(shoe);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed ${shoe['name']} from wishlist!')),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<CartProvider>().addToCart(shoe);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${shoe['name']} to cart!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: const Text('Add to Cart'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo and Title
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ShoeLocker',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // About Section
          Text(
            'About ShoeLocker',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
          
          // Features Section
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.shopping_bag, 'Wide Selection', 'Browse through thousands of shoes from top brands'),
          _buildFeatureItem(Icons.security, 'Secure Payments', 'Multiple payment options with bank-level security'),
          _buildFeatureItem(Icons.local_shipping, 'Fast Shipping', 'Free shipping on orders over \$50'),
          _buildFeatureItem(Icons.support_agent, '24/7 Support', 'Get help anytime with our customer support'),
          _buildFeatureItem(Icons.verified, 'Quality Guarantee', 'All products are authentic and quality assured'),
          _buildFeatureItem(Icons.assignment_return, 'Easy Returns', '30-day return policy for your peace of mind'),
          
          const SizedBox(height: 32),
          
          // Contact Information
          Text(
            'Contact Us',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email, 'Email', 'support@shoelocker.com'),
          _buildContactItem(Icons.phone, 'Phone', '+977 1-4-123456'),
          _buildContactItem(Icons.location_on, 'Address', 'Kathmandu, Nepal'),
          _buildContactItem(Icons.access_time, 'Business Hours', 'Mon-Sat: 9:00 AM - 6:00 PM'),
          
          const SizedBox(height: 32),
          
          // Social Media
          Text(
            'Follow Us',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.facebook, 'Facebook', Colors.blue),
              _buildSocialButton(Icons.camera_alt, 'Instagram', Colors.purple),
              _buildSocialButton(Icons.flutter_dash, 'Twitter', Colors.lightBlue),
              _buildSocialButton(Icons.play_circle, 'YouTube', Colors.red),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Legal Links
          Text(
            'Legal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLegalLink('Privacy Policy'),
          _buildLegalLink('Terms of Service'),
          _buildLegalLink('Return Policy'),
          _buildLegalLink('Shipping Policy'),
          
          const SizedBox(height: 24),
          
          // Copyright
          Center(
            child: Text(
              '© 2024 ShoeLocker. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLegalLink(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: () {
          // Navigate to legal page
        },
        child: Text(title),
      ),
    );
  }
}

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    // Mock orders data
    setState(() {
      _orders = [
        {
          'id': 'ORD-001',
          'date': '2024-01-15',
          'status': 'Delivered',
          'total': 2400.0,
          'items': [
            {'name': 'Nike Air Max 270', 'quantity': 1, 'price': 2400.0}
          ],
          'tracking': [
            {'status': 'Order Placed', 'date': '2024-01-15', 'completed': true},
            {'status': 'Processing', 'date': '2024-01-16', 'completed': true},
            {'status': 'Shipped', 'date': '2024-01-17', 'completed': true},
            {'status': 'Delivered', 'date': '2024-01-18', 'completed': true},
          ]
        },
        {
          'id': 'ORD-002',
          'date': '2024-01-20',
          'status': 'In Transit',
          'total': 1800.0,
          'items': [
            {'name': 'Adidas Ultraboost', 'quantity': 1, 'price': 1800.0}
          ],
          'tracking': [
            {'status': 'Order Placed', 'date': '2024-01-20', 'completed': true},
            {'status': 'Processing', 'date': '2024-01-21', 'completed': true},
            {'status': 'Shipped', 'date': '2024-01-22', 'completed': true},
            {'status': 'In Transit', 'date': '2024-01-23', 'completed': false},
            {'status': 'Delivered', 'date': '', 'completed': false},
          ]
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Orders Yet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              separatorBuilder: (context, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['id'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order['status'],
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ordered on ${order['date']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        
                        // Order Items
                        ...order['items'].map<Widget>((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['name']} x${item['quantity']}'),
                              Text('24${item['price']}'),
                            ],
                          ),
                        )).toList(),
                        
                        const Divider(),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '24${order['total']}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tracking Timeline
                        Text(
                          'Order Status',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...order['tracking'].asMap().entries.map<Widget>((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          final isLast = index == order['tracking'].length - 1;
                          
                          return Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: step['completed'] ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: step['completed']
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: step['completed'] ? Colors.green : Colors.grey,
                                  margin: const EdgeInsets.only(left: 11),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['status'],
                                      style: TextStyle(
                                        fontWeight: step['completed'] ? FontWeight.bold : FontWeight.normal,
                                        color: step['completed'] ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                    if (step['date'].isNotEmpty)
                                      Text(
                                        step['date'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: step['completed'] ? Colors.grey[600] : Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // View order details
                                },
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Details'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Track order
                                },
                                icon: const Icon(Icons.local_shipping),
                                label: const Text('Track Order'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in transit':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 
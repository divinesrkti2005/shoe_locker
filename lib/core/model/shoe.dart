class Shoe {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final List<String> colors;
  final String description;
  final double rating;
  final int reviews;

  Shoe({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
    required this.description,
    required this.rating,
    required this.reviews,
  });

  // Sample data
  static List<Shoe> sampleShoes = [
    Shoe(
      id: '1',
      name: 'Nike Air Max 270',
      brand: 'Nike',
      price: 149.99,
      imageUrl: 'assets/images/shoes/nike_air_max_270.jpg',
      sizes: ['40', '41', '42', '43', '44', '45'],
      colors: ['Black', 'White', 'Red'],
      description: 'The Nike Air Max 270 delivers visible cushioning under every step with a huge Air unit and a super-soft foam midsole.',
      rating: 4.5,
      reviews: 128,
    ),
    Shoe(
      id: '2',
      name: 'Adidas Ultraboost',
      brand: 'Adidas',
      price: 179.99,
      imageUrl: 'assets/images/shoes/adidas_ultraboost.jpg',
      sizes: ['40', '41', '42', '43', '44'],
      colors: ['White', 'Black', 'Grey'],
      description: 'Experience epic energy with the adidas Ultraboost. These running shoes deliver unmatched comfort and responsive cushioning.',
      rating: 4.8,
      reviews: 245,
    ),
    Shoe(
      id: '3',
      name: 'Puma RS-X',
      brand: 'Puma',
      price: 129.99,
      imageUrl: 'assets/images/shoes/puma_rsx.jpg',
      sizes: ['41', '42', '43', '44', '45'],
      colors: ['Blue', 'White', 'Black'],
      description: 'The RS-X reinvents the classic RS running shoe with a bulky design and bold color combinations.',
      rating: 4.3,
      reviews: 89,
    ),
  ];
} 
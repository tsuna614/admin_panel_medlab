class Product {
  final String id;
  final String name;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String? dosageForm; // e.g., Tablet, Syrup, Injection
  final String? strength; // e.g., "500mg"
  final String? category; // e.g., Antibiotic, Painkiller
  final List<String>? ingredients;
  final double price;
  final int stock;
  final bool prescriptionRequired;
  final String? manufacturer;
  final String? expiryDate; // Or use Date if your API supports it
  final String? instructions;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.description,
    this.imageUrl,
    this.dosageForm,
    this.strength,
    this.category,
    this.ingredients,
    required this.price,
    required this.stock,
    required this.prescriptionRequired,
    this.manufacturer,
    this.expiryDate,
    this.instructions,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      dosageForm: json['dosageForm'] as String?,
      strength: json['strength'] as String?,
      category: json['category'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      prescriptionRequired: json['prescriptionRequired'] as bool,
      manufacturer: json['manufacturer'] as String?,
      expiryDate: json['expiryDate'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl,
      'dosageForm': dosageForm,
      'strength': strength,
      'category': category,
      'ingredients': ingredients,
      'price': price,
      'stock': stock,
      'prescriptionRequired': prescriptionRequired,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate,
      'instructions': instructions,
    };
  }
}

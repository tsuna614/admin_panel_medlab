enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class OrderItem {
  final String productId;
  final String productNameSnapshot;
  final int quantity;
  final double
  priceAtPurchase; // Renamed variable to match logic, but JSON key is different
  final String? imageUrlSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.priceAtPurchase,
    this.imageUrlSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  double get subtotal => quantity * priceAtPurchase;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productNameSnapshot: json['productNameSnapshot'] as String,
      quantity: (json['quantity'] as num).toInt(),
      priceAtPurchase: (json['priceSnapshot'] as num).toDouble(),
      imageUrlSnapshot: json['imageUrlSnapshot'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

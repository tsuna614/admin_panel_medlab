class ShippingAddress {
  final String recipientName;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phoneNumber;

  ShippingAddress({
    required this.recipientName,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phoneNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      recipientName: json['recipientName'] as String? ?? '',
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}

class OrderItem {
  final String productId;
  final String productNameSnapshot;
  final int quantity;
  final double
  priceAtPurchase; // Renamed variable to match logic, but JSON key is different
  final String? imageUrlSnapshot;
  final String createdAt;
  final String updatedAt;

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
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      // createdAt: DateTime.parse(json['createdAt'] as String),
      // updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String userEmail;
  final String orderNumber;
  final List<OrderItem> items;
  final double totalAmount;
  final double shippingCost;
  final double taxAmount;
  final String status;
  final ShippingAddress shippingAddress;
  final String paymentMethodDetails;
  final String createdAt;
  final String updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.orderNumber,
    required this.items,
    required this.totalAmount,
    this.shippingCost = 0.0,
    this.taxAmount = 0.0,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethodDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String,
      userId:
          json['userId']["_id"]
              as String, // note, this works with the get api /orders only, it doesn't work with /orders/getAllUserOrder because user is not populate there in the backend
      userEmail: json['userId']['email'] as String,
      orderNumber: json['orderNumber'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: ShippingAddress.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
      paymentMethodDetails: json['paymentMethodDetails'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      // createdAt: DateTime.parse(json['createdAt'] as String),
      // updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

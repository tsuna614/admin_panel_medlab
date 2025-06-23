class Voucher {
  final String id;
  final String title;
  final String description;
  final String code;
  final double discount;
  final String expiryDate;
  final bool isVisibleToUsers;

  Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discount,
    required this.expiryDate,
    this.isVisibleToUsers = true,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      code: json['code'] as String,
      discount: (json['discount'] as num).toDouble(),
      expiryDate: json['expiryDate'] as String,
      isVisibleToUsers: json['isVisibleToUsers'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'code': code,
      'discount': discount,
      'expiryDate': expiryDate,
      'isVisibleToUsers': isVisibleToUsers,
    };
  }
}

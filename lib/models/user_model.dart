class Address {
  final String address;
  final String street;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;

  Address({
    required this.address,
    required this.street,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String,
    );
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? number;
  final String? userType;
  final String? receiptsId;
  final Address? address;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.number,
    this.userType,
    this.receiptsId,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      number: json['number'] as String?,
      userType: json['userType'] as String?,
      receiptsId: json['receiptsId'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}

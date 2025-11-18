class Coupon {
  final String id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final List<String> categories;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.validFrom,
    required this.validUntil,
    required this.categories,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'],
      code: json['code'],
      description: json['description'],
      discountType: json['discountType'],
      discountValue: json['discountValue'].toDouble(),
      minOrderAmount: json['minOrderAmount'].toDouble(),
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      categories:
          List<String>.from(json['categories'].map((cat) => cat['name'])),
    );
  }
}

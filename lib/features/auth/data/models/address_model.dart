import 'package:equatable/equatable.dart';

/// Model Địa chỉ nhận hàng – SQLite
class Address extends Equatable {
  final String id;
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;

  const Address({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    this.ward = '',
    this.district = '',
    this.city = '',
    this.isDefault = false,
  });

  String get fullAddress => '$streetAddress, $ward, $district, $city';

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      recipientName: map['recipient_name'] as String,
      phoneNumber: map['phone_number'] as String,
      streetAddress: map['street_address'] as String,
      ward: map['ward'] as String? ?? '',
      district: map['district'] as String? ?? '',
      city: map['city'] as String? ?? '',
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'recipient_name': recipientName,
        'phone_number': phoneNumber,
        'street_address': streetAddress,
        'ward': ward,
        'district': district,
        'city': city,
        'is_default': isDefault ? 1 : 0,
      };

  Address copyWith({
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? ward,
    String? district,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id];
}

/// Alias cho Address để tương thích với AddressModel
typedef AddressModel = Address;

import 'package:hive/hive.dart';

part 'service.g.dart';

@HiveType(typeId: 0)
class Service {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String serviceName;

  @HiveField(2)
  final String serviceType;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String paymentPolicy;

  @HiveField(5)
  final List<String> mediaUrls;

  @HiveField(6)
  final double averageRating;

  @HiveField(7)
  final int reviewCount;

  @HiveField(8)
  final double basePrice;

  @HiveField(9)
  final String vendorId;

  @HiveField(10)
  final String vendorName;

  @HiveField(11)
  final String phone;

  Service({
    required this.id,
    required this.serviceName,
    required this.serviceType,
    required this.description,
    required this.paymentPolicy,
    required this.mediaUrls,
    required this.averageRating,
    required this.reviewCount,
    required this.basePrice,
    required this.vendorId,
    required this.vendorName,
    required this.phone,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      paymentPolicy: json['paymentPolicy']?.toString() ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      averageRating:
          (json['averageRating'] is num)
              ? json['averageRating'].toDouble()
              : 0.0,
      reviewCount:
          (json['reviewCount'] is num) ? json['reviewCount'] as int : 0,
      basePrice:
          (json['basePrice'] is num) ? json['basePrice'].toDouble() : 0.0,
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? 'Not available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceName': serviceName,
      'serviceType': serviceType,
      'description': description,
      'paymentPolicy': paymentPolicy,
      'mediaUrls': mediaUrls,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'basePrice': basePrice,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'phone': phone,
    };
  }
}

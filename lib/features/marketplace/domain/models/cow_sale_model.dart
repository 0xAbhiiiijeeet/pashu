class CowSaleModel {
  final String id;
  final String userId;
  final CowDetails cowDetails;
  final String status; // pending, approved, rejected, sold
  final DateTime createdAt;
  final DateTime updatedAt;
  final SellerInfo? seller;

  CowSaleModel({
    required this.id,
    required this.userId,
    required this.cowDetails,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
  });

  factory CowSaleModel.fromJson(Map<String, dynamic> json) {
    // Determine userId from 'userId' or 'seller' (if it's a string)
    String userId = json['userId'] ?? '';
    SellerInfo? seller;

    if (json['seller'] != null) {
      if (json['seller'] is Map<String, dynamic>) {
        seller = SellerInfo.fromJson(json['seller']);
        userId = seller.id; // Use seller ID if available in object
      } else if (json['seller'] is String) {
        userId = json['seller'];
      }
    }

    return CowSaleModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      cowDetails: CowDetails.fromJson(json['cowDetails'] ?? {}),
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      seller: seller,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'cowDetails': cowDetails.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (seller != null) 'seller': seller!.toJson(),
    };
  }
}

class CowDetails {
  final String animalType;
  final String breed;
  final int age;
  final double price;
  final double milkYield;
  final List<String> images;
  final String description;

  CowDetails({
    this.animalType = 'cow',
    required this.breed,
    required this.age,
    required this.price,
    required this.milkYield,
    required this.images,
    required this.description,
  });

  factory CowDetails.fromJson(Map<String, dynamic> json) {
    return CowDetails(
      animalType: json['animalType']?.toString() ?? 'cow',
      breed: json['breed'] ?? '',
      age: json['age'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      milkYield: (json['yield'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animalType': animalType,
      'breed': breed,
      'age': age,
      'price': price,
      'yield': milkYield,
      'images': images,
      'description': description,
    };
  }
}

class SellerInfo {
  final String id;
  final String name;
  final String phone;
  final String? address;

  SellerInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      if (address != null) 'address': address,
    };
  }
}

enum AnimalType { cow, buffalo, both }

class CattleListing {
  final String id;
  final String name;
  final AnimalType type;
  final int priceMin;
  final int priceMax;
  final double milkCapacity; // litres/day
  final String location;
  final String breed;
  final String imageUrl;
  final bool isVerified;
  final String? sellerId;
  final DateTime? createdAt;

  const CattleListing({
    required this.id,
    required this.name,
    required this.type,
    required this.priceMin,
    required this.priceMax,
    required this.milkCapacity,
    required this.location,
    required this.breed,
    required this.imageUrl,
    this.isVerified = false,
    this.sellerId,
    this.createdAt,
  });

  String get typeLabel => type == AnimalType.cow
      ? 'गाय'
      : type == AnimalType.buffalo
          ? 'भैंस'
          : 'गाय / भैंस';

  factory CattleListing.fromJson(Map<String, dynamic> json) {
    return CattleListing(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: _parseAnimalType(json['type']),
      priceMin: json['priceMin'] ?? 0,
      priceMax: json['priceMax'] ?? 0,
      milkCapacity: (json['milkCapacity'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      breed: json['breed'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
      sellerId: json['sellerId'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'milkCapacity': milkCapacity,
      'location': location,
      'breed': breed,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      if (sellerId != null) 'sellerId': sellerId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  static AnimalType _parseAnimalType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'cow':
        case 'गाय':
          return AnimalType.cow;
        case 'buffalo':
        case 'भैंस':
          return AnimalType.buffalo;
        case 'both':
          return AnimalType.both;
        default:
          return AnimalType.cow;
      }
    }
    return AnimalType.cow;
  }

  CattleListing copyWith({
    String? id,
    String? name,
    AnimalType? type,
    int? priceMin,
    int? priceMax,
    double? milkCapacity,
    String? location,
    String? breed,
    String? imageUrl,
    bool? isVerified,
    String? sellerId,
    DateTime? createdAt,
  }) {
    return CattleListing(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      milkCapacity: milkCapacity ?? this.milkCapacity,
      location: location ?? this.location,
      breed: breed ?? this.breed,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Dummy data for development
final List<CattleListing> dummyListings = [
  CattleListing(
    id: '1',
    name: 'HF क्रॉस गाय',
    type: AnimalType.cow,
    priceMin: 90000,
    priceMax: 110000,
    milkCapacity: 14,
    location: 'Pune, Maharashtra',
    breed: 'HF क्रॉस',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cow_female_black_white.jpg/320px-Cow_female_black_white.jpg',
    isVerified: true,
  ),
  CattleListing(
    id: '2',
    name: 'मुर्रा भैंस',
    type: AnimalType.buffalo,
    priceMin: 120000,
    priceMax: 150000,
    milkCapacity: 10,
    location: 'Nashik, Maharashtra',
    breed: 'मुर्रा',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Murrah_buffalo.jpg/320px-Murrah_buffalo.jpg',
    isVerified: true,
  ),
  CattleListing(
    id: '3',
    name: 'गिर गाय',
    type: AnimalType.cow,
    priceMin: 80000,
    priceMax: 95000,
    milkCapacity: 8,
    location: 'Nagpur, Maharashtra',
    breed: 'गिर',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Gir_cow.jpg/320px-Gir_cow.jpg',
    isVerified: false,
  ),
  CattleListing(
    id: '4',
    name: 'जर्सी क्रॉस',
    type: AnimalType.cow,
    priceMin: 60000,
    priceMax: 80000,
    milkCapacity: 12,
    location: 'Kolhapur, Maharashtra',
    breed: 'जर्सी',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cow_female_black_white.jpg/320px-Cow_female_black_white.jpg',
    isVerified: false,
  ),
  CattleListing(
    id: '5',
    name: 'नीली रावी भैंस',
    type: AnimalType.buffalo,
    priceMin: 100000,
    priceMax: 500000,
    milkCapacity: 13,
    location: 'Aurangabad, Maharashtra',
    breed: 'नीली रावी',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Murrah_buffalo.jpg/320px-Murrah_buffalo.jpg',
    isVerified: true,
  ),
];

const List<String> dummyBreeds = [
  'सभी नस्लें',
  'HF क्रॉस',
  'मुर्रा',
  'गिर',
  'जर्सी',
  'नीली रावी',
  'साहीवाल',
];

const List<String> dummyLocations = [
  'सभी स्थान',
  'Pune',
  'Nashik',
  'Nagpur',
  'Kolhapur',
  'Aurangabad',
];
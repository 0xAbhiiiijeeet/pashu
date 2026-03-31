class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String? address;
  final String? milkTypePreference;
  final bool isActive;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.milkTypePreference,
    this.isActive = true,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      address: json['address']?.toString(),
      milkTypePreference: json['milkTypePreference']?.toString(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (milkTypePreference != null)
        'milkTypePreference': milkTypePreference,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    String? milkTypePreference,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      milkTypePreference: milkTypePreference ?? this.milkTypePreference,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

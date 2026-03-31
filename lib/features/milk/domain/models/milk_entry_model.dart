class MilkEntry {
  final String id;
  final String? customerId;
  final String customerName;
  final String? customerPhone;
  final double cowMilk;
  final double buffaloMilk;
  final double? pricePerLiter;
  final double? explicitTotalAmount;
  final String? shift;
  final DateTime date;
  final DateTime createdAt;

  const MilkEntry({
    required this.id,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.cowMilk,
    required this.buffaloMilk,
    this.pricePerLiter,
    this.explicitTotalAmount,
    this.shift,
    required this.date,
    required this.createdAt,
  });

  double get totalLiters => cowMilk + buffaloMilk;
  
  double? get totalAmount =>
      explicitTotalAmount ??
      (pricePerLiter != null ? totalLiters * pricePerLiter! : null);

  factory MilkEntry.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    final customerMap = customer is Map<String, dynamic>
        ? customer
        : customer is Map
            ? Map<String, dynamic>.from(customer)
            : <String, dynamic>{};

    final milkType = json['milkType']?.toString().toLowerCase();
    final quantity = _toDouble(json['quantity']);

    return MilkEntry(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: json['customerId']?.toString() ??
          customerMap['_id']?.toString() ??
          customerMap['id']?.toString(),
      customerName: json['customerName']?.toString() ??
          customerMap['name']?.toString() ??
          '',
      customerPhone: customerMap['phoneNumber']?.toString() ??
          customerMap['phone']?.toString(),
      cowMilk: milkType == 'cow'
          ? quantity
          : _toDouble(json['cowMilk']),
      buffaloMilk: milkType == 'buffalo'
          ? quantity
          : _toDouble(json['buffaloMilk']),
      pricePerLiter: json['pricePerLiter'] == null
          ? null
          : _toDouble(json['pricePerLiter']),
      explicitTotalAmount: json['totalPrice'] != null
          ? _toDouble(json['totalPrice'])
          : (json['totalAmount'] != null
              ? _toDouble(json['totalAmount'])
              : null),
      shift: json['shift']?.toString(),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? json['date'].toString(),
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (customerId != null) 'customerId': customerId,
      'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      'cowMilk': cowMilk,
      'buffaloMilk': buffaloMilk,
      if (pricePerLiter != null) 'pricePerLiter': pricePerLiter,
      if (explicitTotalAmount != null) 'totalAmount': explicitTotalAmount,
      if (shift != null) 'shift': shift,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MilkEntry copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    double? cowMilk,
    double? buffaloMilk,
    double? pricePerLiter,
    double? explicitTotalAmount,
    String? shift,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return MilkEntry(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      cowMilk: cowMilk ?? this.cowMilk,
      buffaloMilk: buffaloMilk ?? this.buffaloMilk,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      explicitTotalAmount: explicitTotalAmount ?? this.explicitTotalAmount,
      shift: shift ?? this.shift,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

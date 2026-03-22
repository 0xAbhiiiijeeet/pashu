class MilkEntry {
  final String id;
  final String customerName;
  final double cowMilk;
  final double buffaloMilk;
  final double? pricePerLiter;
  final DateTime date;
  final DateTime createdAt;

  const MilkEntry({
    required this.id,
    required this.customerName,
    required this.cowMilk,
    required this.buffaloMilk,
    this.pricePerLiter,
    required this.date,
    required this.createdAt,
  });

  double get totalLiters => cowMilk + buffaloMilk;
  
  double? get totalAmount =>
      pricePerLiter != null ? totalLiters * pricePerLiter! : null;

  factory MilkEntry.fromJson(Map<String, dynamic> json) {
    return MilkEntry(
      id: json['_id'] ?? json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      cowMilk: (json['cowMilk'] ?? 0).toDouble(),
      buffaloMilk: (json['buffaloMilk'] ?? 0).toDouble(),
      pricePerLiter: json['pricePerLiter']?.toDouble(),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt'] ?? json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'cowMilk': cowMilk,
      'buffaloMilk': buffaloMilk,
      if (pricePerLiter != null) 'pricePerLiter': pricePerLiter,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MilkEntry copyWith({
    String? id,
    String? customerName,
    double? cowMilk,
    double? buffaloMilk,
    double? pricePerLiter,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return MilkEntry(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      cowMilk: cowMilk ?? this.cowMilk,
      buffaloMilk: buffaloMilk ?? this.buffaloMilk,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
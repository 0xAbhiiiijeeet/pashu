class MilkCalculationModel {
  final String id;
  final String userId;
  final int animalCount;
  final double averageMilkPerAnimal;
  final double totalMilkProduced;
  final double homeConsumption;
  final double totalMilkSold;
  final double pricePerLiter;
  final double totalDailyIncome;
  final DateTime calculationDate;

  MilkCalculationModel({
    required this.id,
    required this.userId,
    required this.animalCount,
    required this.averageMilkPerAnimal,
    required this.totalMilkProduced,
    required this.homeConsumption,
    required this.totalMilkSold,
    required this.pricePerLiter,
    required this.totalDailyIncome,
    required this.calculationDate,
  });

  factory MilkCalculationModel.fromJson(Map<String, dynamic> json) {
    // userId can be an ID string or a populated user object
    String userId = '';
    final rawUser = json['user'] ?? json['userId'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map<String, dynamic>) {
      userId = rawUser['_id'] as String? ?? rawUser['id'] as String? ?? '';
    }

    return MilkCalculationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      animalCount: json['animalCount'] ?? 0,
      averageMilkPerAnimal: (json['averageMilkPerAnimal'] ?? 0).toDouble(),
      totalMilkProduced: (json['totalMilkProduced'] ?? 0).toDouble(),
      homeConsumption: (json['homeConsumption'] ?? 0).toDouble(),
      totalMilkSold: (json['totalMilkSold'] ?? 0).toDouble(),
      pricePerLiter: (json['pricePerLiter'] ?? 0).toDouble(),
      totalDailyIncome: (json['totalDailyIncome'] ?? 0).toDouble(),
      calculationDate: DateTime.parse(
        json['calculationDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'animalCount': animalCount,
      'averageMilkPerAnimal': averageMilkPerAnimal,
      'totalMilkProduced': totalMilkProduced,
      'homeConsumption': homeConsumption,
      'totalMilkSold': totalMilkSold,
      'pricePerLiter': pricePerLiter,
      'totalDailyIncome': totalDailyIncome,
      'calculationDate': calculationDate.toIso8601String(),
    };
  }
}

class MilkCalculationInput {
  final int animalCount;
  final double averageMilkPerAnimal;
  final double homeConsumption;
  final double pricePerLiter;

  MilkCalculationInput({
    required this.animalCount,
    required this.averageMilkPerAnimal,
    required this.homeConsumption,
    required this.pricePerLiter,
  });

  Map<String, dynamic> toJson() {
    return {
      'animalCount': animalCount,
      'averageMilkPerAnimal': averageMilkPerAnimal,
      'homeConsumption': homeConsumption,
      'pricePerLiter': pricePerLiter,
    };
  }
}

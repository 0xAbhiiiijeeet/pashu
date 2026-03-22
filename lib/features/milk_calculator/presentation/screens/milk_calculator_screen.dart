import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/milk_calculator_provider.dart';
import '../../domain/models/milk_calculation_model.dart';
import '../widgets/calculation_history_list.dart';
import '../../../milk/presentation/screens/milk_khata_dashboard_screen.dart';

class MilkCalculatorScreen extends StatefulWidget {
  const MilkCalculatorScreen({super.key});

  @override
  State<MilkCalculatorScreen> createState() => _MilkCalculatorScreenState();
}

class _MilkCalculatorScreenState extends State<MilkCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalCountController = TextEditingController();
  final _avgMilkController = TextEditingController();
  final _homeConsumptionController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isSaving = false;
  bool _showResult = false;
  MilkCalculationModel? _localCalculation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilkCalculatorProvider>().fetchHistory();
    });

    _animalCountController.addListener(_calculateLocally);
    _avgMilkController.addListener(_calculateLocally);
    _homeConsumptionController.addListener(_calculateLocally);
    _priceController.addListener(_calculateLocally);
  }

  void _calculateLocally() {
    if (_animalCountController.text.isEmpty ||
        _avgMilkController.text.isEmpty ||
        _homeConsumptionController.text.isEmpty ||
        _priceController.text.isEmpty) {
      if (_showResult) {
        setState(() {
          _showResult = false;
          _localCalculation = null;
        });
      }
      return;
    }

    final animalCount = int.tryParse(_animalCountController.text.trim()) ?? 0;
    final avgMilk = double.tryParse(_avgMilkController.text.trim()) ?? 0;
    final homeConsumption =
        double.tryParse(_homeConsumptionController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    final totalProduced = animalCount * avgMilk;
    final totalSold = totalProduced - homeConsumption;
    final dailyIncome = totalSold * price;

    setState(() {
      _localCalculation = MilkCalculationModel(
        id: 'local',
        userId: 'local',
        animalCount: animalCount,
        averageMilkPerAnimal: avgMilk,
        totalMilkProduced: totalProduced,
        homeConsumption: homeConsumption,
        totalMilkSold: totalSold,
        pricePerLiter: price,
        totalDailyIncome: dailyIncome,
        calculationDate: DateTime.now(),
      );
      _showResult = true;
    });
  }

  @override
  void dispose() {
    _animalCountController.removeListener(_calculateLocally);
    _avgMilkController.removeListener(_calculateLocally);
    _homeConsumptionController.removeListener(_calculateLocally);
    _priceController.removeListener(_calculateLocally);
    _animalCountController.dispose();
    _avgMilkController.dispose();
    _homeConsumptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final input = MilkCalculationInput(
      animalCount: int.parse(_animalCountController.text.trim()),
      averageMilkPerAnimal: double.parse(_avgMilkController.text.trim()),
      homeConsumption: double.parse(_homeConsumptionController.text.trim()),
      pricePerLiter: double.parse(_priceController.text.trim()),
    );

    final provider = context.read<MilkCalculatorProvider>();
    final success = await provider.calculate(input);

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save record'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _animalCountController.clear();
    _avgMilkController.clear();
    _homeConsumptionController.clear();
    _priceController.clear();
    setState(() => _showResult = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.milkCalculator),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MilkKhataDashboardScreen(),
                ),
              );
            },
            tooltip: 'दूध खाता',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalculationHistoryList(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Enter Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MilkKhataDashboardScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.book, size: 16),
                            label: const Text('दूध खाता'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Animal Count
                      TextFormField(
                        controller: _animalCountController,
                        decoration: InputDecoration(
                          labelText: 'Number of Animals',
                          prefixIcon: const Icon(Icons.pets),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final count = int.tryParse(value);
                          if (count == null || count <= 0) {
                            return 'Enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Average Milk per Animal
                      TextFormField(
                        controller: _avgMilkController,
                        decoration: InputDecoration(
                          labelText: 'Avg Milk per Animal (L)',
                          prefixIcon: const Icon(Icons.water_drop),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final milk = double.tryParse(value);
                          if (milk == null || milk < 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Home Consumption
                      TextFormField(
                        controller: _homeConsumptionController,
                        decoration: InputDecoration(
                          labelText: 'Home Consumption (L)',
                          prefixIcon: const Icon(Icons.home),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final consumption = double.tryParse(value);
                          if (consumption == null || consumption < 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Price per Liter
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price per Liter (₹)',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving || !_showResult ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Record',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              // Result Section
              if (_showResult && _localCalculation != null) ...[
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    final calc = _localCalculation;
                    if (calc == null) return const SizedBox();

                    return Card(
                      elevation: 4,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Results',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _reset,
                                  tooltip: 'New Calculation',
                                ),
                              ],
                            ),
                            const Divider(),
                            _ResultRow(
                              label: 'Total Milk Produced',
                              value:
                                  '${calc.totalMilkProduced.toStringAsFixed(1)} L',
                            ),
                            _ResultRow(
                              label: 'Home Consumption',
                              value:
                                  '${calc.homeConsumption.toStringAsFixed(1)} L',
                            ),
                            _ResultRow(
                              label: 'Milk Sold',
                              value:
                                  '${calc.totalMilkSold.toStringAsFixed(1)} L',
                            ),
                            const Divider(),
                            _ResultRow(
                              label: 'Daily Income',
                              value:
                                  '₹${calc.totalDailyIncome.toStringAsFixed(0)}',
                              isHighlight: true,
                            ),
                            _ResultRow(
                              label: 'Monthly Income (Est.)',
                              value:
                                  '₹${(calc.totalDailyIncome * 30).toStringAsFixed(0)}',
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

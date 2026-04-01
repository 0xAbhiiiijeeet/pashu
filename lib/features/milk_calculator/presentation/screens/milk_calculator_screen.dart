import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/milk_calculation_model.dart';
import '../providers/milk_calculator_provider.dart';
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

    if (!mounted) return;
    setState(() => _isSaving = false);
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.saveRecord
              : (provider.errorMessage ?? l10n.failedToSaveRecord),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _reset() {
    _formKey.currentState?.reset();
    _animalCountController.clear();
    _avgMilkController.clear();
    _homeConsumptionController.clear();
    _priceController.clear();
    setState(() {
      _showResult = false;
      _localCalculation = null;
    });
  }

  Route<void> _noAnimationRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.milkCalculator),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: l10n.milkKhata,
            onPressed: () {
              Navigator.push(
                context,
                _noAnimationRoute(const MilkKhataDashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                _noAnimationRoute(const CalculationHistoryList()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Card(
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
                              Text(
                                l10n.enterDetails,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    _noAnimationRoute(
                                      const MilkKhataDashboardScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.book, size: 16),
                                label: Text(l10n.milkKhata),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _animalCountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.numberOfAnimals,
                              prefixIcon: const Icon(Icons.pets),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.required;
                              }
                              final count = int.tryParse(value);
                              if (count == null || count <= 0) {
                                return l10n.enterValidNumber;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _avgMilkController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.avgMilkPerAnimal,
                              prefixIcon: const Icon(Icons.water_drop),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.required;
                              }
                              final milk = double.tryParse(value);
                              if (milk == null || milk < 0) {
                                return l10n.enterValidAmount;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _homeConsumptionController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.homeConsumption,
                              prefixIcon: const Icon(Icons.home),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.required;
                              }
                              final consumption = double.tryParse(value);
                              if (consumption == null || consumption < 0) {
                                return l10n.enterValidAmount;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.pricePerLiter,
                              prefixIcon: const Icon(Icons.currency_rupee),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.required;
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return l10n.enterValidPrice;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _showResult && _localCalculation != null
                                ? _ResultsCard(
                                    calculation: _localCalculation!,
                                    onReset: _reset,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            l10n.saveRecord,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final MilkCalculationModel calculation;
  final VoidCallback onReset;

  const _ResultsCard({
    required this.calculation,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                Text(
                  l10n.results,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onReset,
                  tooltip: l10n.newCalculation,
                ),
              ],
            ),
            const Divider(),
            _ResultRow(
              label: l10n.totalMilkProduced,
              value: '${calculation.totalMilkProduced.toStringAsFixed(1)} L',
            ),
            _ResultRow(
              label: l10n.homeConsumption,
              value: '${calculation.homeConsumption.toStringAsFixed(1)} L',
            ),
            _ResultRow(
              label: l10n.milkSold,
              value: '${calculation.totalMilkSold.toStringAsFixed(1)} L',
            ),
            const Divider(),
            _ResultRow(
              label: l10n.dailyIncome,
              value: 'Rs ${calculation.totalDailyIncome.toStringAsFixed(0)}',
              isHighlight: true,
            ),
            _ResultRow(
              label: l10n.monthlyIncomeEst,
              value:
                  'Rs ${(calculation.totalDailyIncome * 30).toStringAsFixed(0)}',
              isHighlight: true,
            ),
          ],
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

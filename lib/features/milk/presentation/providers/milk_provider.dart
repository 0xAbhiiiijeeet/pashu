import 'package:flutter/material.dart';
import '../../domain/models/milk_entry_model.dart';
import '../../domain/models/customer_model.dart';

class MilkProvider extends ChangeNotifier {
  // State
  String _status = 'initial';
  List<MilkEntry> _entries = [];
  List<Customer> _customers = [];
  String? _errorMessage;

  // Getters
  String get status => _status;
  List<MilkEntry> get entries => _entries;
  List<Customer> get customers => _customers;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';

  // Get entries for a specific date
  List<MilkEntry> getEntriesForDate(DateTime date) {
    return _entries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  // Get summary for a specific date
  Map<String, dynamic> getSummaryForDate(DateTime date) {
    try {
      final dayEntries = getEntriesForDate(date);
      
      final customerCount = dayEntries.length;
      final totalCow = dayEntries.fold<double>(0, (sum, entry) => sum + entry.cowMilk);
      final totalBuffalo = dayEntries.fold<double>(0, (sum, entry) => sum + entry.buffaloMilk);
      final totalAmount = dayEntries.fold<double>(0, (sum, entry) => sum + (entry.totalAmount ?? 0));

      return {
        'customerCount': customerCount,
        'totalCow': totalCow,
        'totalBuffalo': totalBuffalo,
        'totalLiters': totalCow + totalBuffalo,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      debugPrint('Error in getSummaryForDate: $e');
      return {
        'customerCount': 0,
        'totalCow': 0.0,
        'totalBuffalo': 0.0,
        'totalLiters': 0.0,
        'totalAmount': 0.0,
      };
    }
  }

  // Initialize with dummy data (remove when backend is ready)
  Future<void> init() async {
    if (_status == 'loading') return; // Prevent multiple simultaneous inits
    
    _setLoading();
    
    try {
      debugPrint('🥛 Initializing MilkProvider...');
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Load dummy data
      _loadDummyData();
      
      _status = 'loaded';
      _errorMessage = null;
      debugPrint('✅ MilkProvider initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ MilkProvider initialization failed: $e');
      _setError(e.toString());
    }
  }

  void _loadDummyData() {
    _customers = [
      Customer(
        id: '1',
        name: 'राम कुमार',
        phoneNumber: '9876543210',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Customer(
        id: '2',
        name: 'सीता देवी',
        phoneNumber: '9876543211',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Customer(
        id: '3',
        name: 'मोहन लाल',
        phoneNumber: '9876543212',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Customer(
        id: '4',
        name: 'गीता बाई',
        phoneNumber: '9876543213',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Customer(
        id: '5',
        name: 'श्याम सिंह',
        phoneNumber: '9876543214',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    _entries = [
      MilkEntry(
        id: '1',
        customerName: 'राम कुमार',
        cowMilk: 3.5,
        buffaloMilk: 2.0,
        pricePerLiter: 50,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      MilkEntry(
        id: '2',
        customerName: 'सीता देवी',
        cowMilk: 0,
        buffaloMilk: 4.5,
        pricePerLiter: 60,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      MilkEntry(
        id: '3',
        customerName: 'मोहन लाल',
        cowMilk: 2.0,
        buffaloMilk: 0,
        pricePerLiter: 48,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      // Yesterday's entries
      MilkEntry(
        id: '4',
        customerName: 'राम कुमार',
        cowMilk: 3.0,
        buffaloMilk: 2.5,
        pricePerLiter: 50,
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MilkEntry(
        id: '5',
        customerName: 'गीता बाई',
        cowMilk: 1.5,
        buffaloMilk: 3.0,
        pricePerLiter: 55,
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Add new customer (TODO: integrate with backend)
  Future<bool> addCustomer({
    required String name,
    required String phoneNumber,
  }) async {
    _setLoading();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newCustomer = Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );
      
      _customers.add(newCustomer);
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Add new milk entry (TODO: integrate with backend)
  Future<bool> addMilkEntry({
    required String customerName,
    required double cowMilk,
    required double buffaloMilk,
    double? pricePerLiter,
    DateTime? date,
  }) async {
    _setLoading();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newEntry = MilkEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: customerName,
        cowMilk: cowMilk,
        buffaloMilk: buffaloMilk,
        pricePerLiter: pricePerLiter,
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      _entries.add(newEntry);
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Fetch entries for a specific date (TODO: integrate with backend)
  Future<void> fetchEntriesForDate(DateTime date) async {
    _setLoading();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For now, just filter existing entries
      // In real implementation, this would fetch from backend
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper methods
  void _setLoading() {
    _status = 'loading';
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = 'error';
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
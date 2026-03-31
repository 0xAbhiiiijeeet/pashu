import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/milk_remote_datasource.dart';
import '../../domain/models/customer_model.dart';
import '../../domain/models/milk_entry_model.dart';

class MilkProvider extends ChangeNotifier {
  MilkProvider(this._dataSource);

  final MilkRemoteDataSource _dataSource;

  String _status = 'initial';
  List<MilkEntry> _entries = [];
  List<Customer> _customers = [];
  Map<String, dynamic> _todaySummary = {};
  String? _errorMessage;

  String get status => _status;
  List<MilkEntry> get entries => _entries;
  List<Customer> get customers => _customers;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';

  List<MilkEntry> getEntriesForDate(DateTime date) {
    return _entries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  Map<String, dynamic> getSummaryForDate(DateTime date) {
    if (_isSameDay(date, DateTime.now()) && _todaySummary.isNotEmpty) {
      return {
        'customerCount': _todaySummary['totalCustomers'] ?? 0,
        'totalCow': (_todaySummary['cowMilkLiters'] as num?)?.toDouble() ?? 0,
        'totalBuffalo':
            (_todaySummary['buffaloMilkLiters'] as num?)?.toDouble() ?? 0,
        'totalLiters':
            ((_todaySummary['cowMilkLiters'] as num?)?.toDouble() ?? 0) +
                ((_todaySummary['buffaloMilkLiters'] as num?)?.toDouble() ?? 0),
        'totalAmount': (_todaySummary['totalIncome'] as num?)?.toDouble() ?? 0,
      };
    }

    final dayEntries = getEntriesForDate(date);
    final customerCount = dayEntries.length;
    final totalCow =
        dayEntries.fold<double>(0, (sum, entry) => sum + entry.cowMilk);
    final totalBuffalo =
        dayEntries.fold<double>(0, (sum, entry) => sum + entry.buffaloMilk);
    final totalAmount = dayEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry.totalAmount ?? 0),
    );

    return {
      'customerCount': customerCount,
      'totalCow': totalCow,
      'totalBuffalo': totalBuffalo,
      'totalLiters': totalCow + totalBuffalo,
      'totalAmount': totalAmount,
    };
  }

  Future<void> init() async {
    if (_status == 'loading') return;
    _setLoading();
    try {
      await Future.wait([
        fetchCustomers(notify: false),
        fetchEntriesForDate(DateTime.now(), notify: false),
        fetchDailySummary(notify: false),
      ]);
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchCustomers({bool notify = true}) async {
    try {
      _customers = await _dataSource.getCustomers();
      if (notify) {
        _status = 'loaded';
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      if (notify) _setError(e.toString());
      rethrow;
    }
  }

  Future<bool> addCustomer({
    required String name,
    required String phoneNumber,
    required String address,
    required String milkTypePreference,
  }) async {
    _setLoading();
    try {
      final customer = await _dataSource.addCustomer(
        name: name,
        phone: phoneNumber,
        address: address,
        milkTypePreference: milkTypePreference,
      );
      _customers = [customer, ..._customers];
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_extractDioError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> addMilkEntry({
    required String customerId,
    required String customerName,
    required double cowMilk,
    required double buffaloMilk,
    required double pricePerLiter,
    required DateTime date,
    required String shift,
  }) async {
    _setLoading();
    try {
      final createdRecords = <MilkEntry>[];

      if (cowMilk > 0) {
        createdRecords.add(
          await _dataSource.addMilkRecord(
            customerId: customerId,
            quantity: cowMilk,
            pricePerLiter: pricePerLiter,
            milkType: 'Cow',
            shift: shift,
            date: date,
          ),
        );
      }

      if (buffaloMilk > 0) {
        createdRecords.add(
          await _dataSource.addMilkRecord(
            customerId: customerId,
            quantity: buffaloMilk,
            pricePerLiter: pricePerLiter,
            milkType: 'Buffalo',
            shift: shift,
            date: date,
          ),
        );
      }

      if (createdRecords.isEmpty) {
        _status = 'loaded';
        notifyListeners();
        return false;
      }

      await fetchEntriesForDate(date, notify: false);
      if (_isSameDay(date, DateTime.now())) {
        await fetchDailySummary(notify: false);
      }

      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_extractDioError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchEntriesForDate(
    DateTime date, {
    bool notify = true,
  }) async {
    if (notify) _setLoading();
    try {
      final rawEntries = await _dataSource.getMilkRecords(
        startDate: date,
        endDate: date,
      );
      _entries = _aggregateEntries(rawEntries, date);
      if (_isSameDay(date, DateTime.now())) {
        await fetchDailySummary(notify: false);
      }
      if (notify) {
        _status = 'loaded';
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      if (notify) _setError(e.toString());
      rethrow;
    }
  }

  Future<void> fetchDailySummary({bool notify = true}) async {
    try {
      _todaySummary = await _dataSource.getDailySummary();
      if (notify) notifyListeners();
    } catch (e) {
      debugPrint('Milk summary fetch failed: $e');
    }
  }

  List<MilkEntry> _aggregateEntries(List<MilkEntry> records, DateTime date) {
    final grouped = <String, MilkEntry>{};

    for (final record in records) {
      final key = record.customerId ?? record.customerName;
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = record;
        continue;
      }

      grouped[key] = existing.copyWith(
        cowMilk: existing.cowMilk + record.cowMilk,
        buffaloMilk: existing.buffaloMilk + record.buffaloMilk,
        explicitTotalAmount:
            (existing.totalAmount ?? 0) + (record.totalAmount ?? 0),
        pricePerLiter: record.pricePerLiter ?? existing.pricePerLiter,
        date: date,
      );
    }

    final aggregated = grouped.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return aggregated;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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

  String _extractDioError(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] as String?;
      if (message != null) return message;
    } else if (responseData is Map) {
      final message = responseData['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    } else if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }
    return e.message ?? 'Unable to complete this action. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/datasources/problems_remote_datasource.dart';
import '../../domain/models/problem_model.dart';

class ProblemsProvider with ChangeNotifier {
  final ProblemsRemoteDataSource _dataSource;
  final StorageService _storageService;

  ProblemsProvider(this._dataSource, this._storageService);

  List<ProblemModel> _problems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProblemModel> get problems => _problems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get problems grouped by category
  Map<String, List<ProblemModel>> get problemsByCategory {
    final Map<String, List<ProblemModel>> grouped = {};
    for (final problem in _problems.where((p) => p.isActive)) {
      final category = problem.categoryEn;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(problem);
    }
    return grouped;
  }

  /// Initialize: Load from cache first, then fetch fresh data
  Future<void> init() async {
    // Load from cache synchronously (fast)
    loadFromCacheSync();
    
    // Fetch fresh data in background
    await fetchProblems();
  }

  /// Load problems from cache synchronously
  void loadFromCacheSync() {
    try {
      final cachedData = _storageService.getProblems();
      if (cachedData != null && cachedData.isNotEmpty) {
        _problems = cachedData.map((json) => ProblemModel.fromJson(json)).toList();
        debugPrint('📦 Loaded ${_problems.length} problems from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading problems from cache: $e');
    }
  }

  /// Fetch problems from API and cache them
  Future<void> fetchProblems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final freshProblems = await _dataSource.getProblems();
      _problems = freshProblems;
      _errorMessage = null;
      
      // Cache the problems
      await _storageService.saveProblems(
        freshProblems.map((p) => p.toJson()).toList(),
      );
      
      debugPrint('✅ Fetched and cached ${_problems.length} problems');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error fetching problems: $e');
      
      // If we have cached data, keep using it
      if (_problems.isEmpty) {
        loadFromCacheSync();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ProblemModel? getProblemById(String id) {
    try {
      return _problems.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

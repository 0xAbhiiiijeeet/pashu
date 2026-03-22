import 'package:flutter/foundation.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/datasources/posts_remote_datasource.dart';
import '../../domain/models/post_model.dart';

class PostsProvider with ChangeNotifier {
  final PostsRemoteDataSource _dataSource;
  final StorageService _storageService;

  PostsProvider(this._dataSource, this._storageService);

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, bool> _expandedComments = {};

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isCommentsExpanded(String postId) => _expandedComments[postId] ?? false;

  void toggleCommentsExpanded(String postId) {
    _expandedComments[postId] = !(_expandedComments[postId] ?? false);
    notifyListeners();
  }

  Future<void> init() async {
    loadFromCacheSync();
    await fetchPosts();
  }

  void loadFromCacheSync() {
    try {
      final cachedData = _storageService.getPosts();
      if (cachedData != null && cachedData.isNotEmpty) {
        _posts = cachedData.map((json) => PostModel.fromJson(json)).toList();
        debugPrint('📦 Loaded ${_posts.length} posts from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading posts from cache: $e');
      // Clear corrupted cache
      _storageService.clearPostsCache();
    }
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final freshPosts = await _dataSource.getPosts();
      _posts = freshPosts;
      _errorMessage = null;

      await _storageService.savePosts(
        freshPosts.map((p) => p.toJson()).toList(),
      );

      debugPrint('✅ Fetched and cached ${_posts.length} posts');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error fetching posts: $e');

      if (_posts.isEmpty) {
        loadFromCacheSync();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _dataSource.toggleLike(postId);

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final likes = List<String>.from(post.likes);

        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        _posts[postIndex] = post.copyWith(likes: likes);
        notifyListeners();

        await _storageService.savePosts(
          _posts.map((p) => p.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      rethrow;
    }
  }

  Future<void> addComment(String postId, String text) async {
    try {
      // Add the comment
      await _dataSource.addComment(postId, text);
      
      debugPrint('✅ Comment added, fetching fresh post data...');
      
      // Fetch the updated post to get all populated user names
      final updatedPost = await _dataSource.getPostById(postId);
      
      debugPrint('✅ Received updated post with ${updatedPost.comments.length} comments (all names populated)');

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = updatedPost;
        notifyListeners();

        await _storageService.savePosts(
          _posts.map((p) => p.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      rethrow;
    }
  }
}

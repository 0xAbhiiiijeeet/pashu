import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/posts_provider.dart';
import 'post_card.dart';

class PostsFeedTab extends StatelessWidget {
  const PostsFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<PostsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.posts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF666B42),
            ),
          );
        }

        if (provider.errorMessage != null && provider.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.isHindi ? 'पोस्ट लोड नहीं हो सके' : 'Failed to load posts',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.fetchPosts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF666B42),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.isHindi ? 'पुनः प्रयास करें' : 'Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E4DA),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.question_answer_outlined,
                    size: 50,
                    color: Color(0xFF666B42),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.isHindi ? 'अभी तक कोई पोस्ट नहीं' : 'No posts yet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.isHindi ? 'बाद में Q&A पोस्ट के लिए वापस आएं' : 'Check back later for Q&A posts',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchPosts(),
          color: const Color(0xFF666B42),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.posts.length,
            itemBuilder: (context, index) {
              final post = provider.posts[index];
              return PostCard(
                key: ValueKey('${post.id}_${post.comments.length}'),
                post: post,
              );
            },
          ),
        );
      },
    );
  }
}

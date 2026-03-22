import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/post_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import 'comment_section.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id ?? '';
    final isLiked = post.likes.contains(userId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4.70,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 17, 15, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 30,
                  height: 30,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF666B42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(49),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitial(post.askedByName ?? 'User'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Name
                Expanded(
                  child: Text(
                    '${post.askedByName ?? 'User'} ji\'s problem',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Category tag
                if (post.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Text(
                      post.category!,
                      style: const TextStyle(
                        color: Color(0xFF666B42),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Title (Question)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Text(
              post.question,
              style: const TextStyle(
                color: Color(0xFF535735),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Answer Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3DCD6), Colors.white],
              ),
              border: Border.symmetric(
                horizontal: BorderSide(color: Color(0xFFE8E8E8), width: 1),
              ),
            ),
            child: Column(
              children: [
                // "Animal friend answer" pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Animal friend answer',
                    style: TextStyle(
                      color: Color(0xFF666B42),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // Answer body
                Text(
                  post.answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          // Likes / Comments / Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Likes
                InkWell(
                  onTap: () => _handleLike(context, userId),
                  child: _ActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likes.length} Likes',
                    iconColor: isLiked ? Colors.red : const Color(0xFF666B42),
                  ),
                ),
                const Spacer(),
                // Comments
                InkWell(
                  onTap: () => _toggleComments(context),
                  child: _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.comments.length} Comment',
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          Consumer<PostsProvider>(
            builder: (context, provider, _) {
              if (provider.isCommentsExpanded(post.id)) {
                return CommentSection(post: post);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _getInitial(String name) {
    if (name.isEmpty) return 'A';
    return name[0].toUpperCase();
  }

  void _handleLike(BuildContext context, String userId) {
    final provider = context.read<PostsProvider>();
    provider.toggleLike(post.id, userId);
  }

  void _toggleComments(BuildContext context) {
    final provider = context.read<PostsProvider>();
    provider.toggleCommentsExpanded(post.id);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.iconColor = const Color(0xFF666B42),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666B42),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String? userName;
  final String text;
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.text,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String userId = '';
    String? userName;
    final rawUser = json['user'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map<String, dynamic>) {
      userId = rawUser['_id'] as String? ?? '';
      userName = rawUser['name'] as String?;
    }

    return CommentModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: userId,
      userName: userName,
      text: json['text'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class AdminAnswer {
  final String text;
  final DateTime? answeredAt;

  const AdminAnswer({required this.text, this.answeredAt});

  factory AdminAnswer.fromJson(Map<String, dynamic> json) => AdminAnswer(
        text: json['text'] as String,
        answeredAt: json['answeredAt'] != null
            ? DateTime.tryParse(json['answeredAt'] as String)
            : null,
      );
}

class QuestionModel {
  final String id;
  final String userId;
  final String? userName;
  final String questionText;
  final String? imageUrl;
  final List<String> likes;
  final List<CommentModel> comments;
  final AdminAnswer? adminAnswer;
  final DateTime? createdAt;

  const QuestionModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.questionText,
    this.imageUrl,
    required this.likes,
    required this.comments,
    this.adminAnswer,
    this.createdAt,
  });

  int get likeCount => likes.length;
  int get commentCount => comments.length;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    String userId = '';
    String? userName;
    final rawUser = json['user'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map<String, dynamic>) {
      userId = rawUser['_id'] as String? ?? '';
      userName = rawUser['name'] as String?;
    }

    return QuestionModel(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: userId,
      userName: userName,
      questionText: json['questionText'] as String,
      imageUrl: json['imageUrl'] as String?,
      likes: (json['likes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      adminAnswer: json['adminAnswer'] != null
          ? AdminAnswer.fromJson(json['adminAnswer'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  QuestionModel copyWith({
    List<String>? likes,
    List<CommentModel>? comments,
    AdminAnswer? adminAnswer,
  }) =>
      QuestionModel(
        id: id,
        userId: userId,
        userName: userName,
        questionText: questionText,
        imageUrl: imageUrl,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        adminAnswer: adminAnswer ?? this.adminAnswer,
        createdAt: createdAt,
      );
}

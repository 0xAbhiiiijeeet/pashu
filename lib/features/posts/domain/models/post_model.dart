class PostModel {
  final String id;
  final String question;
  final String answer;
  final String? category;
  final String? adminId;
  final String? adminName;
  final String? askedByName;
  final String? askedById;
  final String? askedByPhone;
  final List<String> likes;
  final List<CommentModel> comments;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.adminId,
    this.adminName,
    this.askedByName,
    this.askedById,
    this.askedByPhone,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse askedBy field - can be object or string ID
    String? askedByName;
    String? askedById;
    String? askedByPhone;
    
    final askedByField = json['askedBy'];
    if (askedByField is Map<String, dynamic>) {
      // askedBy is a populated user object
      askedById = askedByField['_id']?.toString();
      askedByName = askedByField['name']?.toString();
      askedByPhone = askedByField['phoneNumber']?.toString();
    } else if (askedByField is String) {
      // askedBy is just an ID string
      askedById = askedByField;
    }
    
    // Use askedByName field if provided (fallback for display name)
    askedByName ??= json['askedByName']?.toString();
    
    return PostModel(
      id: json['_id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString(),
      adminId: json['admin']?['_id']?.toString(),
      adminName: json['admin']?['name']?.toString(),
      askedByName: askedByName,
      askedById: askedById,
      askedByPhone: askedByPhone,
      likes: (json['likes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'askedByName': askedByName,
      'askedBy': askedById,
      'likes': likes,
      'comments': comments.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PostModel copyWith({
    List<String>? likes,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id,
      question: question,
      answer: answer,
      category: category,
      adminId: adminId,
      adminName: adminName,
      askedByName: askedByName,
      askedById: askedById,
      askedByPhone: askedByPhone,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt,
    );
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Handle both cases: user as object or user as string ID
    String userId;
    String userName;
    
    final userField = json['user'];
    if (userField is Map<String, dynamic>) {
      // User is an object with _id and name
      userId = userField['_id']?.toString() ?? '';
      userName = userField['name']?.toString() ?? 'Anonymous';
    } else if (userField is String) {
      // User is just an ID string
      userId = userField;
      userName = 'User'; // Default name when only ID is provided
    } else {
      userId = '';
      userName = 'Anonymous';
    }
    
    return CommentModel(
      id: json['_id']?.toString() ?? '',
      userId: userId,
      userName: userName,
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': {
        '_id': userId,
        'name': userName,
      },
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

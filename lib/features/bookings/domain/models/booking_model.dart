import 'package:flutter/material.dart';
import 'problem_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final ProblemModel? problem;
  final DateTime scheduledTime;
  final String status;

  const BookingModel({
    required this.id,
    required this.userId,
    this.problem,
    required this.scheduledTime,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print the JSON being parsed
    debugPrint('📦 Parsing BookingModel from: $json');
    
    final statusStr = json['status'] as String? ?? 'pending';

    // problem can be an object or just an ID string
    ProblemModel? problem;
    final rawProblem = json['problem'];
    if (rawProblem is Map<String, dynamic>) {
      try {
        problem = ProblemModel.fromJson(rawProblem);
      } catch (e) {
        debugPrint('⚠️ Error parsing problem in booking: $e');
      }
    }

    // user can be an object or just an ID string
    String userId = '';
    final rawUser = json['user'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map<String, dynamic>) {
      userId = rawUser['_id'] as String? ?? rawUser['id'] as String? ?? '';
    }

    // Handle both _id and id fields
    final id = json['_id'] as String? ?? json['id'] as String? ?? '';
    if (id.isEmpty) {
      throw Exception('Booking ID is missing or empty');
    }

    // Parse scheduledTime safely
    final scheduledTimeStr = json['scheduledTime'] as String?;
    if (scheduledTimeStr == null) {
      throw Exception('Booking scheduledTime is missing');
    }

    DateTime scheduledTime;
    try {
      scheduledTime = DateTime.parse(scheduledTimeStr);
    } catch (e) {
      throw Exception('Invalid scheduledTime format: $scheduledTimeStr');
    }

    return BookingModel(
      id: id,
      userId: userId,
      problem: problem,
      scheduledTime: scheduledTime,
      status: statusStr,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user': userId,
        if (problem != null) 'problem': problem!.toJson(),
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': status,
      };
}
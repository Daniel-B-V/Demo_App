import 'package:flutter/material.dart';

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class QuizCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<Question> questions;

  QuizCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

class Player {
  final String name;
  final int score;
  final bool isCurrentUser;

  Player({
    required this.name,
    required this.score,
    this.isCurrentUser = false,
  });
}



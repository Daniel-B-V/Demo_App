import 'package:flutter/material.dart';
import '../models/quiz_models.dart';

class QuizData {
  static List<QuizCategory> getCategories() {
    return [
      QuizCategory(
        name: 'Science',
        icon: Icons.science,
        color: Colors.blue,
        questions: [
          Question(
            question: 'What is the chemical symbol for water?',
            options: ['H2O', 'CO2', 'O2', 'H2SO4'],
            correctAnswer: 0,
          ),
          Question(
            question: 'How many planets are in our solar system?',
            options: ['7', '8', '9', '10'],
            correctAnswer: 1,
          ),
          Question(
            question: 'What gas do plants absorb from the atmosphere?',
            options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
            correctAnswer: 2,
          ),
          Question(
            question: 'What is the speed of light?',
            options: ['300,000 km/s', '150,000 km/s', '450,000 km/s', '200,000 km/s'],
            correctAnswer: 0,
          ),
          Question(
            question: 'What is the hardest natural substance?',
            options: ['Gold', 'Iron', 'Diamond', 'Silver'],
            correctAnswer: 2,
          ),
        ],
      ),
      QuizCategory(
        name: 'History',
        icon: Icons.museum,
        color: Colors.orange,
        questions: [
          Question(
            question: 'In which year did World War II end?',
            options: ['1944', '1945', '1946', '1947'],
            correctAnswer: 1,
          ),
          Question(
            question: 'Who was the first President of the United States?',
            options: ['Thomas Jefferson', 'John Adams', 'George Washington', 'Benjamin Franklin'],
            correctAnswer: 2,
          ),
          Question(
            question: 'Which empire was ruled by Julius Caesar?',
            options: ['Greek Empire', 'Roman Empire', 'Egyptian Empire', 'Persian Empire'],
            correctAnswer: 1,
          ),
          Question(
            question: 'In which year did the Berlin Wall fall?',
            options: ['1987', '1988', '1989', '1990'],
            correctAnswer: 2,
          ),
          Question(
            question: 'Who discovered America in 1492?',
            options: ['Vasco da Gama', 'Christopher Columbus', 'Ferdinand Magellan', 'Marco Polo'],
            correctAnswer: 1,
          ),
        ],
      ),
      QuizCategory(
        name: 'Math',
        icon: Icons.calculate,
        color: Colors.green,
        questions: [
          Question(
            question: 'What is 15 × 8?',
            options: ['110', '115', '120', '125'],
            correctAnswer: 2,
          ),
          Question(
            question: 'What is the square root of 144?',
            options: ['11', '12', '13', '14'],
            correctAnswer: 1,
          ),
          Question(
            question: 'What is 2³?',
            options: ['6', '8', '9', '12'],
            correctAnswer: 1,
          ),
          Question(
            question: 'What is the value of π (pi) approximately?',
            options: ['3.14', '2.71', '1.41', '3.16'],
            correctAnswer: 0,
          ),
          Question(
            question: 'What is 100 ÷ 4?',
            options: ['20', '25', '30', '35'],
            correctAnswer: 1,
          ),
        ],
      ),
      QuizCategory(
        name: 'Geography',
        icon: Icons.public,
        color: Colors.teal,
        questions: [
          Question(
            question: 'What is the capital of France?',
            options: ['London', 'Berlin', 'Paris', 'Madrid'],
            correctAnswer: 2,
          ),
          Question(
            question: 'Which is the largest ocean?',
            options: ['Atlantic', 'Pacific', 'Indian', 'Arctic'],
            correctAnswer: 1,
          ),
          Question(
            question: 'How many continents are there?',
            options: ['5', '6', '7', '8'],
            correctAnswer: 2,
          ),
          Question(
            question: 'What is the longest river in the world?',
            options: ['Amazon', 'Nile', 'Mississippi', 'Yangtze'],
            correctAnswer: 1,
          ),
          Question(
            question: 'Which country has the most time zones?',
            options: ['USA', 'Russia', 'China', 'Canada'],
            correctAnswer: 1,
          ),
        ],
      ),
    ];
  }
}
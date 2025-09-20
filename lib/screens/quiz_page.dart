import 'package:flutter/material.dart';
import '../data/quiz_data.dart';
import '../models/quiz_models.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswer;
  bool showFeedback = false;
  String nickname = '';
  String categoryName = '';
  List<Question> questions = [];
  
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      nickname = args['nickname'] ?? '';
      categoryName = args['category'] ?? '';
      
      final category = QuizData.getCategories().firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => QuizData.getCategories().first,
      );
      questions = category.questions;
      
      
      _progressController.forward();
    }
  }

  void _selectAnswer(int answerIndex) {
    if (showFeedback) return;
    
    setState(() {
      selectedAnswer = answerIndex;
      showFeedback = true;
    });
    
    _feedbackController.forward();
    
    if (answerIndex == questions[currentQuestionIndex].correctAnswer) {
      score += 20; 
    }
    
    Future.delayed(Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showFeedback = false;
      });
      _feedbackController.reset();
      _progressController.forward();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    Navigator.pushReplacementNamed(
      context,
      '/scoreboard',
      arguments: {
        'nickname': nickname,
        'score': score,
        'category': categoryName,
      },
    );
  }

  Color _getOptionColor(int index) {
    if (!showFeedback) {
      return selectedAnswer == index 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
          : Colors.transparent;
    }
    
    if (index == questions[currentQuestionIndex].correctAnswer) {
      return Colors.green.withOpacity(0.8);
    } else if (index == selectedAnswer && selectedAnswer != questions[currentQuestionIndex].correctAnswer) {
      return Colors.red.withOpacity(0.8);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentQuestionIndex + 1) / questions.length;

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Quiz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress Bar
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${currentQuestionIndex + 1} of ${questions.length}',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'Score: $score',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: progress * _progressAnimation.value,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                // Question Card
                Expanded(
                  child: Card(
                    elevation: 12,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Question
                          Text(
                            questions[currentQuestionIndex].question,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 32),
                          
                          // Options
                          Expanded(
                            child: ListView.builder(
                              itemCount: questions[currentQuestionIndex].options.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: _getOptionColor(index),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selectedAnswer == index
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: showFeedback ? null : () => _selectAnswer(index),
                                      leading: CircleAvatar(
                                        backgroundColor: selectedAnswer == index
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.surfaceVariant,
                                        child: Text(
                                          String.fromCharCode(65 + index), // A, B, C, D
                                          style: TextStyle(
                                            color: selectedAnswer == index
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        questions[currentQuestionIndex].options[index],
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      trailing: showFeedback
                                          ? ScaleTransition(
                                              scale: _feedbackAnimation,
                                              child: Icon(
                                                index == questions[currentQuestionIndex].correctAnswer
                                                    ? Icons.check_circle
                                                    : (index == selectedAnswer
                                                        ? Icons.cancel
                                                        : null),
                                                color: index == questions[currentQuestionIndex].correctAnswer
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 28,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Feedback
                          if (showFeedback)
                            ScaleTransition(
                              scale: _feedbackAnimation,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selectedAnswer == questions[currentQuestionIndex].correctAnswer
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedAnswer == questions[currentQuestionIndex].correctAnswer
                                        ? Colors.green
                                        : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedAnswer == questions[currentQuestionIndex].correctAnswer
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: selectedAnswer == questions[currentQuestionIndex].correctAnswer
                                          ? Colors.green
                                          : Colors.red,
                                      size: 28,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedAnswer == questions[currentQuestionIndex].correctAnswer
                                            ? 'Correct! Well done!'
                                            : 'Incorrect. The correct answer is ${String.fromCharCode(65 + questions[currentQuestionIndex].correctAnswer)}.',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
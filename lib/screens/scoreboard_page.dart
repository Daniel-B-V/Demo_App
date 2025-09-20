import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import '../models/quiz_models.dart';

class ScoreboardPage extends StatefulWidget {
  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> with TickerProviderStateMixin {
  List<Player> players = [];
  String currentUserName = '';
  int currentUserScore = 0;
  WebSocketChannel? channel;
  Timer? _simulationTimer;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _sampleNames = [
    'Alex', 'Sarah', 'Mike', 'Emma', 'David', 'Lisa', 'John', 'Anna',
    'Chris', 'Sophie', 'Ryan', 'Maya', 'Kevin', 'Zoe', 'Lucas', 'Mia'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _initializeWebSocket();
    _startScoreSimulation();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _simulationTimer?.cancel();
    channel?.sink.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      currentUserName = args['nickname'] ?? '';
      currentUserScore = args['score'] ?? 0;
      _initializeLeaderboard();
    }
  }

  void _initializeWebSocket() {
    try {
      
      channel = IOWebSocketChannel.connect('wss://echo.websocket.org');
      
      channel!.stream.listen(
        (message) {
          
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  void _initializeLeaderboard() {
    final random = Random();
    players = [
      Player(name: currentUserName, score: currentUserScore, isCurrentUser: true),
    ];

    // Add some sample players with random scores
    for (int i = 0; i < 8; i++) {
      final name = _sampleNames[random.nextInt(_sampleNames.length)];
      if (name != currentUserName) {
        players.add(Player(
          name: name,
          score: random.nextInt(100),
        ));
      }
    }

    _sortPlayers();
  }

  void _sortPlayers() {
    players.sort((a, b) => b.score.compareTo(a.score));
    setState(() {});
  }

  void _startScoreSimulation() {
    _simulationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        _simulateScoreUpdate();
      }
    });
  }

  void _simulateScoreUpdate() {
    final random = Random();
    if (players.length > 1) {
      final playerIndex = random.nextInt(players.length);
      if (!players[playerIndex].isCurrentUser) {
        final scoreChange = random.nextInt(21) - 10; // -10 to +10
        players[playerIndex] = Player(
          name: players[playerIndex].name,
          score: math.max(0, players[playerIndex].score + scoreChange),
          isCurrentUser: false,
        );
        
        _sortPlayers();
        
        // Send update via WebSocket (for demo)
        if (channel != null) {
          final update = jsonEncode({
            'player': players[playerIndex].name,
            'score': players[playerIndex].score,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          channel!.sink.add(update);
        }
      }
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.military_tech;
      case 2:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Scoreboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _simulateScoreUpdate,
          ),
        ],
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
          child: Column(
            children: [
              // Header
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.leaderboard,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Live Rankings',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Live Updates',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Leaderboard
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final rank = index;
                    
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Card(
                        elevation: player.isCurrentUser ? 12 : 4,
                        color: player.isCurrentUser 
                            ? theme.colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getRankColor(rank),
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getRankIcon(rank),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  '#${rank + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                player.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: player.isCurrentUser 
                                      ? theme.colorScheme.onPrimaryContainer
                                      : null,
                                ),
                              ),
                              if (player.isCurrentUser) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'YOU',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${player.score}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Actions
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                            arguments: {'nickname': currentUserName},
                          );
                        },
                        icon: Icon(Icons.play_arrow),
                        label: Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
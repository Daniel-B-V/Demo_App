import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  SettingsPage({required this.onThemeChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  bool isDarkMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadThemePreference();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadThemePreference() async {
    
    final brightness = Theme.of(context).brightness;
    setState(() {
      isDarkMode = brightness == Brightness.dark;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    widget.onThemeChanged(value);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // App Info
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Quiz Master',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Test your knowledge with live competitions!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                // Theme Settings
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Appearance',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text('Dark Mode'),
                        subtitle: Text(
                          isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: _toggleTheme,
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // About
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'About',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text('Version'),
                        subtitle: Text('1.0.0'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.code,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text('Built with Flutter'),
                        subtitle: Text('WebSocket integration for live updates'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.star_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text('Rate this App'),
                        subtitle: Text('Share your feedback'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Thanks for your interest!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout),
                    label: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: EdgeInsets.symmetric(vertical: 16),
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
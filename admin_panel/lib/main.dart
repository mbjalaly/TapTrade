import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/admin_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatefulWidget {
  const AdminPanelApp({super.key});

  @override
  State<AdminPanelApp> createState() => _AdminPanelAppState();
}

class _AdminPanelAppState extends State<AdminPanelApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'TapTrade Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: _themeMode,
      home: AuthWrapper(
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;
  
  const AuthWrapper({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          return DashboardScreen(toggleTheme: toggleTheme);
        }
        return const LoginScreen();
      },
    );
  }
}

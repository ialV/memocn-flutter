import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.init();
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const MemoCNApp(),
    ),
  );
}

class MemoCNApp extends StatelessWidget {
  const MemoCNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '背文助手',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

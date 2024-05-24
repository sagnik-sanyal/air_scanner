import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ProviderScope(child: MainApp()));

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(themeProvider);
    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

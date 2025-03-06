import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'features/pinboard/presentation/pages/analytics_dashboard_page.dart';
import 'features/pinboard/presentation/pages/pinboard_page.dart';
import 'features/pinboard/presentation/services/keyboard_shortcuts_service.dart';
import 'features/settings/presentation/pages/settings_page.dart';

class PinboardApp extends ConsumerStatefulWidget {
  const PinboardApp({super.key});

  @override
  ConsumerState<PinboardApp> createState() => _PinboardAppState();
}

class _PinboardAppState extends ConsumerState<PinboardApp> with WindowListener {
  late final GoRouter _router;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initializeWindowManager();
    _initializeRouter();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeWindowManager() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false, // Hide default window buttons
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // For macOS, configure bitsdojo_window
    doWhenWindowReady(() {
      appWindow.minSize = const Size(800, 600);
      appWindow.size = const Size(1280, 800);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PinboardPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsDashboardPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final keyboardShortcutsService =
        ref.watch(keyboardShortcutsServiceProvider);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: keyboardShortcutsService.handleKeyEvent,
      child: MaterialApp.router(
        title: 'Pinboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: _router,
      ),
    );
  }
}

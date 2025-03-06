import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_window_title_bar.dart';

/// Settings page
class SettingsPage extends ConsumerStatefulWidget {
  /// Constructor
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [
    GlobalKey(debugLabel: 'appearance'),
    GlobalKey(debugLabel: 'keyboard_shortcuts'),
    GlobalKey(debugLabel: 'about'),
  ];
  int _activeSection = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateActiveSection);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateActiveSection);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateActiveSection() {
    if (!_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    // Find the section that is currently most visible
    int newActiveSection = 0;
    double bestVisibility = -1.0;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      final context = key.currentContext;

      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final sectionPos = renderBox.localToGlobal(Offset.zero).dy;
          final sectionHeight = renderBox.size.height;
          
          // Calculate how much of the section is visible in the viewport
          final visibleTop = math.max(0, sectionPos);
          final visibleBottom = math.min(sectionPos + sectionHeight, viewportHeight);
          final visibleHeight = math.max(0, visibleBottom - visibleTop);
          
          // Calculate visibility ratio and adjust for position in viewport
          // Prefer sections near the top of the viewport
          final visibilityScore = visibleHeight * (1.0 - (sectionPos / (viewportHeight * 2)));
          
          if (visibilityScore > bestVisibility) {
            bestVisibility = visibilityScore;
            newActiveSection = i;
          }
        }
      }
    }

    if (newActiveSection != _activeSection) {
      setState(() {
        _activeSection = newActiveSection;
      });
    }
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;

    if (context != null) {
      // Set active section immediately to improve responsiveness
      setState(() {
        _activeSection = index;
      });
      
      // Ensure the section is fully visible with better alignment
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.05, // Adjust alignment to ensure section is more visible at the top
      );
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color,
          size: 22,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Column(
        children: [
          AppWindowTitleBar(
            title: 'Settings',
            showBackButton: true,
            onBackPressed: () => context.go('/'),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation sidebar
                Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Settings',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _buildNavItem(
                              context,
                              'Appearance',
                              Icons.palette_outlined,
                              _activeSection == 0,
                              () => _scrollToSection(0),
                            ),
                            _buildNavItem(
                              context,
                              'Keyboard Shortcuts',
                              Icons.keyboard_outlined,
                              _activeSection == 1,
                              () => _scrollToSection(1),
                            ),
                            _buildNavItem(
                              context,
                              'About',
                              Icons.info_outlined,
                              _activeSection == 2,
                              () => _scrollToSection(2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content area
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      // Appearance section
                      SectionHeader(
                        key: _sectionKeys[0],
                        title: 'Appearance',
                      ),
                      const SizedBox(height: 16),

                      // Theme mode
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Light theme
                              RadioListTile<ThemeMode>(
                                title: const Text('Light'),
                                value: ThemeMode.light,
                                groupValue: themeMode,
                                onChanged: (value) {
                                  if (value != null) {
                                    ref.read(themeModeProvider.notifier).state =
                                        value;
                                  }
                                },
                                secondary: const Icon(Icons.light_mode),
                              ),

                              // Dark theme
                              RadioListTile<ThemeMode>(
                                title: const Text('Dark'),
                                value: ThemeMode.dark,
                                groupValue: themeMode,
                                onChanged: (value) {
                                  if (value != null) {
                                    ref.read(themeModeProvider.notifier).state =
                                        value;
                                  }
                                },
                                secondary: const Icon(Icons.dark_mode),
                              ),

                              // System theme
                              RadioListTile<ThemeMode>(
                                title: const Text('System'),
                                value: ThemeMode.system,
                                groupValue: themeMode,
                                onChanged: (value) {
                                  if (value != null) {
                                    ref.read(themeModeProvider.notifier).state =
                                        value;
                                  }
                                },
                                secondary: const Icon(Icons.settings_suggest),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Keyboard Shortcuts section
                      SectionHeader(
                        key: _sectionKeys[1],
                        title: 'Keyboard Shortcuts',
                      ),
                      const SizedBox(height: 16),

                      // Keyboard shortcuts card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Navigation & Views',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildShortcutItem(
                                  theme, 'Esc', 'Deselect current pin'),
                              _buildShortcutItem(
                                  theme, 'Ctrl/Cmd + F', 'Focus search bar'),
                              _buildShortcutItem(theme, 'Ctrl/Cmd + G',
                                  'Toggle grid/list view'),
                              _buildShortcutItem(theme, 'Ctrl/Cmd + A',
                                  'Toggle show archived pins'),
                              const SizedBox(height: 24),
                              Text(
                                'Pin Management',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildShortcutItem(theme, 'Ctrl/Cmd + N',
                                  'Create new pin with default values'),
                              _buildShortcutItem(theme, 'Ctrl/Cmd + P',
                                  'Toggle pin/unpin for selected pin'),
                              _buildShortcutItem(theme, 'Ctrl/Cmd + H',
                                  'Toggle archive/unarchive for selected pin'),
                              _buildShortcutItem(theme, 'Ctrl/Cmd + Delete',
                                  'Delete selected pin'),
                              const SizedBox(height: 24),
                              Text(
                                'Priority Shortcuts',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildShortcutItem(
                                  theme, 'Ctrl/Cmd + 1', 'Set low priority'),
                              _buildShortcutItem(
                                  theme, 'Ctrl/Cmd + 2', 'Set medium priority'),
                              _buildShortcutItem(
                                  theme, 'Ctrl/Cmd + 3', 'Set high priority'),
                              _buildShortcutItem(
                                  theme, 'Ctrl/Cmd + 4', 'Set urgent priority'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // About section
                      SectionHeader(
                        key: _sectionKeys[2],
                        title: 'About',
                      ),
                      const SizedBox(height: 16),

                      // About card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pinboard',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Version 1.0.0',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'A modern desktop pinboard application with elegant design.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.code),
                                    label: const Text('Source Code'),
                                    onPressed: () {
                                      // Open source code link
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(ThemeData theme, String key, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              key,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  /// Constructor
  const SectionHeader({
    super.key,
    required this.title,
  });

  /// Section title
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

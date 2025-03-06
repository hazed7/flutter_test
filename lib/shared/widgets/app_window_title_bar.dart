import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io' show Platform;

/// Custom window title bar for desktop applications
class AppWindowTitleBar extends StatelessWidget {
  /// Constructor
  const AppWindowTitleBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.height = 38,
  });

  /// Title of the window
  final String title;

  /// Background color of the title bar
  final Color? backgroundColor;

  /// Foreground color of the title bar
  final Color? foregroundColor;

  /// Actions to display in the title bar
  final List<Widget>? actions;

  /// Whether to show a back button
  final bool showBackButton;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Height of the title bar
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final fgColor = foregroundColor ?? theme.colorScheme.onSurface;
    final isMacOS = Platform.isMacOS;

    return Container(
      height: height,
      color: bgColor,
      child: Stack(
        children: [
          // Window buttons (macOS style)
          if (isMacOS)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMacOSButton(
                    color: const Color(0xFFFF5F57),
                    onPressed: () => appWindow.close(),
                    tooltip: 'Close',
                  ),
                  const SizedBox(width: 8),
                  _buildMacOSButton(
                    color: const Color(0xFFFFBD2E),
                    onPressed: () => appWindow.minimize(),
                    tooltip: 'Minimize',
                  ),
                  const SizedBox(width: 8),
                  _buildMacOSButton(
                    color: const Color(0xFF28C840),
                    onPressed: () {
                      if (appWindow.isMaximized) {
                        appWindow.restore();
                      } else {
                        appWindow.maximize();
                      }
                    },
                    tooltip: 'Maximize',
                  ),
                ],
              ),
            ),

          // Title and draggable area
          Positioned.fill(
            child: Row(
              children: [
                // Space for macOS buttons or back button
                SizedBox(width: isMacOS ? 100 : 16),

                // Back button (if enabled)
                if (showBackButton)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: fgColor, size: 20),
                    onPressed: onBackPressed,
                    tooltip: 'Back',
                  ),

                // App icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: fgColor,
                    size: 18,
                  ),
                ),

                // Title
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),

                // Draggable area
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {
                      appWindow.startDragging();
                    },
                    onDoubleTap: () {
                      if (appWindow.isMaximized) {
                        appWindow.restore();
                      } else {
                        appWindow.maximize();
                      }
                    },
                    child: Container(),
                  ),
                ),

                // Actions
                if (actions != null) ...actions!,

                // Window controls (non-macOS)
                if (!isMacOS) ...[
                  WindowButtons(
                    brightness: theme.brightness,
                    foregroundColor: fgColor,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacOSButton({
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Windows-style window buttons
class WindowButtons extends StatelessWidget {
  const WindowButtons({
    super.key,
    required this.brightness,
    required this.foregroundColor,
  });

  final Brightness brightness;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    final buttonIconColor = foregroundColor;
    final hoverColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.04);

    return Row(
      children: [
        _WindowButton(
          icon: Icons.minimize,
          iconSize: 18,
          onPressed: () => appWindow.minimize(),
          hoverColor: hoverColor,
          iconColor: buttonIconColor,
          tooltip: 'Minimize',
        ),
        _WindowButton(
          icon: Icons.crop_square_outlined,
          iconSize: 16,
          onPressed: () {
            if (appWindow.isMaximized) {
              appWindow.restore();
            } else {
              appWindow.maximize();
            }
          },
          hoverColor: hoverColor,
          iconColor: buttonIconColor,
          tooltip: 'Maximize',
        ),
        _WindowButton(
          icon: Icons.close,
          iconSize: 18,
          onPressed: () => appWindow.close(),
          hoverColor: Colors.red.withOpacity(0.6),
          hoverIconColor: Colors.white,
          iconColor: buttonIconColor,
          tooltip: 'Close',
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final Color hoverColor;
  final Color? hoverIconColor;
  final Color iconColor;
  final String tooltip;

  const _WindowButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    required this.hoverColor,
    required this.iconColor,
    required this.tooltip,
    this.hoverIconColor,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
            width: 46,
            height: 38,
            color: _isHovering ? widget.hoverColor : Colors.transparent,
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: _isHovering && widget.hoverIconColor != null
                    ? widget.hoverIconColor
                    : widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

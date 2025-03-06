import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/pin.dart';

/// Component for displaying pin content
class PinDetailContent extends StatefulWidget {
  /// Constructor
  const PinDetailContent({
    super.key,
    required this.pin,
    required this.theme,
  });

  /// The pin to display
  final Pin pin;

  /// The current theme
  final ThemeData theme;

  @override
  State<PinDetailContent> createState() => _PinDetailContentState();
}

class _PinDetailContentState extends State<PinDetailContent> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          // Content container with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.theme.colorScheme.outlineVariant.withOpacity(
                  _isHovering ? 0.8 : 0.5,
                ),
                width: 1,
              ),
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color:
                            widget.theme.colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: SelectableText(
              widget.pin.content,
              style: widget.theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Copy button that appears on hover
          if (_isHovering)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy content',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.pin.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Content copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: widget
                      .theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.8),
                  foregroundColor: widget.theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

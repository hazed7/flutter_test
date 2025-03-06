import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pin_providers.dart';
import 'pin_detail_action_bar.dart';
import 'pin_detail_content.dart';
import 'pin_detail_header.dart';
import 'pin_detail_metadata.dart';
import 'pin_detail_tags.dart';
import 'pin_detail_version_history.dart';

/// A beautiful detailed view for a pin that appears when a pin is clicked
class PinDetailView extends ConsumerWidget {
  /// Constructor
  const PinDetailView({
    super.key,
  });

  void _closeDetailView(WidgetRef ref) {
    ref.read(selectedPinIdProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPinId = ref.watch(selectedPinIdProvider);
    final theme = Theme.of(context);

    if (selectedPinId == null) {
      return const SizedBox.shrink(); // No pin selected
    }

    // Get the selected pin
    final selectedPinAsync = ref.watch(pinByIdProvider(selectedPinId));

    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: selectedPinId != null
          ? Container(
              key: ValueKey(selectedPinId),
              color: theme.colorScheme.background.withOpacity(0.9),
              child: GestureDetector(
                onTap: () =>
                    _closeDetailView(ref), // Close when tapping outside
                behavior: HitTestBehavior.opaque,
                child: selectedPinAsync.when(
                  data: (pin) {
                    if (pin == null) {
                      _closeDetailView(ref);
                      return const SizedBox.shrink();
                    }

                    return Center(
                      child: GestureDetector(
                        onTap:
                            () {}, // Prevent tap from closing the detail view
                        child: Hero(
                          tag: 'pin-${pin.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: 800,
                              margin: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow
                                        .withOpacity(0.15),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header with title and icon
                                    PinDetailHeader(pin: pin, theme: theme),

                                    // Content area
                                    Flexible(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Pin metadata (priority, type, date)
                                            PinDetailMetadata(
                                                pin: pin, theme: theme),

                                            const SizedBox(height: 24),

                                            // Pin content
                                            PinDetailContent(
                                                pin: pin, theme: theme),

                                            // Tags section
                                            PinDetailTags(
                                                pin: pin, theme: theme),

                                            // Version history section
                                            PinDetailVersionHistory(
                                                pin: pin, theme: theme),

                                            const SizedBox(height: 32),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Action bar
                                    PinDetailActionBar(
                                      pin: pin,
                                      theme: theme,
                                      onClose: () => _closeDetailView(ref),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading pin details...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stackTrace) {
                    _closeDetailView(ref);

                    // Show error snackbar
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error loading pin: $error'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    });

                    return const SizedBox.shrink();
                  },
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

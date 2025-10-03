import 'package:flutter/material.dart';


/// Defines how the user interacts with the popup.
enum InteractionMode {
  /// Show/hide popup on click/tap.
  click,

  /// Show/hide popup on mouse hover (desktop/web).
  hover,
}

/// Configuration for popup positioning behavior.
class PositionConfig {
  /// The alignment point on the trigger widget.
  /// For example, [Alignment.bottomCenter] means the bottom-center point of the trigger.
  final Alignment targetAlignment;

  /// The alignment point on the popup (follower) widget.
  /// For example, [Alignment.topCenter] means the top-center point of the popup.
  /// This point will be aligned with [targetAlignment] on the trigger.
  final Alignment followerAlignment;

  /// Distance between the trigger and popup in logical pixels.
  final double gap;

  /// Minimum margin from screen edges in logical pixels.
  final double edgeMargin;

  /// Additional offset to apply after positioning.
  final Offset? offset;

  const PositionConfig({
    required this.targetAlignment,
    required this.followerAlignment,
    this.gap = 8.0,
    this.edgeMargin = 16.0,
    this.offset,
  });

  /// Position popup above trigger, centered.
  const PositionConfig.top({
    this.gap = 8.0,
    this.edgeMargin = 16.0,
    this.offset,
  })  : targetAlignment = Alignment.topCenter,
        followerAlignment = Alignment.bottomCenter;

  /// Position popup below trigger, centered.
  const PositionConfig.bottom({
    this.gap = 8.0,
    this.edgeMargin = 16.0,
    this.offset,
  })  : targetAlignment = Alignment.bottomCenter,
        followerAlignment = Alignment.topCenter;

  /// Position popup to the left of trigger, centered.
  const PositionConfig.left({
    this.gap = 8.0,
    this.edgeMargin = 16.0,
    this.offset,
  })  : targetAlignment = Alignment.centerLeft,
        followerAlignment = Alignment.centerRight;

  /// Position popup to the right of trigger, centered.
  const PositionConfig.right({
    this.gap = 8.0,
    this.edgeMargin = 16.0,
    this.offset,
  })  : targetAlignment = Alignment.centerRight,
        followerAlignment = Alignment.centerLeft;
}

/// Configuration for interaction behavior.
class InteractionConfig {
  /// How the user triggers the popup.
  final InteractionMode mode;

  /// Delay before showing popup on hover.
  final Duration hoverShowDelay;

  /// Delay before hiding popup after hover exit.
  final Duration hoverHideDelay;

  /// Optional timeout to auto-hide the popup.
  final Duration? autoHideTimeout;

  const InteractionConfig({
    this.mode = InteractionMode.click,
    this.hoverShowDelay = const Duration(milliseconds: 120),
    this.hoverHideDelay = const Duration(milliseconds: 120),
    this.autoHideTimeout,
  });
}

/// Result of position calculation.
class PositionResult {
  /// The calculated offset for the popup.
  final Offset offset;

  const PositionResult({
    required this.offset,
  });
}

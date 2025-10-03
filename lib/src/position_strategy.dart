import 'package:flutter/material.dart';

import 'models.dart';

/// Pure positioning logic for popups.
class PositionStrategy {
  /// Calculates the optimal position for a popup using alignment-based positioning.
  ///
  /// Returns an offset RELATIVE to the trigger's top-left corner.
  ///
  /// [triggerRect] is the position and size of the trigger widget in viewport coordinates.
  /// [popupSize] is the size of the popup content.
  /// [viewportRect] is the available screen space.
  /// [config] defines positioning preferences.
  static PositionResult calculate({
    required Rect triggerRect,
    required Size popupSize,
    required Rect viewportRect,
    required PositionConfig config,
  }) {
    return _calculateAlignmentBased(
      triggerRect: triggerRect,
      popupSize: popupSize,
      viewportRect: viewportRect,
      config: config,
    );
  }

  /// Alignment-based positioning with smart fallbacks to avoid overlapping trigger.
  static PositionResult _calculateAlignmentBased({
    required Rect triggerRect,
    required Size popupSize,
    required Rect viewportRect,
    required PositionConfig config,
  }) {
    // Try preferred position first
    final preferredResult = _tryPosition(
      targetAlign: config.targetAlignment,
      followerAlign: config.followerAlignment,
      triggerRect: triggerRect,
      popupSize: popupSize,
      viewportRect: viewportRect,
      config: config,
    );

    // If preferred position doesn't overlap trigger, use it
    if (!preferredResult.overlaps) {
      return PositionResult(offset: preferredResult.offset);
    }

    // Try alternative positions to avoid overlap
    final alternatives = _getAlternativePositions(
      config.targetAlignment,
      config.followerAlignment,
    );

    for (final alt in alternatives) {
      final result = _tryPosition(
        targetAlign: alt.targetAlign,
        followerAlign: alt.followerAlign,
        triggerRect: triggerRect,
        popupSize: popupSize,
        viewportRect: viewportRect,
        config: config,
      );

      if (!result.overlaps) {
        return PositionResult(offset: result.offset);
      }
    }

    // All positions overlap - use preferred (user's explicit choice)
    return PositionResult(offset: preferredResult.offset);
  }

  /// Try positioning with specific alignments and check for overlap.
  static _PositionAttempt _tryPosition({
    required Alignment targetAlign,
    required Alignment followerAlign,
    required Rect triggerRect,
    required Size popupSize,
    required Rect viewportRect,
    required PositionConfig config,
  }) {
    // Calculate the target point on the trigger
    final targetPoint = Offset(
      triggerRect.left + (triggerRect.width / 2) * (1 + targetAlign.x),
      triggerRect.top + (triggerRect.height / 2) * (1 + targetAlign.y),
    );

    // Calculate the follower anchor point offset (relative to popup top-left)
    final followerAnchorOffset = Offset(
      (popupSize.width / 2) * (1 + followerAlign.x),
      (popupSize.height / 2) * (1 + followerAlign.y),
    );

    // Calculate popup position: target point - follower anchor offset
    var popupLeft = targetPoint.dx - followerAnchorOffset.dx;
    var popupTop = targetPoint.dy - followerAnchorOffset.dy;

    // Apply gap (move away from trigger based on alignment direction)
    if (config.gap > 0) {
      final gapVector = _calculateGapVector(targetAlign, followerAlign);
      popupLeft += gapVector.dx * config.gap;
      popupTop += gapVector.dy * config.gap;
    }

    // Clamp to viewport with edge margins
    final minLeft = viewportRect.left + config.edgeMargin;
    final maxLeft = viewportRect.right - popupSize.width - config.edgeMargin;
    final minTop = viewportRect.top + config.edgeMargin;
    final maxTop = viewportRect.bottom - popupSize.height - config.edgeMargin;

    if (minLeft <= maxLeft) {
      popupLeft = popupLeft.clamp(minLeft, maxLeft);
    } else {
      popupLeft = viewportRect.left + (viewportRect.width - popupSize.width) / 2;
    }

    if (minTop <= maxTop) {
      popupTop = popupTop.clamp(minTop, maxTop);
    } else {
      popupTop = viewportRect.top + (viewportRect.height - popupSize.height) / 2;
    }

    // Check for overlap with trigger
    final popupRect = Rect.fromLTWH(popupLeft, popupTop, popupSize.width, popupSize.height);
    final overlaps = _rectsOverlap(triggerRect, popupRect);

    // Convert to relative offset from trigger
    var offset = Offset(
      popupLeft - triggerRect.left,
      popupTop - triggerRect.top,
    );

    // Apply custom offset if provided
    if (config.offset != null) {
      offset = Offset(
        offset.dx + config.offset!.dx,
        offset.dy + config.offset!.dy,
      );
    }

    return _PositionAttempt(offset: offset, overlaps: overlaps);
  }

  /// Check if two rectangles overlap.
  static bool _rectsOverlap(Rect a, Rect b) {
    return !(a.right <= b.left ||
             a.left >= b.right ||
             a.bottom <= b.top ||
             a.top >= b.bottom);
  }

  /// Get alternative positions to try if preferred position overlaps.
  /// Order: opposite, then perpendicular directions.
  static List<_AlignmentPair> _getAlternativePositions(
    Alignment targetAlign,
    Alignment followerAlign,
  ) {
    final alternatives = <_AlignmentPair>[];

    // Determine if primary direction is vertical or horizontal
    final isVertical = (targetAlign.y - followerAlign.y).abs() >
                       (targetAlign.x - followerAlign.x).abs();

    if (isVertical) {
      // Primary is vertical (top/bottom), so opposite is vertical too
      alternatives.add(_AlignmentPair(
        targetAlign: Alignment(targetAlign.x, -targetAlign.y),
        followerAlign: Alignment(followerAlign.x, -followerAlign.y),
      ));

      // Then try horizontal alternatives
      alternatives.add(_AlignmentPair(
        targetAlign: Alignment.centerRight,
        followerAlign: Alignment.centerLeft,
      ));
      alternatives.add(_AlignmentPair(
        targetAlign: Alignment.centerLeft,
        followerAlign: Alignment.centerRight,
      ));
    } else {
      // Primary is horizontal (left/right), so opposite is horizontal too
      alternatives.add(_AlignmentPair(
        targetAlign: Alignment(-targetAlign.x, targetAlign.y),
        followerAlign: Alignment(-followerAlign.x, followerAlign.y),
      ));

      // Then try vertical alternatives
      alternatives.add(_AlignmentPair(
        targetAlign: Alignment.bottomCenter,
        followerAlign: Alignment.topCenter,
      ));
      alternatives.add(_AlignmentPair(
        targetAlign: Alignment.topCenter,
        followerAlign: Alignment.bottomCenter,
      ));
    }

    return alternatives;
  }

  /// Calculate gap direction vector from alignment relationship.
  static Offset _calculateGapVector(Alignment target, Alignment follower) {
    // The gap should push the popup away from the trigger
    // Direction is from follower anchor toward target anchor
    final dx = target.x - follower.x;
    final dy = target.y - follower.y;

    // Normalize to unit vector
    final magnitude = Offset(dx, dy).distance;
    if (magnitude == 0) return Offset.zero;

    return Offset(dx / magnitude, dy / magnitude);
  }
}

/// Internal class to hold position attempt results.
class _PositionAttempt {
  final Offset offset;
  final bool overlaps;

  const _PositionAttempt({
    required this.offset,
    required this.overlaps,
  });
}

/// Internal class to hold alignment pairs for position alternatives.
class _AlignmentPair {
  final Alignment targetAlign;
  final Alignment followerAlign;

  const _AlignmentPair({
    required this.targetAlign,
    required this.followerAlign,
  });
}

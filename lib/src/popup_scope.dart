import 'package:flutter/material.dart';

/// Defines a boundary region that constrains popup positioning.
///
/// Wrap a UI region (sidebar, panel, dialog, etc.) with [FlexOverlayScope]
/// to ensure all [FlexOverlay] descendants stay within that region's bounds.
///
/// Example:
/// ```dart
/// FlexOverlayScope(
///   child: Sidebar(
///     child: FlexOverlay(...), // Constrained to sidebar
///   ),
/// )
/// ```
///
/// Without a scope, popups use the full screen as their viewport.
class FlexOverlayScope extends StatefulWidget {
  /// The widget subtree that defines the constrained region.
  final Widget child;

  const FlexOverlayScope({super.key, required this.child});

  /// Get the scope bounds from the widget tree, or null if no scope exists.
  ///
  /// [overlayContext] must be from within the Overlay widget.
  /// Returns bounds in overlay coordinate space, or null if no scope found.
  static Rect? maybeGetBounds(BuildContext overlayContext) {
    final scope = overlayContext
        .dependOnInheritedWidgetOfExactType<_FlexOverlayScopeData>();
    if (scope == null) return null;

    // Get the scope's render box
    final scopeBox =
        scope._scopeKey.currentContext?.findRenderObject() as RenderBox?;
    if (scopeBox == null || !scopeBox.hasSize) return null;

    // Get the scope's position in global coordinates
    final scopeTopLeft = scopeBox.localToGlobal(Offset.zero);

    // Return the scope bounds in global/overlay coordinates
    return scopeTopLeft & scopeBox.size;
  }

  /// Get the scope bounds, or fall back to default viewport bounds.
  ///
  /// [overlayContext] must be from within the Overlay widget.
  /// [defaultViewportSize] is used if no scope exists (typically overlay size).
  static Rect getBoundsOrDefault(
    BuildContext overlayContext,
    Size defaultViewportSize,
  ) {
    return maybeGetBounds(overlayContext) ??
        (Offset.zero & defaultViewportSize);
  }

  @override
  State<FlexOverlayScope> createState() => _FlexOverlayScopeState();
}

class _FlexOverlayScopeState extends State<FlexOverlayScope> {
  final GlobalKey _scopeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _FlexOverlayScopeData(
      scopeKey: _scopeKey,
      child: Container(key: _scopeKey, child: widget.child),
    );
  }
}

/// InheritedWidget that provides scope information to descendants.
class _FlexOverlayScopeData extends InheritedWidget {
  final GlobalKey _scopeKey;

  const _FlexOverlayScopeData({
    required GlobalKey scopeKey,
    required super.child,
  }) : _scopeKey = scopeKey;

  @override
  bool updateShouldNotify(_FlexOverlayScopeData oldWidget) {
    return _scopeKey != oldWidget._scopeKey;
  }
}

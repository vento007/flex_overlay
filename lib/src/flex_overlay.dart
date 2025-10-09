import 'package:flutter/material.dart';

import 'interaction_controller.dart';
import 'models.dart';
import 'popup_scope.dart';
import 'position_strategy.dart';

/// A widget that displays content in a floating popup positioned relative to a trigger.
///
/// This is a pure positioning system - styling is the user's responsibility.
/// Uses Flutter 3.29+ OverlayPortal.overlayChildLayoutBuilder for proper positioning.
class FlexOverlay extends StatefulWidget {
  /// Builder for the trigger widget. Receives [isActive] state.
  /// If you don't need the active state, simply ignore the parameter.
  final Widget Function(bool isActive) child;

  /// The content to display in the popup.
  final Widget content;

  /// Position configuration.
  final PositionConfig positionConfig;

  /// Interaction configuration.
  final InteractionConfig interactionConfig;

  /// If provided, overrides interaction-based visibility.
  /// - `null` (default): visibility controlled by hover/click interactions
  /// - `true`: always shown (programmatic control)
  /// - `false`: always hidden (programmatic control)
  final bool? visible;

  const FlexOverlay({
    super.key,
    required this.child,
    required this.content,
    this.positionConfig = const PositionConfig.top(),
    this.interactionConfig = const InteractionConfig(),
    this.visible,
  });

  @override
  State<FlexOverlay> createState() => _FlexOverlayState();
}

class _FlexOverlayState extends State<FlexOverlay> with WidgetsBindingObserver {
  late final OverlayPortalController _portalController;
  late final InteractionController _interactionController;

  @override
  void initState() {
    super.initState();
    _portalController = OverlayPortalController();
    _interactionController = InteractionController(widget.interactionConfig);
    _interactionController.addListener(_onInteractionChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _interactionController.removeListener(_onInteractionChanged);
    _interactionController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FlexOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update interaction controller config if it changed
    if (oldWidget.interactionConfig != widget.interactionConfig) {
      _interactionController.config = widget.interactionConfig;
      _interactionController.hide();
    }

    // Hide if position config changed
    if (oldWidget.positionConfig != widget.positionConfig) {
      _interactionController.hide();
    }

    // Handle programmatic visibility changes
    if (oldWidget.visible != widget.visible) {
      // Defer visibility change to after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateVisibility();
        }
      });
    }
  }

  void _updateVisibility() {
    // If visible is explicitly set, use it; otherwise use interaction state
    final shouldShow = widget.visible ?? _interactionController.isShown;

    if (shouldShow && !_portalController.isShowing) {
      _portalController.show();
    } else if (!shouldShow && _portalController.isShowing) {
      _portalController.hide();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Hide on screen rotation/resize
    if (_interactionController.isShown) {
      _interactionController.hide();
    }
  }

  void _onInteractionChanged() {
    // Only respond to interaction changes if visibility is not controlled externally
    if (widget.visible == null) {
      _updateVisibility();
    }
    setState(() {}); // Rebuild to update trigger active state
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _portalController,
      overlayChildBuilder: _buildOverlayChild,
      child: _buildTrigger(),
    );
  }

  Widget _buildTrigger() {
    final isActive =
        _interactionController.isShown || _interactionController.isHovered;

    Widget trigger = widget.child(isActive);

    // Wrap with interaction handlers
    trigger = MouseRegion(
      onEnter: (_) => _interactionController.onTriggerEnter(),
      onExit: (_) => _interactionController.onTriggerExit(),
      child: trigger,
    );

    // Add click handling - use both Listener AND GestureDetector to block parent gestures
    if (widget.interactionConfig.mode == InteractionMode.click) {
      trigger = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Dummy onTap to win gesture arena against parent
        child: Listener(
          onPointerDown: (_) => _interactionController.onTriggerTap(),
          behavior: HitTestBehavior.opaque,
          child: trigger,
        ),
      );
    }

    return trigger;
  }

  Widget _buildOverlayChild(
    BuildContext context,
    OverlayChildLayoutInfo layoutInfo,
  ) {
    return _PositionedPopup(
      layoutInfo: layoutInfo,
      content: widget.content,
      positionConfig: widget.positionConfig,
      interactionConfig: widget.interactionConfig,
      isProgrammatic:
          widget.visible !=
          null, // Don't add backdrop if programmatically controlled
      onPopupEnter: _interactionController.onPopupEnter,
      onPopupExit: _interactionController.onPopupExit,
      onBackdropTap: _interactionController.onBackdropTap,
    );
  }
}

/// Internal widget that measures and positions the popup.
class _PositionedPopup extends StatefulWidget {
  final OverlayChildLayoutInfo layoutInfo;
  final Widget content;
  final PositionConfig positionConfig;
  final InteractionConfig interactionConfig;
  final bool isProgrammatic;
  final VoidCallback onPopupEnter;
  final VoidCallback onPopupExit;
  final VoidCallback onBackdropTap;

  const _PositionedPopup({
    required this.layoutInfo,
    required this.content,
    required this.positionConfig,
    required this.interactionConfig,
    required this.isProgrammatic,
    required this.onPopupEnter,
    required this.onPopupExit,
    required this.onBackdropTap,
  });

  @override
  State<_PositionedPopup> createState() => _PositionedPopupState();
}

class _PositionedPopupState extends State<_PositionedPopup> {
  final GlobalKey _measureKey = GlobalKey();
  Size? _measuredSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePopup());
  }

  @override
  void didUpdateWidget(covariant _PositionedPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      setState(() {
        _measuredSize = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _measurePopup());
    }
  }

  void _measurePopup() {
    final renderBox =
        _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && mounted) {
      setState(() {
        _measuredSize = renderBox.size;
      });
    }
  }

  void _onSizeChanged(Size newSize) {
    if (_measuredSize != null && _measuredSize != newSize && mounted) {
      setState(() {
        _measuredSize = newSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlaySize = widget.layoutInfo.overlaySize;

    // Use overlay bounds as measurement constraints
    // This prevents issues with unbounded intrinsic sizes from scrollables/flex
    final measureConstraints = BoxConstraints(
      maxWidth: overlaySize.width,
      maxHeight: overlaySize.height,
    );

    // First frame: measure the popup with finite constraints
    if (_measuredSize == null) {
      return Positioned(
        left: 0,
        top: 0,
        child: Opacity(
          opacity: 0,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: measureConstraints,
                child: Container(key: _measureKey, child: widget.content),
              ),
            ),
          ),
        ),
      );
    }

    // Extract layout info from the new API
    final childSize = widget.layoutInfo.childSize;
    final childTransform = widget.layoutInfo.childPaintTransform;

    // Transform the child's origin (0,0) to overlay coordinates
    final childOriginInOverlay = MatrixUtils.transformPoint(
      childTransform,
      Offset.zero,
    );

    // Create trigger rect in overlay coordinates
    final triggerRect = childOriginInOverlay & childSize;

    // Viewport is either the scope bounds (if wrapped in FlexOverlayScope)
    // or the full overlay bounds (default behavior)
    final viewportRect = FlexOverlayScope.getBoundsOrDefault(
      context,
      overlaySize,
    );

    // Calculate position
    final position = PositionStrategy.calculate(
      triggerRect: triggerRect,
      popupSize: _measuredSize!,
      viewportRect: viewportRect,
      config: widget.positionConfig,
    );

    // Apply the same constraints during final render to match measurement
    final popupContent = ConstrainedBox(
      constraints: measureConstraints,
      child: widget.content,
    );

    // Build popup with interaction handlers and size change detection
    Widget popup = Material(
      color: Colors.transparent,
      child: _SizeChangeNotifier(
        onSizeChanged: _onSizeChanged,
        child: popupContent,
      ),
    );

    if (widget.interactionConfig.mode == InteractionMode.hover) {
      popup = MouseRegion(
        onEnter: (_) => widget.onPopupEnter(),
        onExit: (_) => widget.onPopupExit(),
        child: popup,
      );
    }

    return Stack(
      children: [
        // Backdrop for click-outside-to-dismiss (only for interaction mode, not programmatic)
        if (widget.interactionConfig.mode == InteractionMode.click &&
            !widget.isProgrammatic)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onBackdropTap,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
        // The popup positioned in overlay coordinates
        Positioned(
          left: triggerRect.left + position.offset.dx,
          top: triggerRect.top + position.offset.dy,
          child: popup,
        ),
      ],
    );
  }
}

/// Widget that notifies when its child's size changes.
class _SizeChangeNotifier extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChanged;

  const _SizeChangeNotifier({required this.child, required this.onSizeChanged});

  @override
  State<_SizeChangeNotifier> createState() => _SizeChangeNotifierState();
}

class _SizeChangeNotifierState extends State<_SizeChangeNotifier> {
  Size? _previousSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final currentSize = renderBox.size;
            if (_previousSize != currentSize) {
              _previousSize = currentSize;
              widget.onSizeChanged(currentSize);
            }
          }
        });

        return widget.child;
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'models.dart';

/// Manages the interaction state and behavior of a popup.
class InteractionController extends ChangeNotifier {
  InteractionConfig config;

  bool _isHoveringTrigger = false;
  bool _isHoveringPopup = false;
  bool _isShown = false;

  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _autoHideTimer;

  InteractionController(this.config);

  /// Whether the popup is currently visible.
  bool get isShown => _isShown;

  /// Whether the trigger or popup is being hovered.
  bool get isHovered => _isHoveringTrigger || _isHoveringPopup;

  /// Called when the mouse enters the trigger widget.
  void onTriggerEnter() {
    _isHoveringTrigger = true;
    notifyListeners();

    if (config.mode == InteractionMode.hover && !_isShown) {
      _cancelHideTimer();
      _scheduleShow();
    }
  }

  /// Called when the mouse exits the trigger widget.
  void onTriggerExit() {
    _isHoveringTrigger = false;
    notifyListeners();

    if (config.mode == InteractionMode.hover) {
      _cancelShowTimer();
      _scheduleHide();
    }
  }

  /// Called when the mouse enters the popup.
  void onPopupEnter() {
    _isHoveringPopup = true;
    notifyListeners();

    if (config.mode == InteractionMode.hover) {
      _cancelHideTimer();
    }
  }

  /// Called when the mouse exits the popup.
  void onPopupExit() {
    _isHoveringPopup = false;
    notifyListeners();

    if (config.mode == InteractionMode.hover) {
      _scheduleHide();
    }
  }

  /// Called when the trigger is tapped/clicked.
  void onTriggerTap() {
    if (config.mode == InteractionMode.click) {
      toggle();
    }
  }

  /// Called when clicking outside the popup (to dismiss).
  void onBackdropTap() {
    if (config.mode == InteractionMode.click) {
      hide();
    }
  }

  /// Show the popup immediately.
  void show() {
    _cancelShowTimer();
    _cancelHideTimer();

    if (!_isShown) {
      _isShown = true;
      notifyListeners();

      // Start auto-hide timer if configured
      if (config.autoHideTimeout != null) {
        _autoHideTimer?.cancel();
        _autoHideTimer = Timer(config.autoHideTimeout!, hide);
      }
    }
  }

  /// Hide the popup immediately.
  void hide() {
    _cancelShowTimer();
    _cancelHideTimer();
    _cancelAutoHideTimer();

    if (_isShown) {
      _isShown = false;
      notifyListeners();
    }
  }

  /// Toggle the popup visibility.
  void toggle() {
    if (_isShown) {
      hide();
    } else {
      show();
    }
  }

  void _scheduleShow() {
    _showTimer?.cancel();
    _showTimer = Timer(config.hoverShowDelay, () {
      if (_isHoveringTrigger) {
        show();
      }
    });
  }

  void _scheduleHide() {
    if (!_isHoveringTrigger && !_isHoveringPopup) {
      _hideTimer?.cancel();
      _hideTimer = Timer(config.hoverHideDelay, () {
        if (!_isHoveringTrigger && !_isHoveringPopup) {
          hide();
        }
      });
    }
  }

  void _cancelShowTimer() {
    _showTimer?.cancel();
    _showTimer = null;
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _cancelAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
  }

  @override
  void dispose() {
    _cancelShowTimer();
    _cancelHideTimer();
    _cancelAutoHideTimer();
    super.dispose();
  }
}

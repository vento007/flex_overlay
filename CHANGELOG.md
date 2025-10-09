## 0.6.1

### Improved

* **Click Response** - Replaced `onTap` with `onTapDown` for instant tooltip response without double-tap detection delay

## 0.6.0

### Fixed

* **Scrollable Content Support** - Fixed `RenderBox was not laid out` errors when popup content contains `Flexible` + `SingleChildScrollView` or other widgets with unbounded intrinsic sizes. Replaced intrinsic measurement with constrained measurement using overlay bounds. (Fixes #1)

## 0.5.0

Initial release of FlexOverlay - a pure positioning system for Flutter popups and tooltips.

### Features

* **Smart Positioning** - Alignment-based positioning with automatic fallback strategies
* **Edge-Aware** - Automatically keeps popups within screen bounds with configurable margins
* **Overlap Detection** - Prevents popups from covering trigger widgets
* **Dual Interaction Modes** - Support for both click and hover interactions
* **Programmatic Control** - External state control via `visible` parameter
* **Scoped Boundaries** - `FlexOverlayScope` for constraining popups to specific regions
* **Auto-Hide** - Optional timeout for automatic dismissal
* **Pure Positioning** - No styling imposed, complete control over appearance
* **Dynamic Content** - Handles content size changes gracefully
* **Zero Dependencies** - Pure Flutter implementation

### API

* `FlexOverlay` - Main widget for creating positioned popups
* `PositionConfig` - Configuration for positioning behavior with presets (`.top()`, `.bottom()`, `.left()`, `.right()`)
* `InteractionConfig` - Configuration for click/hover interactions
* `FlexOverlayScope` - Boundary constraints for popup positioning
* `InteractionMode` - Enum for click vs hover modes

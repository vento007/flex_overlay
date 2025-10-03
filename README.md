<div align="center">

<p>
  <img src="https://raw.githubusercontent.com/vento007/flex_overlay/main/media/logo.png" alt="FlexOverlay Logo" width="420" />
</p>

<h1 align="center">flex overlay — pure positioning for Flutter popups & tooltips</h1>

<p align="center"><em>Smart positioning system without imposed styling—complete control over appearance</em></p>

<p align="center">
  <a href="https://pub.dev/packages/flex_overlay">
    <img src="https://img.shields.io/pub/v/flex_overlay.svg" alt="Pub">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT">
  </a>
  <a href="https://dart.dev/">
    <img src="https://img.shields.io/badge/dart-3.8.0%2B-blue.svg" alt="Dart Version">
  </a>
  <img src="https://img.shields.io/badge/platform-flutter%20|%20web%20|%20mobile%20|%20desktop-blue.svg" alt="Platform Support">
  <a href="https://github.com/vento007/flex_overlay/issues">
    <img src="https://img.shields.io/github/issues/vento007/flex_overlay.svg" alt="Open Issues">
  </a>
  <a href="https://github.com/vento007/flex_overlay/pulls">
    <img src="https://img.shields.io/github/issues-pr/vento007/flex_overlay.svg" alt="Pull Requests">
  </a>
  <a href="https://github.com/vento007/flex_overlay/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/vento007/flex_overlay.svg" alt="Contributors">
  </a>
  <img src="https://img.shields.io/github/last-commit/vento007/flex_overlay.svg" alt="Last Commit">

</p>

<hr>

</div>

## Features

- **Pure Positioning** - No styling imposed, you control 100% of the appearance  
- **Smart Alignment** - Alignment-based positioning with automatic fallback strategies  
- **Dual Interaction Modes** - Click or hover interactions  
- **Programmatic Control** - Show/hide via external state  
- **Edge-Aware** - Automatically keeps popups within screen bounds  
- **Fully Customizable** - Gap, offset, edge margins all configurable  
- **Dynamic Content** - Handles content size changes gracefully  
- **Scoped Boundaries** - Constrain popups to specific regions  
- **Auto-Hide** - Optional timeout for automatic dismissal  
- **Zero Dependencies** - Pure Flutter, no extra packages

## Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/vento007/flex_overlay/main/media/example-app.png" alt="FlexOverlay Example App" width="800" />
</p>

## Quick Start

```dart
import 'package:flex_overlay/flex_overlay.dart';
```

### Minimal Example

The simplest tooltip using all defaults:

```dart
FlexOverlay(
  content: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('Simple tooltip!', style: TextStyle(color: Colors.white)),
  ),
  child: (_) => Text('Hover me'), // Ignore active state if not needed
)
```

### Basic Tooltip with Custom Position

```dart
FlexOverlay(
  positionConfig: PositionConfig.bottom(), // Show below trigger
  content: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue.shade700,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Text('Bottom tooltip', style: TextStyle(color: Colors.white)),
  ),
  child: (isActive) => ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: isActive ? Colors.blue.shade700 : Colors.blue,
    ),
    child: Text('Click me'),
  ),
)
```

## Core Concepts

### 1. Interaction Modes

**Click Mode (default)**
```dart
FlexOverlay(
  interactionConfig: InteractionConfig(mode: InteractionMode.click),
  content: YourPopup(),
  child: (isActive) => YourTrigger(isActive),
)
```

**Hover Mode**
```dart
FlexOverlay(
  interactionConfig: InteractionConfig(
    mode: InteractionMode.hover,
    hoverShowDelay: Duration(milliseconds: 120),
    hoverHideDelay: Duration(milliseconds: 120),
  ),
  content: YourPopup(),
  child: (isActive) => YourTrigger(isActive),
)
```

### 2. Positioning

**Preset Positions**
```dart
// Top, Bottom, Left, Right
PositionConfig.top()
PositionConfig.bottom()
PositionConfig.left()
PositionConfig.right()
```

**Custom Alignment-Based Positioning**
```dart
PositionConfig(
  targetAlignment: Alignment.topCenter,    // Point on trigger
  followerAlignment: Alignment.bottomCenter, // Point on popup
  gap: 8.0,                                // Space between trigger and popup
  edgeMargin: 16.0,                        // Minimum margin from screen edges
  offset: Offset(0, 5),                    // Additional manual offset
)
```

**Examples**
```dart
// Popup above trigger, aligned to left edges
PositionConfig(
  targetAlignment: Alignment.topLeft,
  followerAlignment: Alignment.bottomLeft,
  gap: 8.0,
)

// Popup to the right, aligned at centers
PositionConfig(
  targetAlignment: Alignment.centerRight,
  followerAlignment: Alignment.centerLeft,
  gap: 12.0,
)
```

### 3. Programmatic Control

Control visibility externally using the `visible` property:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _showTooltip = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _showTooltip = !_showTooltip),
          child: Text('Toggle'),
        ),
        FlexOverlay(
          visible: _showTooltip, // External control
          content: YourPopup(),
          child: (_) => YourTrigger(),
        ),
      ],
    );
  }
}
```

### 4. Child Builder

The `child` builder receives the active state - use it if needed, or ignore it:

**With active state styling:**
```dart
FlexOverlay(
  content: YourPopup(),
  child: (isActive) => Container(
    decoration: BoxDecoration(
      color: isActive ? Colors.blue.shade700 : Colors.blue,
    ),
    child: Text('Styled on active'),
  ),
)
```

**Without active state (just ignore the parameter):**
```dart
FlexOverlay(
  content: YourPopup(),
  child: (_) => Icon(Icons.info_outline),
)
```

## Advanced Features

### Auto-Hide Timeout

Automatically hide popup after a duration:

```dart
FlexOverlay(
  interactionConfig: InteractionConfig(
    mode: InteractionMode.click,
    autoHideTimeout: Duration(seconds: 3), // Auto-hide after 3s
  ),
  content: YourPopup(),
  child: (isActive) => YourTrigger(isActive),
)
```

### Scoped Boundaries

Constrain popups to stay within a specific region:

```dart
FlexOverlayScope(
  child: Sidebar(
    child: Column(
      children: [
        FlexOverlay(
          // This popup will stay within the sidebar bounds
          content: YourPopup(),
          child: (isActive) => YourTrigger(isActive),
        ),
      ],
    ),
  ),
)
```

Perfect for:
- Sidebars
- Dialogs
- Panels
- Scrollable regions
- Split-pane layouts

### Fine-Tuning Position

```dart
FlexOverlay(
  positionConfig: PositionConfig(
    targetAlignment: Alignment.topCenter,
    followerAlignment: Alignment.bottomCenter,
    gap: 12.0,           // Space between trigger and popup
    edgeMargin: 20.0,    // Minimum distance from screen edges
    offset: Offset(5, -3), // Additional manual tweaking
  ),
  content: YourPopup(),
  child: (isActive) => YourTrigger(isActive),
)
```

### Rich Content Popups

FlexOverlay doesn't impose styling, so you can create any design:

```dart
FlexOverlay(
  content: Container(
    constraints: BoxConstraints(maxWidth: 350),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple.shade50, Colors.blue.shade50],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 12),
            Text('Pro Tip', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12),
        Text('You have complete control over styling!'),
        SizedBox(height: 16),
        ElevatedButton(onPressed: () {}, child: Text('Learn More')),
      ],
    ),
  ),
  child: (isActive) => YourTrigger(isActive),
)
```

## Common Use Cases

### Tooltip
```dart
FlexOverlay(
  interactionConfig: InteractionConfig(mode: InteractionMode.hover),
  positionConfig: PositionConfig.top(),
  content: Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade800,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text('Tooltip text', style: TextStyle(color: Colors.white)),
  ),
  child: (_) => Icon(Icons.help_outline),
)
```

### Dropdown Menu
```dart
FlexOverlay(
  interactionConfig: InteractionConfig(mode: InteractionMode.click),
  positionConfig: PositionConfig.bottom(),
  content: Container(
    width: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: Text('Option 1'), onTap: () {}),
        ListTile(title: Text('Option 2'), onTap: () {}),
        ListTile(title: Text('Option 3'), onTap: () {}),
      ],
    ),
  ),
  child: (isActive) => TextButton(
    onPressed: () {},
    child: Row(
      children: [
        Text('Menu'),
        Icon(isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down),
      ],
    ),
  ),
)
```

### Context Menu
```dart
FlexOverlay(
  interactionConfig: InteractionConfig(mode: InteractionMode.click),
  positionConfig: PositionConfig(
    targetAlignment: Alignment.bottomRight,
    followerAlignment: Alignment.topRight,
  ),
  content: YourContextMenu(),
  child: (isActive) => IconButton(
    icon: Icon(Icons.more_vert),
    onPressed: () {},
  ),
)
```

### Popover Card
```dart
FlexOverlay(
  interactionConfig: InteractionConfig(mode: InteractionMode.click),
  positionConfig: PositionConfig.bottom(),
  content: Card(
    elevation: 8,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('email@example.com'),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: Text('View Profile')),
        ],
      ),
    ),
  ),
  child: (isActive) => CircleAvatar(child: Icon(Icons.person)),
)
```

## API Reference

### FlexOverlay

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget Function(bool isActive)` | **required** | Builder for trigger widget that receives active state. Ignore the parameter if you don't need it. |
| `content` | `Widget` | **required** | The popup content to display |
| `positionConfig` | `PositionConfig` | `PositionConfig.top()` | Position configuration |
| `interactionConfig` | `InteractionConfig` | `InteractionConfig()` | Interaction behavior configuration |
| `visible` | `bool?` | `null` | Override for programmatic control |

### PositionConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `targetAlignment` | `Alignment` | **required** | Point on trigger widget |
| `followerAlignment` | `Alignment` | **required** | Point on popup widget |
| `gap` | `double` | `8.0` | Space between trigger and popup |
| `edgeMargin` | `double` | `16.0` | Minimum margin from screen edges |
| `offset` | `Offset?` | `null` | Additional manual offset |

**Presets:** `.top()`, `.bottom()`, `.left()`, `.right()`

### InteractionConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mode` | `InteractionMode` | `InteractionMode.click` | Click or hover interaction |
| `hoverShowDelay` | `Duration` | `120ms` | Delay before showing on hover |
| `hoverHideDelay` | `Duration` | `120ms` | Delay before hiding after hover exit |
| `autoHideTimeout` | `Duration?` | `null` | Auto-hide after duration |

### FlexOverlayScope

| Parameter | Type | Description |
|-----------|------|-------------|
| `child` | `Widget` | Widget tree defining the constrained region |

## Tips & Best Practices

1. **Use alignment-based positioning** for stable popups that don't jump when content size changes
2. **Set appropriate edge margins** to ensure popups don't touch screen edges
3. **Use FlexOverlayScope** when working with sidebars, panels, or split layouts
4. **Leverage programmatic control** for complex UI flows (wizards, tours, etc.)
5. **Keep hover delays reasonable** (100-200ms) for good UX
6. **Style your popups consistently** across your app for a cohesive experience

## Example App

Run the example app to see all features in action:

```bash
cd example
flutter run
```

The example demonstrates:
- All positioning modes
- Click vs hover interactions
- Programmatic control
- Edge constraint handling
- Dynamic content
- Fine-tuning parameters
- Scoped boundaries
- Rich content styling

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

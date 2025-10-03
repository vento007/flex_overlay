import 'package:flutter/material.dart';
import 'package:flex_overlay/flex_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flex Overlay Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  InteractionMode _interactionMode = InteractionMode.click;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flex Overlay Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic Examples', icon: Icon(Icons.grid_view)),
            Tab(text: 'Scope Examples', icon: Icon(Icons.crop_square)),
          ],
        ),
        actions: [
          // Toggle between click and hover modes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<InteractionMode>(
              segments: const [
                ButtonSegment(
                  value: InteractionMode.click,
                  label: Text('Click'),
                  icon: Icon(Icons.touch_app),
                ),
                ButtonSegment(
                  value: InteractionMode.hover,
                  label: Text('Hover'),
                  icon: Icon(Icons.mouse),
                ),
              ],
              selected: {_interactionMode},
              onSelectionChanged: (Set<InteractionMode> newSelection) {
                setState(() {
                  _interactionMode = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BasicExamplesPage(interactionMode: _interactionMode),
          ScopeExamplesPage(interactionMode: _interactionMode),
        ],
      ),
    );
  }
}

class BasicExamplesPage extends StatefulWidget {
  final InteractionMode interactionMode;

  const BasicExamplesPage({super.key, required this.interactionMode});

  @override
  State<BasicExamplesPage> createState() => _BasicExamplesPageState();
}

class _BasicExamplesPageState extends State<BasicExamplesPage> {
  InteractionMode get _interactionMode => widget.interactionMode;
  bool _showProgrammaticTooltip = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Mode indicator
          Center(
            child: Text(
              'Mode: ${_interactionMode == InteractionMode.click ? 'Click to toggle' : 'Hover to show'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 40),

          // Programmatic control example
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Programmatic Control',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          _buildProgrammaticExample(),

          const SizedBox(height: 40),

          // Minimal example with defaults
          Center(
            child: FlexOverlay(
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Minimal - all defaults!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              child: (_) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('No config (defaults)'),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Position Examples Grid
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: [
                _buildExample(
                  'Top',
                  const PositionConfig.top(),
                  Colors.blue,
                  _interactionMode,
                ),
                _buildExample(
                  'Bottom',
                  const PositionConfig.bottom(),
                  Colors.green,
                  _interactionMode,
                ),
                _buildExample(
                  'Left',
                  const PositionConfig.left(),
                  Colors.orange,
                  _interactionMode,
                ),
                _buildExample(
                  'Right',
                  const PositionConfig.right(),
                  Colors.purple,
                  _interactionMode,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),

          // Edge case examples
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Edge Cases',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Edge constraint examples
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Edge Constraint Handling',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Near screen edges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top-left corner
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlexOverlay(
                  positionConfig: const PositionConfig.bottom(),
                  interactionConfig: InteractionConfig(mode: _interactionMode),
                  content: _buildStyledPopup(
                    'Should stay on screen!',
                    Colors.red,
                  ),
                  child: (isActive) =>
                      _buildButton('Top-Left', Colors.red, isActive),
                ),
              ),
              // Top-right corner
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlexOverlay(
                  positionConfig: const PositionConfig.bottom(),
                  interactionConfig: InteractionConfig(mode: _interactionMode),
                  content: _buildStyledPopup(
                    'Should stay on screen!',
                    Colors.red,
                  ),
                  child: (isActive) =>
                      _buildButton('Top-Right', Colors.red, isActive),
                ),
              ),
            ],
          ),

          const SizedBox(height: 200),

          // Custom styled example
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Custom Styling Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Rich content popup
          FlexOverlay(
            positionConfig: const PositionConfig.top(),
            interactionConfig: InteractionConfig(mode: _interactionMode),
            content: _buildRichPopup(),
            child: (isActive) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? Colors.indigo.shade700 : Colors.indigo,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.indigo.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Rich Content',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),

          // Dynamic content example - content with internal state
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Dynamic Content (Internal State)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // ⭐ ALIGNMENT-BASED: bottomCenter of popup → topCenter of trigger
          // Fixed anchor point = no jumping when content size changes!
          // (Compare this to legacy "position: PopupPosition.top" above)
          FlexOverlay(
            positionConfig: const PositionConfig(
              targetAlignment: Alignment.topCenter, // Anchor on trigger
              followerAlignment: Alignment.bottomCenter, // Anchor on popup
            ),
            interactionConfig: InteractionConfig(mode: _interactionMode),
            content: const _DynamicSettingsPopup(),
            child: (isActive) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? Colors.teal.shade700 : Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Settings (Dynamic Size)',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Alignment-based positioning examples
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Alignment-Based Positioning (No Jumping!)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // Top positions
              _buildAlignmentExample(
                '↑ Top Center',
                Alignment.topCenter,
                Alignment.bottomCenter,
                Colors.blue,
              ),
              _buildAlignmentExample(
                '↑ Top Left',
                Alignment.topLeft,
                Alignment.bottomLeft,
                Colors.lightBlue,
              ),
              _buildAlignmentExample(
                '↑ Top Right',
                Alignment.topRight,
                Alignment.bottomRight,
                Colors.indigo,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // Right side positions
              _buildAlignmentExample(
                '→ Right Top',
                Alignment.topRight,
                Alignment.topLeft,
                Colors.purple,
              ),
              _buildAlignmentExample(
                '→ Right Center',
                Alignment.centerRight,
                Alignment.centerLeft,
                Colors.deepPurple,
              ),
              _buildAlignmentExample(
                '→ Right Bottom',
                Alignment.bottomRight,
                Alignment.bottomLeft,
                Colors.purpleAccent,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // Bottom positions
              _buildAlignmentExample(
                '↓ Bottom Left',
                Alignment.bottomLeft,
                Alignment.topLeft,
                Colors.orange,
              ),
              _buildAlignmentExample(
                '↓ Bottom Center',
                Alignment.bottomCenter,
                Alignment.topCenter,
                Colors.deepOrange,
              ),
              _buildAlignmentExample(
                '↓ Bottom Right',
                Alignment.bottomRight,
                Alignment.topRight,
                Colors.orangeAccent,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // Left side positions
              _buildAlignmentExample(
                '← Left Top',
                Alignment.topLeft,
                Alignment.topRight,
                Colors.teal,
              ),
              _buildAlignmentExample(
                '← Left Center',
                Alignment.centerLeft,
                Alignment.centerRight,
                Colors.cyan,
              ),
              _buildAlignmentExample(
                '← Left Bottom',
                Alignment.bottomLeft,
                Alignment.bottomRight,
                Colors.tealAccent,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Interactive Fine-Tuning Demo
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Interactive Fine-Tuning',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          _buildFineTuningDemo(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProgrammaticExample() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    setState(() => _showProgrammaticTooltip = true),
                icon: const Icon(Icons.visibility),
                label: const Text('Show'),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    setState(() => _showProgrammaticTooltip = false),
                icon: const Icon(Icons.visibility_off),
                label: const Text('Hide'),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(
                  () => _showProgrammaticTooltip = !_showProgrammaticTooltip,
                ),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Toggle'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FlexOverlay(
            visible: _showProgrammaticTooltip, // ← Programmatic control!
            positionConfig: const PositionConfig.bottom(),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '✨ Controlled externally!\nUse buttons above to show/hide',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
            child: (_) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade300, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.purple.shade700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Programmatic Target',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFineTuningDemo() {
    return const _FineTuningDemo();
  }

  Widget _buildAlignmentExample(
    String label,
    Alignment targetAlign,
    Alignment followerAlign,
    Color color,
  ) {
    return FlexOverlay(
      positionConfig: PositionConfig(
        targetAlignment: targetAlign,
        followerAlignment: followerAlign,
        gap: 8.0,
      ),
      interactionConfig: InteractionConfig(mode: _interactionMode),
      content: _buildStyledPopup(
        '✨ ALIGNMENT-BASED\n\n$label\nTarget: $targetAlign\nFollower: $followerAlign\n\nThis uses fixed anchor points - no jumping when content changes!',
        color,
      ),
      child: (isActive) => _buildButton(label, color, isActive),
    );
  }

  Widget _buildExample(
    String label,
    PositionConfig positionConfig,
    Color color,
    InteractionMode mode,
  ) {
    return FlexOverlay(
      positionConfig: positionConfig,
      interactionConfig: InteractionConfig(mode: mode),
      content: _buildStyledPopup('This is a $label positioned popup!', color),
      child: (isActive) => _buildButton(label, color, isActive),
    );
  }

  Widget _buildButton(String label, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.8) : color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStyledPopup(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildRichPopup() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: Colors.indigo.shade700),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pro Tip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'You have complete control over the styling! '
            'This popup demonstrates rich content with custom layouts, '
            'colors, and shadows.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text('Learn More')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FineTuningDemo extends StatefulWidget {
  const _FineTuningDemo();

  @override
  State<_FineTuningDemo> createState() => _FineTuningDemoState();
}

class _FineTuningDemoState extends State<_FineTuningDemo> {
  double _gap = 8.0;
  double _edgeMargin = 16.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Control Panel
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adjust Parameters:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Gap Slider
              Text('Gap: ${_gap.toInt()}px'),
              Slider(
                value: _gap,
                min: 0,
                max: 50,
                divisions: 50,
                label: _gap.toInt().toString(),
                onChanged: (value) => setState(() => _gap = value),
              ),

              const SizedBox(height: 8),

              // Edge Margin Slider
              Text('Edge Margin: ${_edgeMargin.toInt()}px'),
              Slider(
                value: _edgeMargin,
                min: 0,
                max: 50,
                divisions: 50,
                label: _edgeMargin.toInt().toString(),
                onChanged: (value) => setState(() => _edgeMargin = value),
              ),

              const SizedBox(height: 8),

              // Offset X Slider
              Text('Offset X: ${_offsetX.toInt()}px'),
              Slider(
                value: _offsetX,
                min: -50,
                max: 50,
                divisions: 100,
                label: _offsetX.toInt().toString(),
                onChanged: (value) => setState(() => _offsetX = value),
              ),

              const SizedBox(height: 8),

              // Offset Y Slider
              Text('Offset Y: ${_offsetY.toInt()}px'),
              Slider(
                value: _offsetY,
                min: -50,
                max: 50,
                divisions: 100,
                label: _offsetY.toInt().toString(),
                onChanged: (value) => setState(() => _offsetY = value),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Center demo
        Center(
          child: FlexOverlay(
            positionConfig: PositionConfig(
              targetAlignment: Alignment.topCenter,
              followerAlignment: Alignment.bottomCenter,
              gap: _gap,
              edgeMargin: _edgeMargin,
              offset: Offset(_offsetX, _offsetY),
            ),
            interactionConfig: const InteractionConfig(
              mode: InteractionMode.click,
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎛️ Live Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Gap: ${_gap.toInt()}px'),
                  Text('Edge Margin: ${_edgeMargin.toInt()}px'),
                  Text('Offset: (${_offsetX.toInt()}, ${_offsetY.toInt()})'),
                ],
              ),
            ),
            child: (isActive) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Test Fine-Tuning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Edge test examples
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Test Edge Margin (try setting to 0 vs 50):',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top-left corner
              FlexOverlay(
                positionConfig: PositionConfig(
                  targetAlignment: Alignment.bottomCenter,
                  followerAlignment: Alignment.topCenter,
                  gap: _gap,
                  edgeMargin: _edgeMargin,
                  offset: Offset(_offsetX, _offsetY),
                ),
                interactionConfig: const InteractionConfig(
                  mode: InteractionMode.click,
                ),
                content: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍 Top-Left'),
                      Text('Margin: ${_edgeMargin.toInt()}px'),
                    ],
                  ),
                ),
                child: (isActive) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.red.shade700 : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.north_west,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Top-right corner
              FlexOverlay(
                positionConfig: PositionConfig(
                  targetAlignment: Alignment.bottomCenter,
                  followerAlignment: Alignment.topCenter,
                  gap: _gap,
                  edgeMargin: _edgeMargin,
                  offset: Offset(_offsetX, _offsetY),
                ),
                interactionConfig: const InteractionConfig(
                  mode: InteractionMode.click,
                ),
                content: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍 Top-Right'),
                      Text('Margin: ${_edgeMargin.toInt()}px'),
                    ],
                  ),
                ),
                child: (isActive) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.shade700 : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.north_east,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A popup with internal state that changes its size
class _DynamicSettingsPopup extends StatefulWidget {
  const _DynamicSettingsPopup();

  @override
  State<_DynamicSettingsPopup> createState() => _DynamicSettingsPopupState();
}

class _DynamicSettingsPopupState extends State<_DynamicSettingsPopup> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _showAdvanced = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // ← Fixed width prevents anchor point from shifting!
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Notifications'),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),

          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),

          SwitchListTile(
            title: const Text('Show Advanced'),
            value: _showAdvanced,
            onChanged: (value) => setState(() => _showAdvanced = value),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),

          // Advanced options appear when toggle is on (changes popup size!)
          if (_showAdvanced) ...[
            const Divider(),
            const Text(
              'Advanced Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['English', 'Spanish', 'French', 'German']
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _language = value!),
            ),

            const SizedBox(height: 8),

            const TextField(
              decoration: InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Reset')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Page demonstrating FlexOverlayScope feature
class ScopeExamplesPage extends StatelessWidget {
  final InteractionMode interactionMode;

  const ScopeExamplesPage({super.key, required this.interactionMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'FlexOverlayScope Examples',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'These examples show how FlexOverlayScope constrains popups to stay within a specific region.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Example 1: Sidebar with scope
            _buildSidebarExample(context),

            const SizedBox(height: 40),

            // Example 2: Two-column layout
            _buildTwoColumnExample(context),

            const SizedBox(height: 40),

            // Example 3: Comparison (with vs without scope)
            _buildComparisonExample(context),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. Sidebar Panel', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Popups stay within the 300px sidebar even when triggers are near edges',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Sidebar demo
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Sidebar with scope
              FlexOverlayScope(
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      right: BorderSide(color: Colors.blue.shade200, width: 2),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sidebar (With Scope)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Popups constrained to this area',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Button near top-right
                      Align(
                        alignment: Alignment.topRight,
                        child: FlexOverlay(
                          positionConfig: const PositionConfig.right(),
                          interactionConfig: InteractionConfig(
                            mode: interactionMode,
                          ),
                          content: _buildScopePopup(
                            'Stays in sidebar!',
                            Colors.blue,
                          ),
                          child: (isActive) => _buildScopeButton(
                            'Top-Right',
                            Colors.blue,
                            isActive,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Button near bottom-right
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlexOverlay(
                          positionConfig: const PositionConfig.top(),
                          interactionConfig: InteractionConfig(
                            mode: interactionMode,
                          ),
                          content: _buildScopePopup(
                            'Repositioned to fit!',
                            Colors.blue,
                          ),
                          child: (isActive) => _buildScopeButton(
                            'Bottom-Right',
                            Colors.blue,
                            isActive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main content area (no scope)
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Main Content Area',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Popups from the sidebar won\'t extend into this area',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. Two-Column Layout',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Each column has its own scope - popups stay in their column',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Left column with scope
              Expanded(
                child: FlexOverlayScope(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border(
                        right: BorderSide(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Left Column (Scoped)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FlexOverlay(
                            positionConfig: const PositionConfig.right(),
                            interactionConfig: InteractionConfig(
                              mode: interactionMode,
                            ),
                            content: _buildScopePopup(
                              'Stays left!',
                              Colors.green,
                            ),
                            child: (isActive) => _buildScopeButton(
                              'Near Edge',
                              Colors.green,
                              isActive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right column with scope
              Expanded(
                child: FlexOverlayScope(
                  child: Container(
                    color: Colors.orange.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Right Column (Scoped)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FlexOverlay(
                            positionConfig: const PositionConfig.left(),
                            interactionConfig: InteractionConfig(
                              mode: interactionMode,
                            ),
                            content: _buildScopePopup(
                              'Stays right!',
                              Colors.orange,
                            ),
                            child: (isActive) => _buildScopeButton(
                              'Near Edge',
                              Colors.orange,
                              isActive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. Comparison: With vs Without Scope',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Click buttons near the right edge to see the difference',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // Without scope
            Expanded(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade200, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.shade50,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WITHOUT Scope',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Popup can extend beyond',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FlexOverlay(
                        positionConfig: const PositionConfig.right(),
                        interactionConfig: InteractionConfig(
                          mode: interactionMode,
                        ),
                        content: _buildScopePopup(
                          'I can go outside!',
                          Colors.red,
                        ),
                        child: (isActive) =>
                            _buildScopeButton('Click Me', Colors.red, isActive),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // With scope
            Expanded(
              child: FlexOverlayScope(
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade200, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.shade50,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WITH Scope',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Popup stays inside',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FlexOverlay(
                          positionConfig: const PositionConfig.right(),
                          interactionConfig: InteractionConfig(
                            mode: interactionMode,
                          ),
                          content: _buildScopePopup(
                            'I stay inside!',
                            Colors.green,
                          ),
                          child: (isActive) => _buildScopeButton(
                            'Click Me',
                            Colors.green,
                            isActive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScopeButton(String label, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.8) : color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScopePopup(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 160),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

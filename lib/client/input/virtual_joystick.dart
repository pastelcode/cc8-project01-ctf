import 'package:flutter/material.dart';
import '../../core/messages.dart';

/// A touch-based 8-directional virtual joystick.
///
/// Reports discrete [Dir] values via [onDirectionChanged] whenever the user
/// drags the thumb into a new quantized direction or lifts their finger.
class VirtualJoystick extends StatefulWidget {
  /// Called whenever the quantized direction changes, including when the user
  /// lifts their finger — at which point [Dir.x] and [Dir.y] are both 0.
  final void Function(Dir dir)? onDirectionChanged;

  const VirtualJoystick({super.key, this.onDirectionChanged});

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset? _dragOffset;
  static const double _deadZone = 15.0;
  static const double _maxRadius = 55.0;
  static const double _widgetSize = 140.0;
  Dir _lastDir = const Dir(x: 0, y: 0);

  Dir _offsetToDir(Offset offset) {
    final distance = offset.distance;
    if (distance < _deadZone) return const Dir(x: 0, y: 0);

    final nx = (offset.dx / _maxRadius).clamp(-1.0, 1.0);
    final ny = (offset.dy / _maxRadius).clamp(-1.0, 1.0);

    return Dir(x: _quantize(nx), y: _quantize(ny));
  }

  int _quantize(double v) {
    if (v < -0.3) return -1;
    if (v > 0.3) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updateDrag(details.localPosition),
      onPanUpdate: (details) => _updateDrag(details.localPosition),
      onPanEnd: (_) {
        setState(() => _dragOffset = null);
        final dir = const Dir(x: 0, y: 0);
        if (dir != _lastDir) {
          _lastDir = dir;
          widget.onDirectionChanged?.call(dir);
        }
      },
      child: Container(
        width: _widgetSize,
        height: _widgetSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragOffset ?? Offset.zero,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateDrag(Offset localPosition) {
    final center = Offset(_widgetSize / 2, _widgetSize / 2);
    final offset = localPosition - center;
    final clampedOffset = Offset.fromDirection(
      offset.direction,
      offset.distance.clamp(0, _maxRadius),
    );
    setState(() => _dragOffset = clampedOffset);
    final dir = _offsetToDir(offset);
    if (dir != _lastDir) {
      _lastDir = dir;
      widget.onDirectionChanged?.call(dir);
    }
  }
}

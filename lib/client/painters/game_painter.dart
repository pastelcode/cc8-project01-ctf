import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart' as c;
import '../../core/messages.dart';
import '../providers/game_state_provider.dart';

class GamePainter extends CustomPainter {
  final GameWorld state;
  final String? localPlayerId; // to highlight the local player
  final Map<String, String>? playerNames;

  GamePainter({required this.state, this.localPlayerId, this.playerNames});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale: fit 1000x1000 logical map into available space
    // maintaining aspect ratio (the map is square)
    final scale = min(size.width, size.height) / c.Constants.mapSize;
    final offsetX = (size.width - c.Constants.mapSize * scale) / 2;
    final offsetY = (size.height - c.Constants.mapSize * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    _drawMap(canvas);
    _drawCircle(canvas);
    _drawPlayers(canvas);
    _drawFlag(canvas);

    canvas.restore();
  }

  void _drawMap(Canvas canvas) {
    // Dark background for the map area
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        c.Constants.mapSize.toDouble(),
        c.Constants.mapSize.toDouble(),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );
  }

  void _drawCircle(Canvas canvas) {
    // Central circle boundary (stroked, not filled)
    canvas.drawCircle(
      const Offset(c.Constants.circleCenterX, c.Constants.circleCenterY),
      c.Constants.circleRadius.toDouble(),
      Paint()
        ..color = const Color(0x60FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawPlayers(Canvas canvas) {
    final players = state.gamePlayers;
    for (final player in players) {
      final isLocal = player.id == localPlayerId;
      _drawPlayerBody(canvas, player, isLocal);
      _drawPlayerName(canvas, player);
    }
  }

  void _drawPlayerBody(Canvas canvas, GamePlayer player, bool isLocal) {
    // Player circle
    canvas.drawCircle(
      Offset(player.x, player.y),
      c.Constants.playerRadius.toDouble(),
      Paint()
        ..color = isLocal ? const Color(0xFF00FF88) : const Color(0xFF4488FF),
    );
  }

  void _drawFlag(Canvas canvas) {
    final flag = state.flag;
    if (flag == null) return;

    final x = flag.x;
    final y = flag.y;

    // Flag pole
    canvas.drawLine(
      Offset(x, y - 18),
      Offset(x, y + 10),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5,
    );

    // Flag triangle
    final path = Path()
      ..moveTo(x + 1, y - 16)
      ..lineTo(x + 14, y - 6)
      ..lineTo(x + 1, y + 4)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF4444));
  }

  void _drawPlayerName(Canvas canvas, GamePlayer player) {
    final name = playerNames?[player.id];
    if (name == null) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = player.x - textPainter.width / 2;
    final y = player.y - c.Constants.playerRadius - textPainter.height - 4;

    // Draw a subtle background for readability
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 3,
          y - 1,
          textPainter.width + 6,
          textPainter.height + 2,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) =>
      state != oldDelegate.state ||
      localPlayerId != oldDelegate.localPlayerId ||
      playerNames != oldDelegate.playerNames;
}

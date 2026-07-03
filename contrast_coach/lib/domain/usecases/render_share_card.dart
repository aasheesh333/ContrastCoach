import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ShareCardContent {
  const ShareCardContent({
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.roundsDone,
    required this.roundsPlanned,
    required this.goalEmoji,
    required this.goalLabel,
    required this.streakDays,
  });

  final String title;
  final String subtitle;
  final int minutes;
  final int roundsDone;
  final int roundsPlanned;
  final String goalEmoji;
  final String goalLabel;
  final int streakDays;
}

/// Compose a display DTO from a real Session + extra context (score, streak).
ShareCardContent composeShareCardContent(
  Session session, {
  double? recoveryScore,
  int streakDays = 0,
}) {
  return ShareCardContent(
    title: recoveryScore == null
        ? 'Today\'s contrast session'
        : '${recoveryScore.toStringAsFixed(0)} / 100',
    subtitle: session.goal.name,
    minutes: session.totalActualDuration.inMinutes,
    roundsDone: session.roundsCompleted,
    roundsPlanned: session.protocolRounds,
    goalEmoji: switch (session.goal) {
      Goal.recovery => '🌙',
      Goal.energy => '⚡',
      Goal.sleep => '😴',
      Goal.immunity => '🛡️',
    },
    goalLabel: session.goal.name,
    streakDays: streakDays,
  );
}

/// Capture a RepaintBoundary given its GlobalKey to PNG bytes.
/// Throws on failure (caller handles).
Future<Uint8List> capturePng(GlobalKey boundaryKey) async {
  final boundary = boundaryKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

import 'dart:developer';

import 'package:database_diagrams/collections/smartline_controller.dart';
import 'package:database_diagrams/collections/smartline_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// SmartlinePainterContainer.
class SmartlinePainterContainer extends ConsumerWidget {
  /// Default constructor.
  const SmartlinePainterContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartlineController = ref.watch(SmartlineController.provider);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constarints) {
          log('constraints: $constarints');
          return Transform.translate(
            offset: const Offset(0, -40),
            child: CustomPaint(
              painter: SmartlinePainter(
                anchors: smartlineController.anchors,
              ),
            ),
          );
        },
      ),
    );
  }
}

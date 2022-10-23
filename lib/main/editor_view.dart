import 'dart:developer';

import 'package:database_diagrams/collections/collection_store.dart';
import 'package:database_diagrams/collections/draggable_collection_card.dart';
import 'package:database_diagrams/collections/smartline_painter_container.dart';
import 'package:database_diagrams/drawing/drawing_controller.dart';
import 'package:database_diagrams/drawing/drawing_painter_container.dart';
import 'package:database_diagrams/drawing/drawing_undo_redo_buttonds.dart';
import 'package:database_diagrams/drawing/polyline_painter_container.dart';
import 'package:database_diagrams/drawing/size_slider.dart';
import 'package:database_diagrams/main/editor_buttons.dart';
import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Editor view.
class EditorView extends HookConsumerWidget {
  /// Default constructor.
  const EditorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(CollectionStore.provider);
    final drawingController = ref.watch(DrawingController.provider);

    // TODO(Janez): Lift to controller.
    final offsets = useState<List<Offset>>([]);

    final focusStack = useState<List<Widget>>(
      [
        const DrawingPainterContainer(),
        const PolylinePainterContainer(),
        const SmartlinePainterContainer(),
      ],
    );

    final focusStackIndexes = useState<List<int>>(
      List.generate(focusStack.value.length, (index) => index),
    );

    ref
      ..listen(
        CollectionStore.provider,
        (previous, next) {
          if (previous != null && previous.length < next.length) {
            offsets.value = [...offsets.value, Offset.zero];
          }
          offsets.value = [...offsets.value, Offset.zero];
        },
      )
      ..listen(
        ModeController.provider,
        (previous, next) {
          log('previous: $previous, next: $next');
          switch (next) {
            case Mode.drawing:
              focusStackIndexes.value = [2, 1, 0];
              break;
            case Mode.polyline:
              focusStackIndexes.value = [0, 2, 1];
              break;
            case Mode.smartLine:
              focusStackIndexes.value = [1, 0, 2];
              break;
            case Mode.none:
              break;
          }
          log('focusStackIndexes.value: ${focusStackIndexes.value}');
        },
      );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: MouseRegion(
        cursor: drawingController.isDrawing
            ? SystemMouseCursors.precise
            : drawingController.isPolyline
                ? SystemMouseCursors.cell
                : SystemMouseCursors.basic,
        child: Stack(
          alignment: Alignment.center,
          children: [
            focusStack.value.elementAt(focusStackIndexes.value.elementAt(0)),
            focusStack.value.elementAt(focusStackIndexes.value.elementAt(1)),
            focusStack.value.elementAt(focusStackIndexes.value.elementAt(2)),
            ...collections.map(
              (collection) => Positioned(
                top: 50 + offsets.value[collections.indexOf(collection)].dy,
                left: 50 + offsets.value[collections.indexOf(collection)].dx,
                child: DraggableCollectionCard(
                  collection: collection,
                  onDragUpdate: (details) {
                    offsets.value = [
                      ...offsets.value.sublist(0, collections.indexOf(collection)),
                      Offset(
                        offsets.value[collections.indexOf(collection)].dx + details.delta.dx,
                        offsets.value[collections.indexOf(collection)].dy + details.delta.dy,
                      ),
                      ...offsets.value.sublist(collections.indexOf(collection) + 1),
                    ];
                  },
                ),
              ),
            ),
            const Positioned(
              right: 16,
              bottom: 32,
              child: EditorButtons(),
            ),
            const Positioned(
              left: 16,
              bottom: 16,
              child: DrawingUndoRedoButtons(),
            ),
            const Positioned(
              bottom: 16,
              child: SizeSlider(),
            ),
          ],
        ),
      ),
    );
  }
}

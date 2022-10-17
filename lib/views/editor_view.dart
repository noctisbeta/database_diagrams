import 'package:database_diagrams/controllers/collection_store.dart';
import 'package:database_diagrams/controllers/drawing_controller.dart';
import 'package:database_diagrams/widgets/draggable_collection_card.dart';
import 'package:database_diagrams/widgets/drawing_painter.dart';
import 'package:database_diagrams/widgets/drawing_undo_redo_buttonds.dart';
import 'package:database_diagrams/widgets/editor_buttons.dart';
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

    // final drawingController = ref.watch(DrawingController.provider.notifier);
    // final drawingState = ref.watch(DrawingController.provider);

    final drawingControllerMut = ref.watch(DrawingController.provider);

    final offsets = useState<List<Offset>>([]);

    ref.listen(
      CollectionStore.provider,
      (previous, next) {
        if (previous != null && previous.length < next.length) {
          offsets.value = [...offsets.value, Offset.zero];
        }
        offsets.value = [...offsets.value, Offset.zero];
      },
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: MouseRegion(
        cursor: drawingControllerMut.isDrawing ? SystemMouseCursors.precise : SystemMouseCursors.basic,
        child: Stack(
          children: [
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
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: !drawingControllerMut.isDrawing,
                child: GestureDetector(
                  onPanStart: (details) {
                    drawingControllerMut.addPoint(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    drawingControllerMut.addPoint(details.localPosition);
                  },
                  onPanEnd: (details) {
                    drawingControllerMut.addPoint(null);
                  },
                  // TODO(Janez): Optimize. Dynamic number of painters scaled with the size of points array.
                  child: RepaintBoundary(
                    child: CustomPaint(
                      isComplex: true,
                      willChange: true,
                      painter: DrawingPainter(
                        points: drawingControllerMut.points,
                      ),
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }
}

import 'package:database_diagrams/models/collection.dart';
import 'package:database_diagrams/widgets/collection_card.dart';
import 'package:flutter/material.dart';

/// DraggableCollectionCard.
class DraggableCollectionCard extends StatelessWidget {
  /// Default constructor.
  const DraggableCollectionCard({
    required this.collection,
    required this.onDragUpdate,
    super.key,
  });

  /// On drag update.
  final void Function(DragUpdateDetails) onDragUpdate;

  /// Collection.
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Draggable<Collection>(
      onDragUpdate: onDragUpdate,
      data: collection,
      childWhenDragging: const SizedBox.shrink(),
      feedback: Material(
        type: MaterialType.transparency,
        child: CollectionCard(
          collection: collection,
        ),
      ),
      child: CollectionCard(
        collection: collection,
      ),
    );
  }
}

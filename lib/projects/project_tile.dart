import 'package:database_diagrams/projects/project.dart';
import 'package:flutter/material.dart';

/// Project tile.
class ProjectTile extends StatelessWidget {
  /// Default constructor.
  const ProjectTile({
    required this.project,
    super.key,
  });

  /// Project.
  final Project project;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

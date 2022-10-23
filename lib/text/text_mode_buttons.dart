import 'package:database_diagrams/main/mode.dart';
import 'package:database_diagrams/main/mode_controller.dart';
import 'package:database_diagrams/text/my_text_controller.dart';
import 'package:database_diagrams/text/text_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Text mode buttons.
class TextModeButtons extends HookConsumerWidget {
  /// Default constructor.
  const TextModeButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final textController = ref.watch(MyTextController.provider);
    final textMode = textController.mode;

    ref.listen(
      ModeController.provider,
      (previous, next) {
        if (next == Mode.text) {
          ctl.forward();
        } else if (!next.isUndoable) {
          ctl.reverse();
        }
      },
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: ctl, curve: Curves.easeOutBack),
      ),
      child: Row(
        children: [
          FloatingActionButton(
            backgroundColor: textMode == TextMode.edit ? Colors.orange.shade900 : Colors.orange.shade700,
            hoverColor: textMode == TextMode.edit ? Colors.orange.shade600 : Colors.orange.shade800,
            splashColor: textMode == TextMode.edit ? Colors.orange.shade700 : Colors.orange.shade900,
            onPressed: () {
              textController.setMode(TextMode.edit);
            },
            child: const Icon(
              Icons.text_format,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          FloatingActionButton(
            backgroundColor: textMode == TextMode.move ? Colors.orange.shade900 : Colors.orange.shade700,
            hoverColor: textMode == TextMode.move ? Colors.orange.shade600 : Colors.orange.shade800,
            splashColor: textMode == TextMode.move ? Colors.orange.shade700 : Colors.orange.shade900,
            onPressed: () {
              textController.setMode(TextMode.move);
            },
            child: const Icon(
              Icons.move_down,
            ),
          ),
        ],
      ),
    );
  }
}

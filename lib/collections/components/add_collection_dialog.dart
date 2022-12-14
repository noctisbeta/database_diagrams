import 'dart:developer';

import 'package:database_diagrams/collections/components/collection_card.dart';
import 'package:database_diagrams/collections/controllers/collection_store.dart';
import 'package:database_diagrams/collections/models/collection.dart';
import 'package:database_diagrams/main/my_button.dart';
import 'package:database_diagrams/main/my_dropdown_button.dart';
import 'package:database_diagrams/main/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Add collection dialog.
class AddCollectionDialog extends HookConsumerWidget {
  /// Default constructor.
  const AddCollectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collName = useState<String?>(null);
    final fieldName = useState<String?>(null);
    final fieldType = useState<String?>(null);
    final collection = useState<Collection?>(null);
    final fieldCtl = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AlertDialog(
        title: const Text('Add Collection'),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FocusScope(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextField(
                        label: 'Collection name',
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          collName.value = value;
                        },
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      MyTextField(
                        controller: fieldCtl,
                        label: 'Field name',
                        textInputAction: TextInputAction.next,
                        enabled: collName.value != null && collName.value!.isNotEmpty,
                        onChanged: (value) {
                          fieldName.value = value;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      MyDropdownButton(
                        value: fieldType.value,
                        enabled: collName.value != null && collName.value!.isNotEmpty,
                        onChanged: (value) {
                          fieldType.value = value;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: MyButton(
                          label: 'Add field',
                          onPressed: () {
                            log(
                              {
                                if (collection.value != null) ...collection.value!.schema,
                                fieldName.value!: fieldType.value!,
                              }.toString(),
                            );
                            if (collName.value != null &&
                                collName.value!.isNotEmpty &&
                                fieldName.value != null &&
                                fieldName.value!.isNotEmpty &&
                                fieldType.value != null &&
                                fieldType.value!.isNotEmpty) {
                              collection.value = collection.value?.copyWith(
                                    name: collName.value,
                                    schema: {
                                      if (collection.value != null) ...collection.value!.schema,
                                      fieldName.value!: fieldType.value!,
                                    },
                                  ) ??
                                  Collection(
                                    name: collName.value!,
                                    schema: {
                                      fieldName.value!: fieldType.value!,
                                    },
                                  );
                              fieldName.value = null;
                              fieldType.value = null;
                              fieldCtl.clear();
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                width: 1,
                color: Colors.black.withOpacity(0.3),
              ),
              Expanded(
                child: collection.value != null
                    ? HookBuilder(
                        builder: (context) {
                          return CollectionCard(
                            collection: collection.value!,
                            isPreview: true,
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No collection added',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          MyButton(
            label: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MyButton(
            label: 'Add',
            onPressed: () {
              if (collection.value != null) {
                ref.read(CollectionStore.provider.notifier).add(
                      collection.value!,
                    );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

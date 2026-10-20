import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import 'category_icon.dart';

class ManageCategoriesPage extends ConsumerWidget {
  const ManageCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryControllerProvider).categories;
    final palette = context.lumaPalette;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editCategory(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: categories.length,
        onReorder: (oldIndex, newIndex) => ref
            .read(categoryControllerProvider)
            .reorder(oldIndex, newIndex),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            key: ValueKey(category.id),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: palette.elevated,
                child: CategoryIcon(category: category, size: 21),
              ),
              title: Text(category.name),
              subtitle: Text(category.isDefault ? 'Default category' : 'Custom category'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit ${category.name}',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editCategory(context, ref, category),
                  ),
                  if (!category.isDefault)
                    IconButton(
                      tooltip: 'Delete ${category.name}',
                      icon: Icon(Icons.delete_outline, color: palette.error),
                      onPressed: () => _deleteCategory(context, ref, category),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.drag_handle_rounded),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref, [
    CategoryModel? category,
  ]) async {
    final result = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _CategoryEditorSheet(category: category),
    );
    if (result != null) {
      await ref.read(categoryControllerProvider).save(result);
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${category.name}?'),
        content: const Text('Existing expenses will keep their category ID.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(categoryControllerProvider).delete(category);
    }
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.category});

  final CategoryModel? category;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController nameController;
  late final TextEditingController iconSearchController;
  late String iconKey;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category?.name ?? '');
    iconSearchController = TextEditingController();
    iconKey = widget.category?.iconKey ?? categoryIconOptions.first.key;
    iconSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    iconSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category == null ? 'Add Category' : 'Edit Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Category name'),
            ),
            const SizedBox(height: 18),
            Text('Icon', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            TextField(
              controller: iconSearchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search icons, e.g. gym or coffee',
                suffixIcon: Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final options = categoryIconOptions
                    .where((option) => option.matches(iconSearchController.text))
                    .toList();
                if (options.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No matching icons')),
                  );
                }
                return GridView.builder(
                  itemCount: options.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = option.key == iconKey;
                final preview = CategoryModel(
                  id: option.key,
                  name: option.label,
                  iconKey: option.key,
                  colorValue: 0xFFB8A7A0,
                  sortOrder: 0,
                  isDefault: true,
                );
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => iconKey = option.key),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? palette.primaryAccent.withValues(alpha: .16)
                          : palette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? palette.primaryAccent : palette.border,
                      ),
                    ),
                    child: Center(child: CategoryIcon(category: preview)),
                  ),
                );
                  },
                );
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final category = widget.category;
                  Navigator.pop(
                    context,
                    CategoryModel(
                      id: category?.id ?? 'custom_${DateTime.now().microsecondsSinceEpoch}',
                      name: name,
                      iconKey: iconKey,
                      colorValue: 0xFFB8A7A0,
                      sortOrder: category?.sortOrder ?? 999,
                      isDefault: category?.isDefault ?? false,
                    ),
                  );
                },
                child: Text(categoryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get categoryLabel => widget.category == null ? 'Add Category' : 'Save changes';
}

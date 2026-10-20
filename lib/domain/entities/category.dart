class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.sortOrder,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final int sortOrder;
  final bool isDefault;

  CategoryModel copyWith({
    String? name,
    String? iconKey,
    int? colorValue,
    int? sortOrder,
  }) => CategoryModel(
    id: id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    isDefault: isDefault,
  );
}

const defaultCategories = [
  CategoryModel(id: 'food', name: 'Food', iconKey: 'food', colorValue: 0xFFE68A6B, sortOrder: 0, isDefault: true),
  CategoryModel(id: 'travel', name: 'Travel', iconKey: 'travel', colorValue: 0xFF7EB6D8, sortOrder: 1, isDefault: true),
  CategoryModel(id: 'shopping', name: 'Shopping', iconKey: 'shopping', colorValue: 0xFFC49AD7, sortOrder: 2, isDefault: true),
  CategoryModel(id: 'bills', name: 'Bills', iconKey: 'bills', colorValue: 0xFFE5B96F, sortOrder: 3, isDefault: true),
  CategoryModel(id: 'subscriptions', name: 'Subscriptions', iconKey: 'subscriptions', colorValue: 0xFF92C7A5, sortOrder: 4, isDefault: true),
  CategoryModel(id: 'entertainment', name: 'Entertainment', iconKey: 'entertainment', colorValue: 0xFFE08BB4, sortOrder: 5, isDefault: true),
  CategoryModel(id: 'health', name: 'Health', iconKey: 'health', colorValue: 0xFFE78383, sortOrder: 6, isDefault: true),
  CategoryModel(id: 'education', name: 'Education', iconKey: 'education', colorValue: 0xFF9AB7E8, sortOrder: 7, isDefault: true),
  CategoryModel(id: 'personal', name: 'Personal', iconKey: 'personal', colorValue: 0xFFB5A0D9, sortOrder: 8, isDefault: true),
  CategoryModel(id: 'other', name: 'Other', iconKey: 'other', colorValue: 0xFFB8A7A0, sortOrder: 9, isDefault: true),
];

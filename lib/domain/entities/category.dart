class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.name, required this.icon, required this.sortOrder});

  final String id;
  final String name;
  final String icon;
  final int sortOrder;
}

const defaultCategories = [
  ExpenseCategory(id: 'food', name: 'Food', icon: 'restaurant', sortOrder: 0),
  ExpenseCategory(id: 'travel', name: 'Travel', icon: 'directions_car', sortOrder: 1),
  ExpenseCategory(id: 'shopping', name: 'Shopping', icon: 'shopping_bag', sortOrder: 2),
  ExpenseCategory(id: 'bills', name: 'Bills', icon: 'receipt', sortOrder: 3),
  ExpenseCategory(id: 'subscriptions', name: 'Subscriptions', icon: 'autorenew', sortOrder: 4),
  ExpenseCategory(id: 'entertainment', name: 'Entertainment', icon: 'movie', sortOrder: 5),
  ExpenseCategory(id: 'health', name: 'Health', icon: 'favorite', sortOrder: 6),
  ExpenseCategory(id: 'education', name: 'Education', icon: 'school', sortOrder: 7),
  ExpenseCategory(id: 'personal', name: 'Personal', icon: 'person', sortOrder: 8),
  ExpenseCategory(id: 'other', name: 'Other', icon: 'wallet', sortOrder: 9),
];

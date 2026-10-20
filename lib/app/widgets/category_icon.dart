import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/category.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.label,
    required this.icon,
    this.aliases = const [],
  });

  final String key;
  final String label;
  final IconData icon;
  final List<String> aliases;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return <String>[label, key, ...aliases].any(
      (value) => value.toLowerCase().contains(normalized),
    );
  }
}

const categoryIconOptions = <CategoryIconOption>[
  CategoryIconOption(key: 'food', label: 'Food', icon: Icons.restaurant_rounded, aliases: ['meal', 'restaurant']),
  CategoryIconOption(key: 'travel', label: 'Travel', icon: Icons.directions_car_rounded, aliases: ['car', 'transport']),
  CategoryIconOption(key: 'shopping', label: 'Shopping', icon: Icons.shopping_bag_outlined, aliases: ['store', 'clothes']),
  CategoryIconOption(key: 'subscriptions', label: 'Subscriptions', icon: Icons.autorenew_rounded, aliases: ['recurring', 'membership']),
  CategoryIconOption(key: 'bills', label: 'Bills', icon: Icons.receipt_long_rounded, aliases: ['invoice', 'utilities']),
  CategoryIconOption(key: 'entertainment', label: 'Entertainment', icon: Icons.movie_outlined, aliases: ['movie', 'fun']),
  CategoryIconOption(key: 'health', label: 'Health', icon: Icons.favorite_outline, aliases: ['doctor', 'medical']),
  CategoryIconOption(key: 'education', label: 'Education', icon: Icons.school_outlined, aliases: ['school', 'course']),
  CategoryIconOption(key: 'personal', label: 'Personal', icon: Icons.person_outline, aliases: ['self']),
  CategoryIconOption(key: 'other', label: 'Other', icon: Icons.wallet_outlined, aliases: ['miscellaneous']),
  CategoryIconOption(key: 'groceries', label: 'Groceries', icon: Icons.local_grocery_store_outlined, aliases: ['supermarket', 'market']),
  CategoryIconOption(key: 'home', label: 'Home', icon: Icons.home_outlined, aliases: ['rent', 'house']),
  CategoryIconOption(key: 'pets', label: 'Pets', icon: Icons.pets_outlined, aliases: ['dog', 'cat', 'vet']),
  CategoryIconOption(key: 'gifts', label: 'Gifts', icon: Icons.card_giftcard_outlined, aliases: ['present', 'birthday']),
  CategoryIconOption(key: 'work', label: 'Work', icon: Icons.work_outline, aliases: ['office', 'business']),
  CategoryIconOption(key: 'dumbbell', label: 'Dumbbell', icon: Icons.fitness_center_rounded, aliases: ['gym', 'workout', 'fitness', 'exercise']),
  CategoryIconOption(key: 'coffee', label: 'Coffee', icon: Icons.local_cafe_outlined, aliases: ['cafe', 'tea']),
  CategoryIconOption(key: 'mobile', label: 'Mobile', icon: Icons.phone_android_outlined, aliases: ['phone', 'recharge']),
  CategoryIconOption(key: 'charity', label: 'Charity', icon: Icons.volunteer_activism_outlined, aliases: ['donation', 'donate']),
  CategoryIconOption(key: 'tools', label: 'Tools', icon: Icons.build_outlined, aliases: ['repair', 'maintenance']),
  CategoryIconOption(key: 'music', label: 'Music', icon: Icons.music_note_outlined, aliases: ['concert', 'songs']),
  CategoryIconOption(key: 'games', label: 'Games', icon: Icons.sports_esports_outlined, aliases: ['gaming', 'play']),
  CategoryIconOption(key: 'flight', label: 'Flight', icon: Icons.flight_takeoff_outlined, aliases: ['airplane', 'airport']),
  CategoryIconOption(key: 'bike', label: 'Bike', icon: Icons.directions_bike_outlined, aliases: ['cycling']),
  CategoryIconOption(key: 'train', label: 'Train', icon: Icons.train_outlined, aliases: ['metro', 'rail']),
  CategoryIconOption(key: 'bus', label: 'Bus', icon: Icons.directions_bus_outlined, aliases: ['public transport']),
  CategoryIconOption(key: 'fuel', label: 'Fuel', icon: Icons.local_gas_station_outlined, aliases: ['petrol', 'gas']),
  CategoryIconOption(key: 'parking', label: 'Parking', icon: Icons.local_parking_outlined, aliases: ['car park']),
  CategoryIconOption(key: 'internet', label: 'Internet', icon: Icons.wifi_outlined, aliases: ['broadband', 'data']),
  CategoryIconOption(key: 'water', label: 'Water', icon: Icons.water_drop_outlined, aliases: ['drinking']),
  CategoryIconOption(key: 'electricity', label: 'Electricity', icon: Icons.bolt_outlined, aliases: ['power', 'light']),
  CategoryIconOption(key: 'clothing', label: 'Clothing', icon: Icons.checkroom_outlined, aliases: ['fashion', 'shoes']),
  CategoryIconOption(key: 'beauty', label: 'Beauty', icon: Icons.face_retouching_natural_outlined, aliases: ['salon', 'grooming']),
  CategoryIconOption(key: 'medicine', label: 'Medicine', icon: Icons.medication_outlined, aliases: ['pharmacy', 'pills']),
  CategoryIconOption(key: 'hospital', label: 'Hospital', icon: Icons.local_hospital_outlined, aliases: ['clinic']),
  CategoryIconOption(key: 'baby', label: 'Baby', icon: Icons.child_friendly_outlined, aliases: ['kids', 'child']),
  CategoryIconOption(key: 'family', label: 'Family', icon: Icons.family_restroom_outlined, aliases: ['parents']),
  CategoryIconOption(key: 'camera', label: 'Camera', icon: Icons.camera_alt_outlined, aliases: ['photography']),
  CategoryIconOption(key: 'book', label: 'Books', icon: Icons.menu_book_outlined, aliases: ['reading']),
  CategoryIconOption(key: 'cloud', label: 'Cloud', icon: Icons.cloud_outlined, aliases: ['storage']),
  CategoryIconOption(key: 'security', label: 'Security', icon: Icons.security_outlined, aliases: ['insurance', 'protect']),
  CategoryIconOption(key: 'savings', label: 'Savings', icon: Icons.savings_outlined, aliases: ['save', 'money']),
  CategoryIconOption(key: 'bank', label: 'Bank', icon: Icons.account_balance_outlined, aliases: ['finance']),
  CategoryIconOption(key: 'credit-card', label: 'Card', icon: Icons.credit_card_outlined, aliases: ['payment', 'debit']),
  CategoryIconOption(key: 'cash', label: 'Cash', icon: Icons.payments_outlined, aliases: ['wallet', 'atm']),
  CategoryIconOption(key: 'calendar', label: 'Calendar', icon: Icons.calendar_month_outlined, aliases: ['event']),
  CategoryIconOption(key: 'celebration', label: 'Celebration', icon: Icons.celebration_outlined, aliases: ['party', 'wedding']),
  CategoryIconOption(key: 'donut', label: 'Dessert', icon: Icons.donut_large_outlined, aliases: ['cake', 'sweet']),
  CategoryIconOption(key: 'restaurant', label: 'Restaurant', icon: Icons.restaurant_menu_outlined, aliases: ['dining', 'dinner']),
  CategoryIconOption(key: 'local-drink', label: 'Drinks', icon: Icons.local_drink_outlined, aliases: ['bar', 'beverage']),
  CategoryIconOption(key: 'laptop', label: 'Laptop', icon: Icons.laptop_mac_outlined, aliases: ['computer', 'software']),
];

IconData categoryIconData(String? key) {
  for (final option in categoryIconOptions) {
    if (option.key == key) return option.icon;
  }
  return Icons.wallet_outlined;
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 22});

  final CategoryModel category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    if (categoryIconOptions.any((option) => option.key == category.iconKey)) {
      return Icon(
        categoryIconData(category.iconKey),
        size: size,
        color: iconColor,
      );
    }
    return SvgPicture.asset(
      'assets/icons/${category.iconKey}.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        iconColor,
        BlendMode.srcIn,
      ),
      placeholderBuilder: (_) => Icon(
        categoryIconData(category.iconKey),
        size: size,
        color: iconColor,
      ),
    );
  }
}

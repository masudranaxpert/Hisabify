import 'package:flutter/material.dart';

// Category model
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'expense' or 'income'

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

// All categories
const List<Category> expenseCategories = [
  Category(id: 'food', name: 'Food & Drinks', icon: Icons.restaurant_rounded, color: Color(0xFFEF4444), type: 'expense'),
  Category(id: 'transport', name: 'Transport', icon: Icons.directions_car_rounded, color: Color(0xFFF59E0B), type: 'expense'),
  Category(id: 'entertainment', name: 'Entertainment', icon: Icons.movie_rounded, color: Color(0xFFEC4899), type: 'expense'),
  Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFF8B5CF6), type: 'expense'),
  Category(id: 'bills', name: 'Bills & Utilities', icon: Icons.receipt_long_rounded, color: Color(0xFF06B6D4), type: 'expense'),
  Category(id: 'health', name: 'Health', icon: Icons.local_hospital_rounded, color: Color(0xFF22C55E), type: 'expense'),
  Category(id: 'education', name: 'Education', icon: Icons.school_rounded, color: Color(0xFF3B82F6), type: 'expense'),
  Category(id: 'other_expense', name: 'Other', icon: Icons.more_horiz_rounded, color: Color(0xFF6B7280), type: 'expense'),
];

const List<Category> incomeCategories = [
  Category(id: 'salary', name: 'Salary', icon: Icons.work_rounded, color: Color(0xFF22C55E), type: 'income'),
  Category(id: 'freelance', name: 'Freelance', icon: Icons.laptop_mac_rounded, color: Color(0xFFF97316), type: 'income'),
  Category(id: 'investment', name: 'Investment', icon: Icons.trending_up_rounded, color: Color(0xFFF59E0B), type: 'income'),
  Category(id: 'gift', name: 'Gift', icon: Icons.card_giftcard_rounded, color: Color(0xFFEC4899), type: 'income'),
  Category(id: 'other_income', name: 'Other', icon: Icons.more_horiz_rounded, color: Color(0xFF6B7280), type: 'income'),
];

Category getCategoryById(String id, String type) {
  final list = type == 'expense' ? expenseCategories : incomeCategories;
  return list.firstWhere(
    (c) => c.id == id,
    orElse: () => list.last,
  );
}

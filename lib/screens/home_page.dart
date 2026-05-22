import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/menu_service.dart';
import '../widgets/menu_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning,';
    if (hour >= 12 && hour < 17) return 'Good afternoon,';
    if (hour >= 17 && hour < 21) return 'Good evening,';
    return 'Good night,';
  }

  List<Map<String, dynamic>> get _filteredItems {
    final items = MenuService().menuItems.value;
    final cats = MenuService().categories;
    if (_selectedCategoryIndex == 0) return items;
    final cat = cats[_selectedCategoryIndex];
    return items.where((item) => item['category'] == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: MenuService().menuItems,
          builder: (context, menuItems, child) {
            return SafeArea(
              child: Container(
                color: ThemeColors.scaffold,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildBanner(),
                      const SizedBox(height: 24),
                      _buildCategories(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Popular Menu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                      ),
                      const SizedBox(height: 16),
                      _buildPopularItems(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_greeting, style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary)),
            const SizedBox(height: 4),
            ValueListenableBuilder<UserProfile?>(
              valueListenable: AuthService().currentUser,
              builder: (context, user, child) {
                return Text(user?.fullName ?? 'Guest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text));
              },
            ),
          ]),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeColors.surface, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.notifications_outlined, color: const Color(0xFFC2713A)),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFC2713A), borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFC2713A).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Text('Special Offer', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            const Text('Get 20% Off\nOn Cheesecakes',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
          ])),
          Image.asset('assets/images/cheesecake.png', width: 100, height: 100, fit: BoxFit.contain),
        ]),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = MenuService().categories;
    return SizedBox(
      height: 36,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC2713A) : ThemeColors.chipBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? const Color(0xFFC2713A) : ThemeColors.border),
              ),
              alignment: Alignment.center,
              child: Text(categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : ThemeColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularItems() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(child: Text('No items in this category',
          style: TextStyle(color: ThemeColors.textSecondary, fontSize: 14))),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeColors.surface, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(
              width: 90, height: 90, padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(16)),
              child: MenuImage(imagePath: item['image'], fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.text)),
              const SizedBox(height: 6),
              Text(item['ingredients'], style: TextStyle(fontSize: 12, color: ThemeColors.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${item['price']} THB',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFFC2713A))),
                GestureDetector(
                  onTap: () {
                    CartService().addToCart(item, 1);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${item['name']} added to cart!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFFC2713A),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFC2713A), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ])),
          ]),
        );
      },
    );
  }
}

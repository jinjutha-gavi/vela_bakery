import 'package:flutter/material.dart';
import 'home_page.dart';
import 'random_pick_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'orders_page.dart';
import '../services/theme_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Home is center (index 2)

  final List<Widget> _pages = [
    const RandomPickPage(),
    const OrdersPage(),
    const HomePage(),
    const CartPage(),
    const ProfilePage(),
  ];

  void switchToTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeColors.scaffold,
          body: _pages[_currentIndex],
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: ThemeColors.navBar,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Nav bar items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.shuffle_rounded, 'Random', 0),
              _buildNavItem(Icons.local_shipping_outlined, 'Orders', 1),
              const SizedBox(width: 56), // Space for center button
              _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 3),
              _buildNavItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
          // Center floating home button
          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ThemeColors.navBarCenter,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.navBar.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: ThemeColors.accent,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

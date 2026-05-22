import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'my_orders_page.dart';
import 'shipping_addresses_page.dart';
import 'payment_methods_page.dart';
import 'settings_page.dart';
import 'manage_menu_page.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/theme_service.dart';
import 'help_center_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return SafeArea(
          child: Container(
            color: ThemeColors.scaffold,
            child: ValueListenableBuilder<UserProfile?>(
              valueListenable: AuthService().currentUser,
              builder: (context, user, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.text,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildProfileHeader(user),
                      const SizedBox(height: 32),
                      _buildStatsCard(),
                      const SizedBox(height: 32),
                      _buildMenu(context),
                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile? user) {
    final initials = user?.initials ?? 'U';
    final name = user?.fullName ?? 'Guest';
    final email = user?.email ?? 'No email provided';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.avatarBg,
            border: Border.all(color: ThemeColors.surface, width: 4),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.shadow,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFC2713A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ThemeColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: ThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return ValueListenableBuilder<List<Order>>(
      valueListenable: OrderService().orders,
      builder: (context, orders, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: ThemeColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Orders', '${orders.length}'),
                Container(width: 1, height: 40, color: ThemeColors.border),
                _buildStatItem('Coupons', '0'),
                Container(width: 1, height: 40, color: ThemeColors.border),
                _buildStatItem('Points', '${orders.length * 10}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFC2713A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: ThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuItem(context, Icons.shopping_bag_outlined, 'My Orders', true, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
            }),
            _buildMenuItem(context, Icons.location_on_outlined, 'Shipping Addresses', true, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingAddressesPage()));
            }),
            _buildMenuItem(context, Icons.payment_outlined, 'Payment Methods', true, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()));
            }),
            _buildMenuItem(context, Icons.settings_outlined, 'Settings', true, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            }),
            _buildMenuItem(context, Icons.help_outline, 'Help Center',
              AuthService().currentUser.value?.isAdmin == true, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
            }),
            if (AuthService().currentUser.value?.isAdmin == true)
              _buildMenuItem(context, Icons.restaurant_menu_outlined, 'Manage Menu', false, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageMenuPage()));
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, bool hasBorder, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFC2713A), size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.text,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: ThemeColors.textSecondary),
          onTap: onTap,
        ),
        if (hasBorder)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: ThemeColors.border),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () async {
            await CartService().clearForLogout();
            await OrderService().clearForLogout();
            await AuthService().logout();
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF3B30),
            side: const BorderSide(color: Color(0xFFFF3B30)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

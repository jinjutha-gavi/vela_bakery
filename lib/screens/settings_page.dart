import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser.value;
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeColors.scaffold,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildSection(context, 'Account', [
                        _buildInfoTile(context, Icons.person_outline, 'Name', user?.fullName ?? '-'),
                        _buildInfoTile(context, Icons.alternate_email, 'Username', user?.username ?? '-'),
                        _buildInfoTile(context, Icons.email_outlined, 'Email', user?.email ?? '-'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(context, 'Notifications', [
                        _buildSwitchTile(context, Icons.notifications_outlined, 'Push Notifications', _notifications, (v) => setState(() => _notifications = v)),
                        _buildSwitchTile(context, Icons.local_offer_outlined, 'Promotions', _promotions, (v) => setState(() => _promotions = v)),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(context, 'Appearance', [
                        _buildSwitchTile(context, 
                          Icons.dark_mode_outlined,
                          'Dark Mode',
                          isDark,
                          (v) => ThemeService().toggle(),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(context, 'About', [
                        _buildInfoTile(context, Icons.info_outline, 'Version', '1.0.0'),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeColors.appBar,
        boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFC2713A), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ThemeColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: ThemeColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFFC2713A), size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary)),
      trailing: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ThemeColors.text)),
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFFC2713A), size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeColors.text)),
      trailing: Switch(value: value, onChanged: onChanged, activeTrackColor: const Color(0xFFC2713A)),
    );
  }
}

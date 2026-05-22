import 'package:flutter/material.dart';
import '../services/theme_service.dart';


class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeColors.scaffold,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildContent()),
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
              child: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFFC2713A), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text('Help Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final faqs = [
      {'q': 'How do I place an order?', 'a': 'Browse our menu, add items to your cart, and proceed to checkout. Select your delivery address and payment method to complete your order.'},
      {'q': 'What are the delivery hours?', 'a': 'We deliver from 8:00 AM to 8:00 PM, seven days a week. Orders placed after hours will be delivered the next morning.'},
      {'q': 'Can I cancel my order?', 'a': 'You can cancel your order within 5 minutes of placing it. After that, the order enters preparation and cannot be cancelled.'},
      {'q': 'How do I contact support?', 'a': 'You can reach us at support@velabakery.com or call us at 02-123-4567 during business hours.'},
      {'q': 'Is there a minimum order?', 'a': 'There is no minimum order amount. However, orders above 300 THB qualify for free delivery.'},
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Contact card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFC2713A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              const Text('Need Help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Our team is ready to assist you.', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildContactBtn(Icons.email_outlined, 'Email'),
                  const SizedBox(width: 12),
                  _buildContactBtn(Icons.phone_outlined, 'Call'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        const SizedBox(height: 16),
        ...faqs.map((faq) => _buildFaqItem(faq['q']!, faq['a']!)),
      ],
    );
  }

  Widget _buildContactBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: ThemeColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          iconColor: const Color(0xFFC2713A),
          collapsedIconColor: ThemeColors.textSecondary,
          title: Text(question, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeColors.text)),
          children: [Text(answer, style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary, height: 1.5))],
        ),
      ),
    );
  }
}

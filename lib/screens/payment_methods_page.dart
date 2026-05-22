import 'package:flutter/material.dart';
import '../services/theme_service.dart';


class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  int _selectedMethod = 0;

  final List<Map<String, dynamic>> _methods = [
    {'icon': Icons.money, 'title': 'Cash on Delivery', 'subtitle': 'Pay when you receive'},
    {'icon': Icons.account_balance, 'title': 'Bank Transfer', 'subtitle': 'Transfer via mobile banking'},
    {'icon': Icons.qr_code_2, 'title': 'PromptPay', 'subtitle': 'Scan QR to pay'},
  ];

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
        boxShadow: [
          BoxShadow(color: ThemeColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
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
          Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ThemeColors.textSecondary)),
        const SizedBox(height: 16),
        ...List.generate(_methods.length, (i) => _buildMethodCard(i)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeColors.accentSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC2713A).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFFC2713A).withValues(alpha: 0.7), size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Your payment method will be applied at checkout.', style: TextStyle(fontSize: 13, color: ThemeColors.textSecondary))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(int index) {
    final method = _methods[index];
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFC2713A) : ThemeColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? ThemeColors.accentSubtle : ThemeColors.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method['icon'], color: isSelected ? const Color(0xFFC2713A) : ThemeColors.textSecondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? ThemeColors.text : ThemeColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(method['subtitle'], style: TextStyle(fontSize: 13, color: ThemeColors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? const Color(0xFFC2713A) : ThemeColors.border, width: 2)),
              child: isSelected ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFC2713A)))) : null,
            ),
          ],
        ),
      ),
    );
  }
}

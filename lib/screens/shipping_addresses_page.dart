import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/theme_service.dart';

class ShippingAddressesPage extends StatefulWidget {
  const ShippingAddressesPage({super.key});
  @override
  State<ShippingAddressesPage> createState() => _ShippingAddressesPageState();
}

class _ShippingAddressesPageState extends State<ShippingAddressesPage> {
  final CartService _cartService = CartService();

  void _showEditAddressSheet() {
    final addr = _cartService.deliveryAddress.value;
    final nameCtrl = TextEditingController(text: addr['name'] ?? '');
    final addr1Ctrl = TextEditingController(text: addr['address1'] ?? '');
    final addr2Ctrl = TextEditingController(text: addr['address2'] ?? '');
    final phoneCtrl = TextEditingController(text: addr['phone'] ?? '');

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: ThemeColors.bottomSheet,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: ThemeColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              // Header
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2713A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.location_on, color: Color(0xFFC2713A), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_cartService.hasAddress ? 'Edit Address' : 'Add New Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                  const SizedBox(height: 2),
                  Text('Your shipping details', style: TextStyle(
                    fontSize: 12, color: ThemeColors.textSecondary)),
                ])),
              ]),
              const SizedBox(height: 24),
              _buildField(nameCtrl, 'Full Name *', Icons.person_outline),
              const SizedBox(height: 14),
              _buildField(addr1Ctrl, 'Address Line 1 *', Icons.home_outlined),
              const SizedBox(height: 14),
              _buildField(addr2Ctrl, 'Address Line 2 (Optional)', Icons.apartment_outlined),
              const SizedBox(height: 14),
              _buildField(phoneCtrl, 'Phone Number *', Icons.phone_outlined),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: SizedBox(height: 48, child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeColors.textSecondary,
                    side: BorderSide(color: ThemeColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: SizedBox(height: 48, child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty || addr1Ctrl.text.trim().isEmpty ||
                        phoneCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Color(0xFFFF3B30),
                        behavior: SnackBarBehavior.floating));
                      return;
                    }
                    _cartService.setDeliveryAddress({
                      'name': nameCtrl.text.trim(),
                      'address1': addr1Ctrl.text.trim(),
                      'address2': addr2Ctrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                    });
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2713A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                  child: const Text('Save Address', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ))),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: ThemeColors.inputHint),
        prefixIcon: Icon(icon, color: ThemeColors.textSecondary, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: ThemeColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ThemeColors.border, width: 1.2)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeColors.scaffold,
          body: SafeArea(
            child: Column(children: [
              _buildAppBar(context),
              Expanded(
                child: ValueListenableBuilder<Map<String, String>>(
                  valueListenable: _cartService.deliveryAddress,
                  builder: (context, addr, child) {
                    if (!_cartService.hasAddress) return _buildEmptyState();
                    return _buildAddressCard(addr);
                  },
                ),
              ),
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showEditAddressSheet,
            backgroundColor: const Color(0xFFC2713A),
            child: Icon(
              _cartService.hasAddress ? Icons.edit : Icons.add,
              color: Colors.white),
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
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFFC2713A), size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text('Shipping Addresses', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text)),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(color: ThemeColors.accentSubtle, shape: BoxShape.circle),
          child: Icon(Icons.location_off_outlined, size: 56, color: const Color(0xFFC2713A)),
        ),
        const SizedBox(height: 24),
        Text('No Address Saved', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        const SizedBox(height: 8),
        Text('Add your shipping address to\nspeed up the checkout process.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary, height: 1.5)),
      ]),
    );
  }

  Widget _buildAddressCard(Map<String, String> addr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeColors.surface, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeColors.accentSubtle, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.location_on_outlined, color: const Color(0xFFC2713A), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Shipping Address', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.text)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
                child: const Text('Default', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF34C759))),
              ),
            ])),
            GestureDetector(
              onTap: _showEditAddressSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.edit_outlined, color: const Color(0xFFC2713A), size: 18),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Divider(color: ThemeColors.border, height: 1),
          const SizedBox(height: 20),
          // Name
          _buildInfoRow(Icons.person_outline, 'Name', addr['name'] ?? ''),
          const SizedBox(height: 16),
          // Address 1
          _buildInfoRow(Icons.home_outlined, 'Address', addr['address1'] ?? ''),
          if (addr['address2']?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.only(left: 38),
              child: Text(addr['address2']!, style: TextStyle(
                fontSize: 14, color: ThemeColors.textSecondary, height: 1.4))),
          ],
          const SizedBox(height: 16),
          // Phone
          _buildInfoRow(Icons.phone_outlined, 'Phone', addr['phone'] ?? ''),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: ThemeColors.textSecondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
          color: ThemeColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeColors.text)),
      ])),
    ]);
  }
}

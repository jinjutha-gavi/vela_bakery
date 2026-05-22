import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/theme_service.dart';
import '../widgets/menu_image.dart';
import 'home_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  String _selectedPaymentMethod = 'Cash on Delivery';
  final List<String> _paymentMethods = ['Cash on Delivery', 'Bank Transfer', 'PromptPay'];

  void _editAddress() {
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
              // Handle bar
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
                  Text('Delivery Address', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                  const SizedBox(height: 2),
                  Text('Enter your delivery details', style: TextStyle(
                    fontSize: 12, color: ThemeColors.textSecondary)),
                ])),
              ]),
              const SizedBox(height: 24),
              // Name
              _buildAddrField(nameCtrl, 'Full Name *', Icons.person_outline),
              const SizedBox(height: 14),
              // Address Line 1
              _buildAddrField(addr1Ctrl, 'Address Line 1 *', Icons.home_outlined),
              const SizedBox(height: 14),
              // Address Line 2
              _buildAddrField(addr2Ctrl, 'Address Line 2 (Optional)', Icons.apartment_outlined),
              const SizedBox(height: 14),
              // Phone
              _buildAddrField(phoneCtrl, 'Phone Number *', Icons.phone_outlined),
              const SizedBox(height: 24),
              // Buttons
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

  Widget _buildAddrField(TextEditingController ctrl, String hint, IconData icon) {
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

  Future<void> _placeOrder() async {
    if (_cartService.cartItems.value.isEmpty) return;
    if (!_cartService.hasAddress) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please add a delivery address first'),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating));
      return;
    }
    final int price = _cartService.totalPrice;
    final bool isFreeDelivery = price >= 300;
    final int deliveryFee = isFreeDelivery ? 0 : 50;
    final orderItems = _cartService.cartItems.value.map((cartItem) {
      return OrderItem(
        name: cartItem.product['name'] ?? '',
        price: cartItem.product['price'] as int,
        quantity: cartItem.quantity,
        image: cartItem.product['image'] ?? '',
        ingredients: cartItem.product['ingredients'] ?? '',
      );
    }).toList();
    final order = await OrderService().placeOrder(
      items: orderItems, totalPrice: price, deliveryFee: deliveryFee,
      deliveryAddress: _cartService.formattedAddress,
      paymentMethod: _selectedPaymentMethod,
    );
    _cartService.clearCart();
    if (!mounted) return;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(width: 80, height: 80, decoration: BoxDecoration(
              color: const Color(0xFF34C759).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Color(0xFF34C759), size: 48)),
            const SizedBox(height: 20),
            Text('Order Placed!', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: ThemeColors.text)),
            const SizedBox(height: 8),
            Text('Your order ${order.orderId} has been placed successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary, height: 1.4)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeColors.accentSubtle, borderRadius: BorderRadius.circular(12)),
              child: Text('${order.grandTotal} THB', style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFC2713A)))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final homeState = context.findAncestorStateOfType<HomeScreenState>();
                homeState?.switchToTab(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2713A), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('Track Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return SafeArea(
          child: Container(
            color: ThemeColors.scaffold,
            child: Column(children: [
              const SizedBox(height: 20),
              Text('Cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ThemeColors.text)),
              const SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: const Color(0xFFC2713A).withValues(alpha: 0.1), thickness: 2)),
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  _buildDeliveryAddress(),
                  const SizedBox(height: 20),
                  _buildCartItems(),
                  const SizedBox(height: 20),
                  _buildPaymentSummary(),
                  const SizedBox(height: 100),
                ]),
              )),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.deliveryCard, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Delivery Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        const SizedBox(height: 12),
        ValueListenableBuilder<Map<String, String>>(
          valueListenable: _cartService.deliveryAddress,
          builder: (context, addr, child) {
            if (!_cartService.hasAddress) {
              return Text('No address set. Tap "Edit Address" to add one.',
                style: TextStyle(fontSize: 13, color: ThemeColors.textSecondary, fontStyle: FontStyle.italic));
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(addr['name'] ?? '', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: ThemeColors.text)),
              const SizedBox(height: 4),
              Text(addr['address1'] ?? '', style: TextStyle(
                fontSize: 13, color: ThemeColors.textSecondary, height: 1.4)),
              if (addr['address2']?.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(addr['address2']!, style: TextStyle(
                  fontSize: 13, color: ThemeColors.textSecondary, height: 1.4)),
              ],
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.phone_outlined, size: 14, color: ThemeColors.textSecondary),
                const SizedBox(width: 4),
                Text(addr['phone'] ?? '', style: TextStyle(
                  fontSize: 13, color: ThemeColors.textSecondary)),
              ]),
            ]);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _editAddress,
          icon: Icon(Icons.edit_outlined, size: 16, color: ThemeColors.text),
          label: Text('Edit Address', style: TextStyle(fontSize: 13, color: ThemeColors.text)),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.surface, elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: ThemeColors.border))),
        ),
      ]),
    );
  }

  Widget _buildCartItems() {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: _cartService.cartItems,
      builder: (context, items, child) {
        if (items.isEmpty) {
          return Padding(padding: const EdgeInsets.all(40.0),
            child: Center(child: Text("Your cart is empty", style: TextStyle(color: ThemeColors.textSecondary))));
        }
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(borderRadius: BorderRadius.circular(16),
                child: Dismissible(
                  key: Key('${item.product['name']}_$index'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (d) => _cartService.removeItem(index),
                  background: Container(
                    color: const Color(0xFFFF3B30), alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 30)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.surface, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      MenuImage(imagePath: item.product['image'], width: 80, height: 80, fit: BoxFit.contain),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.product['name'], style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                        const SizedBox(height: 4),
                        Text(item.product['ingredients'], style: TextStyle(
                          fontSize: 12, color: ThemeColors.textSecondary),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text('${item.product['price']} THB', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: ThemeColors.text)),
                        const SizedBox(height: 12),
                        Row(children: [
                          _buildQtyButton(Icons.remove, () => _cartService.updateQuantity(index, -1)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('${item.quantity}', style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: ThemeColors.text))),
                          _buildQtyButton(Icons.add, () => _cartService.updateQuantity(index, 1)),
                        ]),
                      ])),
                    ]),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(width: 28, height: 28,
        decoration: BoxDecoration(
          color: ThemeColors.iconBg, shape: BoxShape.circle,
          border: Border.all(color: ThemeColors.border)),
        child: Icon(icon, size: 14, color: ThemeColors.textSecondary),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: _cartService.cartItems,
      builder: (context, items, child) {
        if (items.isEmpty) return const SizedBox.shrink();
        final int price = _cartService.totalPrice;
        final bool isFreeDelivery = price >= 300;
        final int deliveryFee = isFreeDelivery ? 0 : 50;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment Summary', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.text)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Price', style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary)),
            Text('$price THB', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ThemeColors.text)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Delivery Fee', style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary)),
            Row(children: [
              if (isFreeDelivery) Text('50 THB ', style: TextStyle(
                fontSize: 14, color: ThemeColors.textSecondary, decoration: TextDecoration.lineThrough)),
              Text('$deliveryFee THB', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: ThemeColors.text)),
            ]),
          ]),
          const SizedBox(height: 24),
          // Payment method dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.surface, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.border)),
            child: Row(children: [
              Icon(Icons.account_balance_wallet_outlined, color: const Color(0xFFC2713A), size: 20),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  icon: Icon(Icons.keyboard_arrow_down, color: ThemeColors.textSecondary, size: 20),
                  isExpanded: true, dropdownColor: ThemeColors.dropdownBg,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ThemeColors.text),
                  onChanged: (String? v) { if (v != null) setState(() => _selectedPaymentMethod = v); },
                  items: _paymentMethods.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                ),
              )),
            ]),
          ),
          // PromptPay QR Code
          if (_selectedPaymentMethod == 'PromptPay') ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColors.surface, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC2713A).withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.qr_code_2, color: const Color(0xFFC2713A), size: 20),
                  const SizedBox(width: 8),
                  Text('Scan to pay with PromptPay', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: ThemeColors.text)),
                ]),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/qrcode.jpg',
                    width: 220, height: 220, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text('Total: ${price + deliveryFee} THB', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFFC2713A))),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2713A), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), elevation: 2),
            child: const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          )),
        ]);
      },
    );
  }
}

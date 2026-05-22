import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../services/theme_service.dart';
import '../widgets/menu_image.dart';
import 'order_tracking_page.dart';


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedFilter = 'All';
  final List<String> _statuses = ['All', 'Preparing', 'Shipping', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return SafeArea(
          child: Container(
            color: ThemeColors.scaffold,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text('Orders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: const Color(0xFFC2713A).withValues(alpha: 0.1), thickness: 2),
                ),
                const SizedBox(height: 8),
                _buildStatusFilters(),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<Order>>(
                    valueListenable: OrderService().orders,
                    builder: (context, allOrders, child) {
                      final filtered = _selectedFilter == 'All'
                          ? allOrders
                          : allOrders.where((o) => o.statusLabel == _selectedFilter).toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildOrderList(filtered);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          final isSelected = _statuses[index] == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = _statuses[index]),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC2713A) : ThemeColors.filterChipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFFC2713A) : ThemeColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                _statuses[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : ThemeColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderTrackingPage(order: order),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: order ID + status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ${order.orderId}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: order.statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: order.statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: order.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Items summary
                Row(
                  children: [
                    // Stacked item images
                    SizedBox(
                      width: 50,
                      height: 40,
                      child: Stack(
                        children: [
                          ...order.items.take(2).toList().asMap().entries.map((entry) {
                            return Positioned(
                              left: entry.key * 18.0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: ThemeColors.iconBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: ThemeColors.surface, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: MenuImage(
                                    imagePath: entry.value.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.itemsSummary,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${order.grandTotal} THB',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC2713A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Divider
                Divider(color: ThemeColors.border, height: 1),
                const SizedBox(height: 12),
                // Bottom row: payment method + track button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: ThemeColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.paymentMethod,
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2713A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          const Text(
                            'Track',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ThemeColors.accentSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_outlined, size: 48, color: const Color(0xFFC2713A)),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedFilter == 'All' ? 'No Orders Yet' : 'No $_selectedFilter Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Your orders will appear here.'
                : 'No orders with "$_selectedFilter" status.',
            style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

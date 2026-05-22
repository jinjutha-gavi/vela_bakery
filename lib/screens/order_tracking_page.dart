import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/order_service.dart';
import '../services/theme_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final Order order;
  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late MapController _mapController;

  // Vela Bakery location (Bangkok, Sukhumvit area)
  static const _bakeryLat = 13.7363;
  static const _bakeryLng = 100.5618;

  // Delivery destination (nearby, simulated)
  static const _destLat = 13.7420;
  static const _destLng = 100.5545;

  // Route waypoints (simulated road path)
  final List<LatLng> _routePoints = const [
    LatLng(_bakeryLat, _bakeryLng),
    LatLng(13.7363, 100.5590),
    LatLng(13.7380, 100.5590),
    LatLng(13.7380, 100.5560),
    LatLng(13.7400, 100.5560),
    LatLng(13.7400, 100.5545),
    LatLng(_destLat, _destLng),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  LatLng _getVehiclePosition(OrderStatus status) {
    double progress;
    switch (status) {
      case OrderStatus.preparing:
        progress = 0.05;
        break;
      case OrderStatus.shipping:
        progress = 0.55;
        break;
      case OrderStatus.delivered:
        progress = 1.0;
        break;
    }

    // Interpolate along route
    if (_routePoints.length < 2) return _routePoints.first;

    final totalSegments = _routePoints.length - 1;
    final exactIndex = progress * totalSegments;
    final segIndex = exactIndex.floor().clamp(0, totalSegments - 1);
    final segProgress = exactIndex - segIndex;

    final from = _routePoints[segIndex];
    final to = _routePoints[min(segIndex + 1, _routePoints.length - 1)];

    return LatLng(
      from.latitude + (to.latitude - from.latitude) * segProgress,
      from.longitude + (to.longitude - from.longitude) * segProgress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return ValueListenableBuilder<List<Order>>(
          valueListenable: OrderService().orders,
          builder: (context, orders, child) {
            final currentOrder = orders.firstWhere(
              (o) => o.orderId == widget.order.orderId,
              orElse: () => widget.order,
            );

            final vehiclePos = _getVehiclePosition(currentOrder.status);

            return Scaffold(
              backgroundColor: ThemeColors.scaffold,
              body: Stack(
                children: [
                  // Real Map
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.62,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          (_bakeryLat + _destLat) / 2,
                          (_bakeryLng + _destLng) / 2,
                        ),
                        initialZoom: 15.5,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        // OpenStreetMap Tiles
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.vela.bakery',
                          maxZoom: 19,
                        ),

                        // Route polyline
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              strokeWidth: 5.0,
                              color: const Color(0xFFC2713A),
                            ),
                          ],
                        ),

                        // Markers
                        MarkerLayer(
                          markers: [
                            // Bakery marker
                            Marker(
                              point: const LatLng(_bakeryLat, _bakeryLng),
                              width: 44,
                              height: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC2713A),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            // Destination marker
                            Marker(
                              point: const LatLng(_destLat, _destLng),
                              width: 44,
                              height: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: currentOrder.status ==
                                          OrderStatus.delivered
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFFC2713A),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            // Vehicle marker (delivery rider)
                            Marker(
                              point: vehiclePos,
                              width: 48,
                              height: 48,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFC2713A)
                                              .withValues(
                                                  alpha: 0.3 +
                                                      0.2 *
                                                          _pulseController
                                                              .value),
                                          blurRadius: 8 +
                                              6 *
                                                  _pulseController
                                                      .value,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text('🛵',
                                          style:
                                              TextStyle(fontSize: 22)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ThemeColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFFC2713A),
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // GPS / recenter button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        _mapController.move(
                          LatLng(
                            (_bakeryLat + _destLat) / 2,
                            (_bakeryLng + _destLng) / 2,
                          ),
                          15.5,
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC2713A),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC2713A)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Status Badge (floating over map)
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.42 + 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildStatusBadge(currentOrder),
                    ),
                  ),

                  // Bottom Sheet
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.42,
                    minChildSize: 0.35,
                    maxChildSize: 0.75,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: ThemeColors.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: ThemeColors.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildOrderHeader(currentOrder),
                            const SizedBox(height: 24),
                            _buildDriverInfo(currentOrder),
                            const SizedBox(height: 24),
                            _buildRouteProgress(currentOrder),
                            const SizedBox(height: 24),
                            _buildOrderDetails(currentOrder),
                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(Order order) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: ThemeColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: order.statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: order.statusColor.withValues(
                          alpha: 0.4 + 0.3 * _pulseController.value),
                      blurRadius: 6 + 4 * _pulseController.value,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                order.statusMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.text,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderHeader(Order order) {
    final etaText = order.status == OrderStatus.delivered
        ? 'Delivered'
        : '${order.estimatedMinutes} minutes left';

    return Column(
      children: [
        Text(
          'Order ${order.orderId}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          etaText,
          style: TextStyle(
            fontSize: 14,
            color: ThemeColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo(Order order) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.avatarBg,
            border: Border.all(color: ThemeColors.border, width: 2),
          ),
          child: Center(
            child: Icon(Icons.person, color: ThemeColors.textSecondary, size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.driverName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < order.driverRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFC2713A),
                    size: 18,
                  );
                }),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Chat feature coming soon!'),
                backgroundColor: const Color(0xFFC2713A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ThemeColors.accentSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Color(0xFFC2713A),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Call feature coming soon!'),
                backgroundColor: const Color(0xFFC2713A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ThemeColors.accentSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: Color(0xFFC2713A),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteProgress(Order order) {
    double progress;
    switch (order.status) {
      case OrderStatus.preparing:
        progress = 0.15;
        break;
      case OrderStatus.shipping:
        progress = 0.55;
        break;
      case OrderStatus.delivered:
        progress = 1.0;
        break;
    }

    final addressLines = order.deliveryAddress.split('\n');
    final destinationLabel = addressLines.length > 1
        ? addressLines[1]
        : (addressLines.isNotEmpty ? addressLines[0] : 'Your Address');

    return Column(
      children: [
        SizedBox(
          height: 36,
          child: Stack(
            children: [
              Positioned(
                left: 24,
                right: 24,
                top: 17,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: ThemeColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: 17,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Container(
                          width: constraints.maxWidth * progress,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2713A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2713A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              Positioned(
                left: 24 +
                    (MediaQuery.of(context).size.width - 96) * progress -
                    10,
                top: 7,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2713A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC2713A)
                                .withValues(alpha: 0.3),
                            blurRadius:
                                6 + 4 * _pulseController.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: order.status == OrderStatus.delivered
                        ? const Color(0xFF34C759)
                        : const Color(0xFFC2713A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                'Vela\nBakery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                destinationLabel.length > 25
                    ? '${destinationLabel.substring(0, 25)}...'
                    : destinationLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.iconBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ThemeColors.text,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ThemeColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, e, s) => Icon(
                            Icons.cake_outlined,
                            color: ThemeColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors.text,
                        ),
                      ),
                    ),
                    Text(
                      '${item.price * item.quantity} THB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.text,
                      ),
                    ),
                  ],
                ),
              )),
          Divider(color: ThemeColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee',
                  style: TextStyle(
                      fontSize: 13, color: ThemeColors.textSecondary)),
              Text('${order.deliveryFee} THB',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.text)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment',
                  style: TextStyle(
                      fontSize: 13, color: ThemeColors.textSecondary)),
              Text(order.paymentMethod,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.text)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: ThemeColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.text)),
              Text('${order.grandTotal} THB',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC2713A))),
            ],
          ),
        ],
      ),
    );
  }
}

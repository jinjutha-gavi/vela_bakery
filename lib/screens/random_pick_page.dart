import 'package:flutter/material.dart';
import 'dart:math';
import '../services/cart_service.dart';
import '../services/theme_service.dart';
import '../services/menu_service.dart';
import '../widgets/menu_image.dart';

class RandomPickPage extends StatefulWidget {
  const RandomPickPage({super.key});
  @override
  State<RandomPickPage> createState() => _RandomPickPageState();
}

class _RandomPickPageState extends State<RandomPickPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  bool _hasRandomized = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  late Map<String, dynamic> _currentItem;

  // Fair randomization: shuffle queue ensures every item appears before repeats
  List<int> _shuffledQueue = [];
  final Random _rng = Random();

  List<Map<String, dynamic>> get _items => MenuService().menuItems.value;

  @override
  void initState() {
    super.initState();
    final items = _items;
    _currentItem = items.isNotEmpty ? items[0] : {'name': '', 'price': 0, 'image': 'assets/images/icon.png', 'ingredients': ''};
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _randomize() {
    final items = _items;
    if (items.isEmpty) return;

    // If queue is empty, create a fresh shuffled list of all indices
    if (_shuffledQueue.isEmpty) {
      _shuffledQueue = List.generate(items.length, (i) => i);
      // Fisher-Yates shuffle
      for (int i = _shuffledQueue.length - 1; i > 0; i--) {
        final j = _rng.nextInt(i + 1);
        final temp = _shuffledQueue[i];
        _shuffledQueue[i] = _shuffledQueue[j];
        _shuffledQueue[j] = temp;
      }
      // If the first item in shuffled queue is the same as current, move it to back
      if (_hasRandomized && _shuffledQueue.isNotEmpty &&
          items[_shuffledQueue.first]['name'] == _currentItem['name']) {
        _shuffledQueue.add(_shuffledQueue.removeAt(0));
      }
    }

    final nextIndex = _shuffledQueue.removeAt(0);
    setState(() {
      _hasRandomized = true;
      _quantity = 1;
      _currentItem = items[nextIndex];
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        if (!_hasRandomized) return _buildInitialView();
        return _buildRandomResult();
      },
    );
  }

  Widget _buildInitialView() {
    return Container(
      color: ThemeColors.surface,
      child: SafeArea(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(ThemeColors.themeIcon, width: 140, fit: BoxFit.contain),
            const SizedBox(height: 28),
            Text("Can't decide?", style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFFC2713A))),
            const SizedBox(height: 8),
            Text('Let us pick for you!',
              style: TextStyle(fontSize: 15, color: ThemeColors.textSecondary)),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: _randomize,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: ThemeColors.surface, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ThemeColors.border, width: 1.2),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFFC2713A).withValues(alpha: 0.12),
                    blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Padding(padding: const EdgeInsets.all(10.0),
                  child: Image.asset(ThemeColors.themeIcon, fit: BoxFit.contain)),
              ),
            ),
            const SizedBox(height: 14),
            Text('( Click here to randomize )',
              style: TextStyle(fontSize: 13, color: ThemeColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _buildRandomResult() {
    return ScaleTransition(scale: _scaleAnim,
      child: FadeTransition(opacity: _fadeAnim,
        child: Container(
          color: ThemeColors.scaffold,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(top: 0, left: 0, right: 0,
              height: MediaQuery.of(context).size.height * 0.35,
              child: PhysicalShape(
                color: ThemeColors.navBar, elevation: 10.0,
                clipper: _BottomCurveClipper(),
                shadowColor: Colors.black.withValues(alpha: 0.5),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
                  Column(children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.only(top: 75, bottom: 30, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: ThemeColors.surface, borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 24, offset: const Offset(0, 12))],
                      ),
                      child: Column(children: [
                        Text(_currentItem['name'] as String,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ThemeColors.text),
                          textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Price | ', style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary)),
                          Text('${_currentItem['price']} THB',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ThemeColors.text)),
                        ]),
                        const SizedBox(height: 8),
                        Text(_currentItem['ingredients'] as String,
                          style: TextStyle(fontSize: 13, color: ThemeColors.textSecondary),
                          textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _buildQtyButton(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text('$_quantity', style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text))),
                          _buildQtyButton(Icons.add, () { setState(() => _quantity++); }),
                        ]),
                        const SizedBox(height: 24),
                        SizedBox(width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              CartService().addToCart(_currentItem, _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${_currentItem['name']} added to cart!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFFC2713A),
                                duration: const Duration(seconds: 2),
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC2713A),
                              foregroundColor: Colors.white, elevation: 4,
                              shadowColor: const Color(0xFFC2713A).withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            ),
                            child: const Text('Add to cart',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Text('( Click here to randomize )',
                      style: TextStyle(fontSize: 12, color: ThemeColors.textSecondary)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _randomize,
                      child: Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: ThemeColors.surface, borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ThemeColors.border, width: 1),
                          boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Padding(padding: const EdgeInsets.all(12.0),
                          child: Image.asset(ThemeColors.themeIcon, fit: BoxFit.contain)),
                      ),
                    ),
                    const SizedBox(height: 130),
                  ]),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.06,
                    left: 0, right: 0,
                    child: Stack(alignment: Alignment.topCenter, children: [
                      Padding(padding: const EdgeInsets.only(top: 50),
                        child: MenuImage(imagePath: _currentItem['image'] as String?,
                          height: MediaQuery.of(context).size.height * 0.30, fit: BoxFit.contain)),
                      SizedBox(width: 350, height: 120,
                        child: CustomPaint(painter: _CurvedTextPainter())),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return Builder(builder: (context) => GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: ThemeColors.iconBg, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Icon(icon, size: 18, color: ThemeColors.textSecondary),
      ),
    ));
  }
}

class _CurvedTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height + 65);
    const radius = 175.0;
    const text = 'Enjoy the random pick !';
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final totalAngle = (text.length - 1) * 0.075;
    double startAngle = -pi / 2 - totalAngle / 2;
    for (int i = 0; i < text.length; i++) {
      final angle = startAngle + (i * 0.075);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2);
      tp.text = TextSpan(text: text[i], style: TextStyle(
        fontSize: 22, color: Colors.white.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500, fontStyle: FontStyle.italic));
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

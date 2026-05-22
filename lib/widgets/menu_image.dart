import 'package:flutter/material.dart';
import '../services/menu_service.dart';

/// A widget that displays a menu item image, supporting both
/// local assets (assets/...) and network URLs (https://...).
class MenuImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MenuImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _placeholder();
    }

    if (MenuService.isNetworkImage(imagePath)) {
      return Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFC2713A),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, e, s) => _placeholder(),
      );
    }

    return Image.asset(
      imagePath!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, e, s) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.cake_outlined, color: Color(0xFFB0B0B0), size: 28),
    );
  }
}

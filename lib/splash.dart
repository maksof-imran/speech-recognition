import 'package:dawaadost_ads/app/config/app_router.dart';
import 'package:dawaadost_ads/app/config/assets/app_images.dart';
import 'package:dawaadost_ads/app/config/page_path.dart';
import 'package:dawaadost_ads/app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalContext?.go(PagePath.home);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation!,
          child: Image.asset(AppImages.icon, width: 100),
        ),
      ),
    );
  }
}

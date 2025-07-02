import 'dart:async';

// Updated: Replaced uni_links with app_links
import 'package:dawaadost_ads/app/config/app_router.dart';
import 'package:dawaadost_ads/app/config/theme/app_colors.dart';
import 'package:dawaadost_ads/app/config/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sizer/sizer.dart';

final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

class Dawaadost extends StatefulWidget {
  const Dawaadost({super.key});

  @override
  State<Dawaadost> createState() => _DawaadostState();
}

class _DawaadostState extends State<Dawaadost> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setSystemPreferences() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.black,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setSystemPreferences();
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          title: 'Dawaadost',
          scaffoldMessengerKey: scaffoldKey,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: ThemeData(
            fontFamily: AppFont.ibpm,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              surfaceTintColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

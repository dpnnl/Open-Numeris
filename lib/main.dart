import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numeris/core/colors.dart';
import 'package:numeris/pages/home_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  runApp(const MyApp());

  // ANDROID SYSTEM UI OVERLAY
  // ANDROID 16 <
  // define statusbar e navigationbar como transparentes
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // define statusbar como visivel
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Numeris",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          surface: backgroundColor,
        ),
        useMaterial3: true,
        fontFamily: "poppins-medium",
        textTheme: const TextTheme().copyWith(
          bodySmall: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          bodyLarge: TextStyle(color: textColor),
          labelSmall: TextStyle(color: textColor),
          labelMedium: TextStyle(color: textColor),
          labelLarge: TextStyle(color: textColor),
          displaySmall: TextStyle(color: textColor),
          displayMedium: TextStyle(color: textColor),
          displayLarge: TextStyle(color: textColor),
        ),
      ),
      navigatorObservers: [routeObserver],
      home: HomePage(),
    );
  }
}

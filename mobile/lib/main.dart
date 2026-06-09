import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("FLUTTER ERROR:");
    print(details.exception);
    print(details.stack);
  };

  runApp(const BasketballApp());
}

class BasketballApp extends StatelessWidget {
  const BasketballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D1224),

        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: NoTransitionsBuilder()},
        ),
      ),

      home: const SplashScreen(),
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

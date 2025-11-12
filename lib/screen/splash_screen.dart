import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warga_kita_app/provider/user_provider.dart';
import 'package:warga_kita_app/style/colors/wargakita_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = await userProvider.checkAuthenticationStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/texture.png", fit: BoxFit.cover),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  Colors.transparent,
                  WargaKitaColors.white.color.withValues(alpha: 0.9),
                  const Color(0xFFF8F8F8),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", width: 120, height: 120),
                const SizedBox(height: 16),
                Text(
                  "WargaKita",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text("App", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),

          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              "By Group-13",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
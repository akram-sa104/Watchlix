import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3500), () {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      if (mounted) {
        Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. BACKGROUND GRADIENT LAYER
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF3B0000), 
                  Colors.black,     
                ],
              ),
            ),
          ),

          // 2. LAYER PARTIKEL PENDEARAN CAHAYA
          ..._buildBackgroundParticles(),

          // 3. LAYER LOGO "W" DENGAN EFEK PENDARAN
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: (1.0 - _controller.value).clamp(0.0, 0.15), 
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Text(
                    'W',
                    style: TextStyle(
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),

          // 4. LAYER TEKS "Watchlix" DAN LOADING INDICATOR
          FadeTransition(
            opacity: _textFadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.redAccent, Colors.orangeAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Watchlix',
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'STREAMS EVERYTHING',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 80),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   
  List<Widget> _buildBackgroundParticles() {
    return List.generate(5, (index) {
      final random = math.Random();
      return Positioned(
        top: random.nextDouble() * MediaQuery.of(context).size.height,
        left: random.nextDouble() * MediaQuery.of(context).size.width,
        child: Container(
          width: 150 + random.nextDouble() * 200,
          height: 150 + random.nextDouble() * 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity(0.03),
          ),
        ),
      );
    });
  }
}
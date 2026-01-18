import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui'; 

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  String? _errorMessage;

  // Controller untuk animasi 'bernafas' pada background orbs (Explicit Animation)
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller sesuai materi Chapter 9 [cite: 17, 85]
    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true); // Animasi bolak-balik terus menerus [cite: 13]

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk mencegah memory leak [cite: 87, 102]
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _auth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email dan password harus diisi.');
      return;
    }
    setState(() => _errorMessage = null);
    try {
      if (isLogin) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email, 
          password: password,
        );
        if (response.session != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        await Supabase.instance.client.auth.signUp(email: email, password: password);
        setState(() {
          _errorMessage = 'Registrasi berhasil! Silakan login.';
          isLogin = true;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background Layer: Radial Gradient [cite: 11]
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF2C0B0E), // Maroon gelap
                  Colors.black,
                ],
              ),
            ),
          ),

          // 2. Animated Glow Orbs (Dekorasi Latar Belakang)
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: _buildGlowOrb(200 * _glowAnimation.value, Colors.redAccent.withOpacity(0.1)),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -50,
                    child: _buildGlowOrb(300 * _glowAnimation.value, Colors.orangeAccent.withOpacity(0.05)),
                  ),
                ],
              );
            },
          ),

          // 3. Main Content Layer
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero Animation agar logo sinkron dengan Splash Screen 
                    Hero(
                      tag: 'logo-watchlix',
                      child: Material(
                        color: Colors.transparent,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.redAccent, Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            'Watchlix',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Card Login (Glassmorphism) [cite: 30, 80]
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              if (_errorMessage != null)
                                Text(_errorMessage!, 
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 15),
                              _buildInput(controller: _emailController, label: 'Email', icon: Icons.email_outlined),
                              const SizedBox(height: 15),
                              _buildInput(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPass: true),
                              const SizedBox(height: 30),
                              
                              // Tombol Utama
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _auth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: Text(isLogin ? 'Login' : 'Register', 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              TextButton(
                                onPressed: () => setState(() => isLogin = !isLogin),
                                child: Text(
                                  isLogin ? "Don't have an account? Create one" : "Already have an account? Sign In",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper UI: Input Field
  Widget _buildInput({required TextEditingController controller, required String label, required IconData icon, bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  // Helper UI: Background Orbs
  Widget _buildGlowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 80, spreadRadius: 40),
        ],
      ),
    );
  }
}
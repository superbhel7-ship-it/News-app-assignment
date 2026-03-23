import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showLogin = false; // toggle between welcome & login form
  bool _isSignUp = false;
  bool _awaitingSignUpSuccess = false;

  late AnimationController _fadeController;
  late AnimationController _globeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _globeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null) {
        _awaitingSignUpSuccess = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (_awaitingSignUpSuccess &&
          prev?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        _awaitingSignUpSuccess = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _showLogin ? _buildLoginForm(authState) : _buildWelcome(),
      ),
    );
  }

  // ─── Welcome Screen (exact match) ───
  Widget _buildWelcome() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E14),
            Color(0xFF0D1520),
            Color(0xFF0A0E14),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // "Artics" title
            const Text(
              'Artics',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            // Lottie globe animation
            Expanded(
              flex: 3,
              child: Lottie.asset(
                'assets/animations/news_globe.json',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildGlobe(),
              ),
            ),
            // "Your Daily Digest"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Your Daily Digest',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Trustworthy news from reputable\npublications.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _showLogin = true;
                        _isSignUp = true;
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Log back in button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _showLogin = true;
                        _isSignUp = false;
                      }),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppTheme.dividerColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Log back in',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Terms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Terms of Serives',
                      style: TextStyle(
                        color: AppTheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    const TextSpan(text: '.\nFor more information, see our '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Globe Graphic (animated) ───
  Widget _buildGlobe() {
    return AnimatedBuilder(
      animation: _globeController,
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: _GlobePainter(
                rotation: _globeController.value * 2 * pi,
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Login / Sign Up Form ───
  Widget _buildLoginForm(AuthState authState) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E14),
            Color(0xFF0D1520),
            Color(0xFF0A0E14),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Lottie lock animation
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Lottie.asset(
                    'assets/animations/login_anim.json',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.3),
                            AppTheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.public,
                          size: 40, color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Sign up to get your daily news digest'
                      : 'Log in to continue reading',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 36),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppTheme.textSecondary, size: 20),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 14),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppTheme.textSecondary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }),
                      ),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            if (_isSignUp) {
                              final confirmPassword =
                                  _confirmPasswordController.text;
                              if (password != confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Passwords do not match'),
                                    backgroundColor: AppTheme.errorColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              _awaitingSignUpSuccess = true;
                              ref
                                  .read(authProvider.notifier)
                                  .signUp(email, password);
                            } else {
                              _awaitingSignUpSuccess = false;
                              ref
                                  .read(authProvider.notifier)
                                  .login(email, password);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Sign Up' : 'Log In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle
                GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _awaitingSignUpSuccess = false;
                    _confirmPasswordController.clear();
                  }),
                  child: Text.rich(
                    TextSpan(
                      text: _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                      children: [
                        TextSpan(
                          text: _isSignUp ? 'Log In' : 'Sign Up',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Globe Painter ───
class _GlobePainter extends CustomPainter {
  final double rotation;

  _GlobePainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF1E88E5).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, radius + 20, glowPaint);

    // Globe background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1a2a3a),
          const Color(0xFF0d1520),
          const Color(0xFF060a10),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Globe border
    final borderPaint = Paint()
      ..color = const Color(0xFF1E88E5).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Latitude lines
    final latPaint = Paint()
      ..color = const Color(0xFF1E88E5).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = -2; i <= 2; i++) {
      final y = center.dy + (i * radius * 0.3);
      final halfWidth = sqrt(max(0, radius * radius - pow(y - center.dy, 2)));
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, y),
          width: halfWidth * 2,
          height: radius * 0.15,
        ),
        0,
        pi * 2,
        false,
        latPaint,
      );
    }

    // Longitude lines (rotating)
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + rotation;
      final xOffset = cos(angle) * radius * 0.5;

      final longPath = Path();
      longPath.moveTo(center.dx + xOffset, center.dy - radius);
      longPath.quadraticBezierTo(
        center.dx + xOffset * 1.8,
        center.dy,
        center.dx + xOffset,
        center.dy + radius,
      );
      canvas.drawPath(longPath, latPaint);
    }

    // Continent-like shapes (dots)
    final dotPaint = Paint()..color = const Color(0xFF1E88E5).withValues(alpha: 0.25);
    final random = Random(42);
    for (int i = 0; i < 60; i++) {
      final angle = random.nextDouble() * 2 * pi + rotation * 0.3;
      final r = random.nextDouble() * radius * 0.85;
      final x = center.dx + cos(angle) * r * 0.7;
      final y = center.dy + sin(angle) * r * 0.9;

      final distFromCenter = sqrt(pow(x - center.dx, 2) + pow(y - center.dy, 2));
      if (distFromCenter < radius - 5) {
        canvas.drawCircle(Offset(x, y), 1.5 + random.nextDouble() * 2, dotPaint);
      }
    }

    // Red accent dots (like in the design)
    final redPaint = Paint()..color = const Color(0xFFFF4444).withValues(alpha: 0.7);
    final redPositions = [
      Offset(center.dx - 30, center.dy - 20),
      Offset(center.dx + 50, center.dy + 30),
      Offset(center.dx - 60, center.dy + 40),
      Offset(center.dx + 20, center.dy - 50),
      Offset(center.dx + 70, center.dy - 10),
    ];
    for (final pos in redPositions) {
      final dist = sqrt(pow(pos.dx - center.dx, 2) + pow(pos.dy - center.dy, 2));
      if (dist < radius - 10) {
        canvas.drawCircle(pos, 3, redPaint);
        // Glow around red dot
        final redGlow = Paint()
          ..color = const Color(0xFFFF4444).withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, 6, redGlow);
      }
    }

    // Highlight arc at top
    final highlightPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: -pi / 2,
        endAngle: pi / 4,
        colors: [
          const Color(0xFF1E88E5).withValues(alpha: 0.0),
          const Color(0xFF1E88E5).withValues(alpha: 0.15),
          const Color(0xFF1E88E5).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -pi * 0.7,
      pi * 0.5,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

import 'package:flutter/material.dart';
import '../main_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffDB3022);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(flex: 3),
              
              // Custom Confetti & Shopping Bags Illustration
              Center(child: _buildSuccessIllustration()),
              
              const SizedBox(height: 40),
              
              const Text(
                "Success!",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your order will be delivered soon.\nThank you for choosing our app!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const Spacer(flex: 4),
              
              // CONTINUE SHOPPING Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "CONTINUE SHOPPING",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti pieces background
          ..._buildConfettiList(),

          // Yellow/Orange Shopping Bag (Background Left)
          Positioned(
            left: 55,
            top: 75,
            child: Transform.rotate(
              angle: -0.15,
              child: _buildShoppingBag(
                color: const Color(0xffF2A900),
                width: 65,
                height: 85,
              ),
            ),
          ),

          // Red Shopping Bag (Foreground Right)
          Positioned(
            left: 95,
            top: 90,
            child: Transform.rotate(
              angle: 0.1,
              child: _buildShoppingBag(
                color: const Color(0xffDB3022),
                width: 80,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingBag({required Color color, required double width, required double height}) {
    return SizedBox(
      width: width,
      height: height + 24,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Bag handle loop
          Container(
            width: width * 0.45,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.12), width: 2.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          // Bag body
          Positioned(
            top: 18,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfettiList() {
    final confettiData = [
      // (left, top, color, rotation, width, height)
      (30.0, 60.0, const Color(0xffF2A900), 0.3, 10.0, 10.0),     // Yellow square
      (210.0, 75.0, const Color(0xffDB3022), -0.4, 8.0, 18.0),    // Red ribbon
      (45.0, 175.0, const Color(0xff4F4F4F), 0.8, 6.0, 12.0),     // Grey rectangle
      (200.0, 185.0, const Color(0xffF2A900), 0.15, 12.0, 6.0),   // Yellow ribbon
      (35.0, 120.0, const Color(0xffDB3022), -0.2, 7.0, 7.0),     // Red square
      (225.0, 130.0, const Color(0xff4F4F4F), 0.5, 9.0, 9.0),     // Grey square
      (90.0, 30.0, const Color(0xffF2A900), 0.6, 8.0, 14.0),      // Yellow ribbon
      (160.0, 45.0, const Color(0xffDB3022), -0.5, 6.0, 12.0),    // Red ribbon
    ];

    return confettiData.map((data) {
      final left = data.$1;
      final top = data.$2;
      final color = data.$3;
      final rotation = data.$4;
      final w = data.$5;
      final h = data.$6;

      return Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }).toList();
  }
}

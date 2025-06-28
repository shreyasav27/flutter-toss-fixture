import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class TossScreen extends StatefulWidget {
  const TossScreen({super.key});

  @override
  State<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _resultImage = 'assets/images/coin_head.png';
  bool _isFlipping = false;
  String _tossResult = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _animation = Tween<double>(begin: 0, end: 10 * pi).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isFlipping = false;
            bool isHeads = Random().nextBool();
            _resultImage = isHeads ? 'assets/images/coin_head.png' : 'assets/images/coin_tail.png';
            _tossResult = isHeads ? 'Heads' : 'Tails';
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startToss() {
    setState(() {
      _isFlipping = true;
      _tossResult = '';
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Cricket Toss',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_animation.value),
                  child: Image.asset(
                    _resultImage,
                    width: 180,
                    height: 180,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            if (_tossResult.isNotEmpty)
              Text(
                '$_tossResult!',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                ),
              ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isFlipping ? null : _startToss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text(
                'Flip Coin',
                style: GoogleFonts.poppins(fontSize: 22, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
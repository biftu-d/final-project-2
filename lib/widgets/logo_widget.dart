import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({super.key, this.size = 80, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700), // Gold background
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hammer
              Transform.rotate(
                angle: -0.785398, // -45 degrees
                child: Icon(
                  Icons.build,
                  size: size * 0.4,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
              // Screwdriver
              Transform.rotate(
                angle: 0.785398, // 45 degrees
                child: Icon(
                  Icons.construction,
                  size: size * 0.4,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'ProMatch',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ],
    );
  }
}

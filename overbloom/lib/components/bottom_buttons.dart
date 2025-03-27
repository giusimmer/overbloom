import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  final VoidCallback? onTap1;
  final VoidCallback? onTap2;
  final VoidCallback? onTap3;

  const BottomButtons({
    super.key,
    this.onTap1,
    this.onTap2,
    this.onTap3,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap1,
            child: Image.asset('assets/images/amigos_button.png', width: 117),
          ),
          GestureDetector(
            onTap: onTap2,
            child: Image.asset('assets/images/ranking_button.png', width: 117),
          ),
          GestureDetector(
            onTap: onTap3,
            child: Image.asset('assets/images/calendario_button.png', width: 117),
          ),
        ],
      ),
    );
  }
}

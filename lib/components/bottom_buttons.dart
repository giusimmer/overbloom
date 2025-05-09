import 'package:flutter/material.dart';

import '../service/message_badge.dart';

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
          ValueListenableBuilder(
            valueListenable: MessageBadge.hasNewMessage,
            builder: (context, bool hasNew, _) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: onTap1,
                    child: Image.asset(
                      'assets/images/buttons/amigos_button.png',
                      width: 117,
                    ),
                  ),
                  if (hasNew)
                    Positioned(
                      top: 0,
                      right: 1,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          GestureDetector(
            onTap: onTap2,
            child: Image.asset('assets/images/buttons/ranking_button.png',
                width: 117),
          ),
          GestureDetector(
            onTap: onTap3,
            child: Image.asset('assets/images/buttons/calendario_button.png',
                width: 117),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final String? fundo;

  const BaseScreen({
    super.key,
    required this.child,
    this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo/$fundo'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final String assetPath;
  const FullScreenImageView({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: Image.network(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, color: Colors.white);
          },
        ),
      ),
    );
    ;
  }
}




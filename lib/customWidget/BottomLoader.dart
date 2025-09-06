// widgets/bottom_loader.dart
import 'package:flutter/material.dart';

import '../constant/color.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.kPrimary,
          ),
          SizedBox(height: 8),
          Text(
            "Loading more...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

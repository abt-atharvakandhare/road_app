import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class BottomLoadingWidget extends StatelessWidget {
  const BottomLoadingWidget({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: LinearProgressIndicator(
              minHeight: 10, color: RMColors.rmPrimaryColor, backgroundColor: Colors.transparent)),
    );
  }
}

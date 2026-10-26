import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../colors.dart';

class RMLoader extends StatefulWidget {
  const RMLoader({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;
  final bool isLoading;

  @override
  State<RMLoader> createState() => _TkLoaderState();
}

class _TkLoaderState extends State<RMLoader> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _key, child: widget.child);

    return widget.isLoading
        ? PopScope(
            canPop: false,
            child: Stack(
              children: [
                child,
                Container(
                  color: RMColors.rmPrimaryColor.withValues(alpha: 0.95),
                  child: Center(
                    child: Lottie.asset('assets/lottie/loader_logo.json'),
                  ),
                ),
              ],
            ),
          )
        : child;
  }
}

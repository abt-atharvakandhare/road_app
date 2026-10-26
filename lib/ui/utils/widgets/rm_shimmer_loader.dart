import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../colors.dart';

enum ShimmerTemplate {
  headerPlus3Lines,
  stationList;

  Widget get shimmerTemplate {
    switch (this) {
      case ShimmerTemplate.headerPlus3Lines:
        return Column(children: [
          Container(
            height: 24,
            width: double.infinity,
            color: RMColors.separatorLightGrey,
          ),
          const SizedBox(height: 24),
          Container(
            height: 16,
            width: double.infinity,
            color: RMColors.separatorLightGrey,
          ),
          const SizedBox(height: 10),
          Container(
            height: 16,
            width: double.infinity,
            color: RMColors.separatorLightGrey,
          ),
          const SizedBox(height: 10),
          Container(
            height: 16,
            width: double.infinity,
            color: RMColors.separatorLightGrey,
          ),
        ]);
      case ShimmerTemplate.stationList:
        return Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Leading icon placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: RMColors.separatorLightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Station name
                        Container(
                          height: 18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: RMColors.separatorLightGrey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Address
                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            color: RMColors.separatorLightGrey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Status icons row
                        Row(
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: RMColors.separatorLightGrey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Distance placeholder
                  Container(
                    height: 16,
                    width: 50,
                    decoration: BoxDecoration(
                      color: RMColors.separatorLightGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class RMShimmerLoader extends StatefulWidget {
  const RMShimmerLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.minDisplayDuration = 300,
    this.template = ShimmerTemplate.headerPlus3Lines,
  });

  final Widget child;
  final bool isLoading;
  final int minDisplayDuration;
  final ShimmerTemplate template;

  @override
  State<RMShimmerLoader> createState() => _TkLoaderState();
}

class _TkLoaderState extends State<RMShimmerLoader> {
  final _key = GlobalKey();
  late ValueNotifier<bool> _isShimmeringValue;
  DateTime? _startedShimmeringTime;

  @override
  void initState() {
    super.initState();
    _isShimmeringValue = ValueNotifier(widget.isLoading);
    if (widget.isLoading) {
      _startedShimmeringTime = DateTime.now();
    }
  }

  @override
  void didUpdateWidget(RMShimmerLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isShimmeringValue.value == widget.isLoading) return;

    if (widget.isLoading) {
      _startedShimmeringTime = DateTime.now();
      _isShimmeringValue.value = true;
      return;
    }

    assert(!widget.isLoading);

    // Always keep shimmering for at least minDisplayDuration to avoid flickering
    final now = DateTime.now();
    final durationSinceDisplay = now.difference(_startedShimmeringTime!);
    if (durationSinceDisplay.inMilliseconds < widget.minDisplayDuration) {
      Future.delayed(Duration(milliseconds: widget.minDisplayDuration - durationSinceDisplay.inMilliseconds), () {
        if (!widget.isLoading) {
          _stopShimmering();
        }
      });
    } else {
      _stopShimmering();
    }
  }

  void _stopShimmering() {
    _isShimmeringValue.value = false;
    _startedShimmeringTime = null;
  }

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _key, child: widget.child);

    return ValueListenableBuilder(
      valueListenable: _isShimmeringValue,
      builder: (context, value, _) {
        return value
            ? Shimmer.fromColors(
                baseColor: RMColors.separatorLightGrey,
                highlightColor: RMColors.separatorDarkGrey,
                child: widget.template.shimmerTemplate,
              )
            : child;
      },
    );
  }
}

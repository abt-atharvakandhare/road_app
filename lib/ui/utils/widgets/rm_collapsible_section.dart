import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

/// Collapsible section for the location detail drawer, styled like the EVSE
/// accordion rows: a bold title with a rotating chevron, and an animated
/// size transition for [child]. Collapsed by default; [child] is not built
/// until the first expansion, so its network/platform work only starts when
/// the user asks for it.
class RMCollapsibleSection extends StatefulWidget {
  const RMCollapsibleSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  State<RMCollapsibleSection> createState() => _RMCollapsibleSectionState();
}

class _RMCollapsibleSectionState extends State<RMCollapsibleSection> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _hasBeenExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _chevronRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _chevronRotation = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _hasBeenExpanded = true;
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                RotationTransition(
                  turns: _chevronRotation,
                  child: Icon(Icons.expand_more, size: 20, color: RMColors.rmPrimaryColor),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _hasBeenExpanded ? widget.child : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

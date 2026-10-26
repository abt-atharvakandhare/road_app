import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

/// Bottom sheet for searching and selecting network operators.
///
/// Returns the updated selection when dismissed (via drag, back, or close button).
/// Kept in its own file so presentation can be swapped to modal/push later.
class NetworkSearchBottomSheet extends StatefulWidget {
  const NetworkSearchBottomSheet({
    super.key,
    required this.allOperators,
    required this.selectedOperators,
    required this.title,
  });

  final List<String> allOperators;
  final List<String> selectedOperators;
  final String title;

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> allOperators,
    required List<String> selectedOperators,
    required String title,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => NetworkSearchBottomSheet(
        allOperators: allOperators,
        selectedOperators: selectedOperators,
        title: title,
      ),
    );
  }

  @override
  State<NetworkSearchBottomSheet> createState() => _NetworkSearchBottomSheetState();
}

class _NetworkSearchBottomSheetState extends State<NetworkSearchBottomSheet> {
  late Set<String> _selected;
  String _query = '';
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedOperators);
    // Defer focus to avoid visual jump on Android when keyboard opens
    // simultaneously with the bottom sheet animation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<String> get _filteredOperators {
    if (_query.isEmpty) return widget.allOperators;
    final lowerQuery = _query.toLowerCase();
    return widget.allOperators.where((op) => op.toLowerCase().contains(lowerQuery)).toList();
  }

  void _close() {
    Navigator.of(context).pop(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filteredOperators;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_selected.toList());
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle + close button
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _close,
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  focusNode: _searchFocusNode,
                  autocorrect: false,
                  style: Theme.of(context).textTheme.labelMedium,
                  decoration: InputDecoration(
                    hintText: l10n.searchNetworks,
                    hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: RMColors.containerBorderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: RMColors.containerBorderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
              ),
              // Results list or empty state
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noNetworksFound,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Divider(height: 1, color: RMColors.separatorLightGrey),
                        itemBuilder: (context, index) {
                          final operator = filtered[index];
                          final isSelected = _selected.contains(operator);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selected.remove(operator);
                                } else {
                                  _selected.add(operator);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      operator,
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    isSelected
                                        ? 'assets/icons/multi_select_selected.svg'
                                        : 'assets/icons/multi_select_unselected.svg',
                                    colorFilter: ColorFilter.mode(
                                      isSelected ? RMColors.rmPrimaryColor : RMColors.sliderGrey,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

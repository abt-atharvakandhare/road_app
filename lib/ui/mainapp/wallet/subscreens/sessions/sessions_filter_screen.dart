import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_month_picker.dart';
import 'package:road_mobile/ui/utils/widgets/rm_year_picker.dart';

import 'cubit/sessions_cubit.dart';

class SessionsFilterScreen extends StatefulWidget {
  static void pushAsModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) {
          return BlocProvider.value(
            value: BlocProvider.of<SessionsCubit>(context),
            child: const SessionsFilterScreen(),
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  const SessionsFilterScreen({super.key});

  @override
  State<SessionsFilterScreen> createState() => _SessionsFilterScreenState();
}

class _SessionsFilterScreenState extends State<SessionsFilterScreen> {
  int? _selectedYear;
  int? _selectedMonth;
  String? _selectedChargeCardTokenId;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    final state = BlocProvider.of<SessionsCubit>(context).state;
    _selectedYear = state.selectedYear;
    _selectedMonth = state.selectedMonth;
    _selectedChargeCardTokenId = state.selectedChargeCardTokenId;
    _selectedPaymentMethod = state.selectedPaymentMethod;
  }

  void _applyFiltersAndClose() {
    BlocProvider.of<SessionsCubit>(context).applyFilters(
      year: _selectedYear,
      month: _selectedMonth,
      chargeCardTokenId: _selectedChargeCardTokenId,
      paymentMethod: _selectedPaymentMethod,
    );
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _selectedChargeCardTokenId = null;
      _selectedPaymentMethod = null;
    });
  }

  bool get _hasActiveFilters =>
      _selectedYear != null ||
      _selectedMonth != null ||
      _selectedChargeCardTokenId != null ||
      _selectedPaymentMethod != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _applyFiltersAndClose,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.filters,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Filter by charge card (behind feature flag)
              if (Defines.showChargeCardFilter) ...[
                _buildFilterLabel(l10n.chargeCard),
                const SizedBox(height: 8),
                _buildDropdownSelector(
                  value: _selectedChargeCardTokenId,
                  hint: l10n.selectOption,
                  onTap: () {
                    // TODO: Show charge card picker when backend supports it
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Filter by year
              _buildFilterLabel(l10n.filterByYear),
              const SizedBox(height: 8),
              _buildDropdownSelector(
                value: _selectedYear?.toString(),
                hint: l10n.selectOption,
                onTap: () => _showYearPicker(context),
              ),
              const SizedBox(height: 24),

              // Filter by month
              _buildFilterLabel(l10n.filterByMonth),
              const SizedBox(height: 8),
              _buildDropdownSelector(
                value: _selectedMonth != null ? _getMonthName(_selectedMonth!) : null,
                hint: l10n.selectOption,
                onTap: () => _showMonthPicker(context),
              ),
              const SizedBox(height: 24),

              // Payment method (behind feature flag)
              if (Defines.showPaymentMethodFilter) ...[
                _buildFilterLabel(l10n.paymentMethod),
                const SizedBox(height: 8),
                _buildDropdownSelector(
                  value: _selectedPaymentMethod,
                  hint: l10n.selectOption,
                  onTap: () {
                    // TODO: Show payment method picker when backend supports it
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Clear Filters button
              if (_hasActiveFilters) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      l10n.clearFilters,
                      style: TextStyle(
                        color: RMColors.rmPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildDropdownSelector({
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: RMColors.separatorDarkGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: value != null ? Colors.black : RMColors.searchTextGrey,
                    ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              color: RMColors.searchTextGrey,
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return RmYearPicker(
          initialYear: _selectedYear ?? DateTime.now().year,
          onYearSelected: (year) {
            setState(() {
              _selectedYear = year;
            });
          },
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return RmMonthPicker(
          initialMonth: _selectedMonth ?? DateTime.now().month,
          onMonthSelected: (month) {
            setState(() {
              _selectedMonth = month;
              // Auto-fill year if not already set
              _selectedYear ??= _inferYearForMonth(month);
            });
          },
        );
      },
    );
  }

  /// Infers the most recent year where the given month has occurred.
  /// If the month is in the future for this year, returns last year.
  int _inferYearForMonth(int month) {
    final now = DateTime.now();
    if (month <= now.month) {
      return now.year;
    } else {
      return now.year - 1;
    }
  }

  String _getMonthName(int month) {
    // Use intl for localized month names
    final date = DateTime(0, month);
    return DateFormat.MMMM().format(date);
  }
}

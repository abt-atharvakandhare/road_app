import 'package:flutter/material.dart';
import 'package:road_mobile/data/model/invoices/invoices_model.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';

class InvoiceItemWidget extends StatelessWidget {
  const InvoiceItemWidget({super.key, required this.invoice, required this.isActive, required this.onPressed});

  final InvoiceModel invoice;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return RMInkwellButton(
        padding: const EdgeInsets.symmetric(vertical: 0),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${invoice.month.monthName} ${invoice.year}', style: Theme.of(context).textTheme.titleSmall),
            Text(invoice.totalInvoiceAmountWithVatString, style: Theme.of(context).textTheme.bodySmall),
          ],
        ));
  }
}

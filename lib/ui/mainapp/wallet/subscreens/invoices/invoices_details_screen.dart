import 'package:flutter/material.dart';
import 'package:road_mobile/data/model/invoices/invoices_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  const InvoiceDetailsScreen({super.key, required this.invoice});

  final InvoiceModel invoice;

  static Future<bool?> push(BuildContext context, InvoiceModel invoice) async {
    return Navigator.push<bool>(context, MaterialPageRoute(builder: ((routeContext) {
      return InvoiceDetailsScreen(invoice: invoice);
    })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.invoiceDetails, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        Text(
          '${invoice.month.monthName} ${invoice.year}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        const RMSeparator(),
        const SizedBox(height: 10),
        _buildInvoiceDetailsWidgetItem(
            context,
            AppLocalizations.of(context)!.price,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${invoice.totalInvoiceAmountWithVatString} ${AppLocalizations.of(context)!.inclVat}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text('${invoice.totalInvoiceAmountWithoutVatString} ${AppLocalizations.of(context)!.exclVat}',
                  style: Theme.of(context).textTheme.labelMedium),
            ])),
        // _buildInvoiceDetailsTextItem(context, AppLocalizations.of(context)!.usage, invoice.formattedKwhString),
        // if (invoice.durationSeconds != null)
        //   _buildInvoiceDetailsTextItem(context, AppLocalizations.of(context)!.duration,
        //       invoice.durationSeconds!.toInt().toDaysHoursMinutesString(context)),
        // _buildInvoiceDetailsTextItem(
        //     context, AppLocalizations.of(context)!.startTime, invoice.startedAt.toLocal().timeMeridiemMonthDayYear),
        // if (invoice.endedAt != null) ...[
        //   _buildInvoiceDetailsTextItem(
        //       context, AppLocalizations.of(context)!.endTime, invoice.endedAt!.toLocal().timeMeridiemMonthDayYear)
        // ]
        RMTextButton(
            onPressed: () {
              final url = invoice.downloadUriForInvoice;
              if (url != null) {
                launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            text: AppLocalizations.of(context)!.downloadInvoice)
      ]),
    );
  }

  // _buildInvoiceDetailsTextItem(BuildContext context, String title, String details) {
  //   return _buildInvoiceDetailsWidgetItem(
  //       context,
  //       title,
  //       Text(
  //         details,
  //         style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
  //       ));
  // }

  Widget _buildInvoiceDetailsWidgetItem(BuildContext context, String title, Widget details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(title, style: Theme.of(context).textTheme.labelMedium)),
          details,
        ],
      ),
    );
  }
}

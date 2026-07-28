import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds a simple PDF receipt and opens the OS share sheet (WhatsApp, Save, etc.).
Future<void> shareReceiptPdf({
  required String orderNumber,
  required String shareText,
  String? vendorName,
  List<({String name, String price})> items = const [],
  List<({String label, String value})> billLines = const [],
  String? paymentMethod,
}) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Yjeek Receipt',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Order #$orderNumber'),
            if (vendorName != null && vendorName.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(vendorName),
            ],
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            for (final item in items) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text(item.name)),
                  pw.Text(item.price),
                ],
              ),
              pw.SizedBox(height: 4),
            ],
            if (billLines.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              for (final line in billLines) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(line.label),
                    pw.Text(line.value),
                  ],
                ),
                pw.SizedBox(height: 4),
              ],
            ],
            if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text('Paid: $paymentMethod'),
            ],
            pw.SizedBox(height: 20),
            pw.Text(
              shareText,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        );
      },
    ),
  );

  final bytes = await doc.save();
  final dir = await getTemporaryDirectory();
  final safeName = orderNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final file = File('${dir.path}/yjeek-receipt-$safeName.pdf');
  await file.writeAsBytes(bytes, flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/pdf')],
      text: shareText,
      subject: 'Yjeek Receipt #$orderNumber',
    ),
  );
}

/// Opens WhatsApp with the receipt text prefilled (fallback / direct share).
Future<bool> shareReceiptWhatsApp(String shareText) async {
  final uri = Uri.parse(
    'https://wa.me/?text=${Uri.encodeComponent(shareText)}',
  );
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

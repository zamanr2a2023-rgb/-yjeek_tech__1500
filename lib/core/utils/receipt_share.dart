import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds a PDF that follows the in-app receipt paper, then opens the share sheet.
Future<void> shareReceiptPdf({
  required String orderNumber,
  String shareText = '',
  String? vendorName,
  String? badgeLabel,
  String? vendorAddress,
  String? orderDate,
  String? typeLabel,
  String? deliverTo,
  List<({String name, String price})> items = const [],
  List<({String label, String value})> billLines = const [],
  String? paymentMethod,
}) async {
  final doc = pw.Document();
  final title = _pdfText(vendorName ?? '');
  final address = _pdfText(vendorAddress ?? '');
  final badge = _pdfText(
    (badgeLabel ?? '').replaceAll('✓', '').replaceAll('✔', '').trim(),
  );
  final meta = <({String label, String value})>[
    (label: 'Order #', value: orderNumber),
    if (orderDate != null && orderDate.isNotEmpty)
      (label: 'Date', value: orderDate),
    if (typeLabel != null && typeLabel.isNotEmpty)
      (label: 'Type', value: typeLabel),
    if (deliverTo != null && deliverTo.isNotEmpty)
      (label: 'Deliver to', value: deliverTo),
  ];

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
      build: (context) {
        return pw.Container(
          color: PdfColor.fromHex('#F4F6F4'),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(16),
              border: pw.Border.all(color: PdfColor.fromHex('#E6EBE6')),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                if (badge.isNotEmpty)
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#E3F2EB'),
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        badge,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#127036'),
                        ),
                      ),
                    ),
                  ),
                if (title.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1A1A1A'),
                    ),
                  ),
                ],
                if (address.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    address,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex('#6B756E'),
                    ),
                  ),
                ],
                if (meta.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  _dashedDivider(),
                  pw.SizedBox(height: 12),
                  for (var i = 0; i < meta.length; i++) ...[
                    if (i > 0) pw.SizedBox(height: 8),
                    _labelValue(meta[i].label, meta[i].value),
                  ],
                ],
                pw.SizedBox(height: 12),
                _dashedDivider(),
                pw.SizedBox(height: 12),
                _labelValue('ITEM', 'PRICE', valueWeight: pw.FontWeight.bold),
                pw.SizedBox(height: 8),
                if (items.isEmpty)
                  pw.Text(
                    'No items',
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColor.fromHex('#6B756E'),
                    ),
                  )
                else
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) pw.SizedBox(height: 8),
                    _labelValue(
                      items[i].name,
                      items[i].price,
                      labelColor: PdfColor.fromHex('#1A1A1A'),
                    ),
                  ],
                if (billLines.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  _dashedDivider(),
                  pw.SizedBox(height: 12),
                  for (var i = 0; i < billLines.length; i++) ...[
                    if (i > 0) pw.SizedBox(height: 8),
                    _labelValue(
                      billLines[i].label,
                      billLines[i].value,
                      bold: billLines[i].label.toLowerCase() == 'total',
                    ),
                  ],
                ],
                if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  _labelValue('Paid', paymentMethod),
                ],
              ],
            ),
          ),
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

pw.Widget _labelValue(
  String label,
  String value, {
  bool bold = false,
  PdfColor? labelColor,
  pw.FontWeight? valueWeight,
}) {
  final size = bold ? 15.0 : 13.0;
  final weight = bold ? pw.FontWeight.bold : pw.FontWeight.normal;
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Text(
          _pdfText(label),
          style: pw.TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: labelColor ??
                (bold ? PdfColor.fromHex('#1A1A1A') : PdfColor.fromHex('#6B756E')),
          ),
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Text(
        _pdfText(value),
        style: pw.TextStyle(
          fontSize: bold ? 16 : 13,
          fontWeight: valueWeight ?? (bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          color: PdfColor.fromHex('#1A1A1A'),
        ),
      ),
    ],
  );
}

pw.Widget _dashedDivider() {
  const dash = 4.0;
  const gap = 3.0;
  const count = 62;
  return pw.Row(
    children: [
      for (var i = 0; i < count; i++)
        pw.Container(
          width: dash,
          height: 1,
          margin: const pw.EdgeInsets.only(right: gap),
          color: PdfColor.fromHex('#C7CCC7'),
        ),
    ],
  );
}

/// Helvetica in the PDF library cannot draw every Unicode mark.
/// Those missing glyphs showed up as broken boxes between names and prices.
String _pdfText(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    switch (rune) {
      case 0x2014:
      case 0x2013:
        buffer.write(' - ');
      case 0x2212:
        buffer.write('-');
      case 0x00D7:
        buffer.write('x');
      case 0x00B7:
        buffer.write(' - ');
      case 0x2713:
      case 0x2714:
      case 0x2611:
      case 0x2612:
        break;
      default:
        if (rune == 0x0A || (rune >= 0x20 && rune <= 0x7E) || (rune >= 0xA0 && rune <= 0xFF)) {
          buffer.writeCharCode(rune);
        } else {
          buffer.write(' ');
        }
    }
  }
  return buffer.toString().replaceAll(RegExp(r' {2,}'), ' ').trim();
}

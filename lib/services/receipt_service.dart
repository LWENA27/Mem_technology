import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

// Platform-specific imports
import 'dart:io' if (dart.library.html) '';
import 'package:path_provider/path_provider.dart' if (dart.library.html) '';

class ReceiptService {
  static const String _companyName = 'InventoryMaster';
  static const String _tagline = 'Professional Inventory Management';

  /// Generate a receipt PDF for a sale
  static Future<Uint8List> generateReceipt({
    required Sale sale,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    required String businessTIN,
    String? receiptNumber,
  }) async {
    final pdf = pw.Document();

    // Generate receipt number if not provided
    final String finalReceiptNumber = receiptNumber ??
        'RCP${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(
                  businessName, businessAddress, businessPhone, businessTIN),

              pw.SizedBox(height: 20),

              // Receipt Title and Number
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'No. $finalReceiptNumber',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Customer and Date Info
              _buildCustomerInfo(sale),

              pw.SizedBox(height: 20),

              // Items Table
              _buildItemsTable(sale),

              pw.SizedBox(height: 20),

              // Total Section
              _buildTotalSection(sale),

              pw.SizedBox(height: 30),

              // Footer
              _buildFooter(),

              // Spacer to push signature to bottom
              pw.Spacer(),

              // Signature Section
              _buildSignatureSection(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
      String businessName, String address, String phone, String tin) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          businessName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          address,
          style: const pw.TextStyle(fontSize: 12),
          textAlign: pw.TextAlign.center,
        ),
        if (phone.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            'Phone: $phone',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        if (tin.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            'TIN: $tin',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(Sale sale) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Customer: ${sale.customerName}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (sale.customerPhone?.isNotEmpty == true) ...[
              pw.SizedBox(height: 3),
              pw.Text(
                'Phone: ${sale.customerPhone}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Date: ${DateFormat('dd/MM/yyyy').format(sale.saleDate)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Time: ${DateFormat('HH:mm').format(sale.saleDate)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Sale sale) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // Qty
        1: const pw.FlexColumnWidth(4), // Particulars
        2: const pw.FlexColumnWidth(2), // Unit Price
        3: const pw.FlexColumnWidth(2), // Total
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Particulars', isHeader: true),
            _buildTableCell('Unit Price', isHeader: true),
            _buildTableCell('Total', isHeader: true),
          ],
        ),
        // Data Row
        pw.TableRow(
          children: [
            _buildTableCell(sale.quantity.toString()),
            _buildTableCell(sale.productName),
            _buildTableCell('${sale.unitPrice.toStringAsFixed(0)}/-'),
            _buildTableCell('${sale.totalPrice.toStringAsFixed(0)}/-'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildTotalSection(Sale sale) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2),
              ),
              child: pw.Text(
                'TOTAL: ${sale.totalPrice.toStringAsFixed(0)}/-',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'THANK YOU FOR YOUR BUSINESS!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Powered by $_companyName - $_tagline',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Customer Signature:',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              width: 150,
              height: 1,
              color: PdfColors.black,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Authorized Signature:',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              width: 150,
              height: 1,
              color: PdfColors.black,
            ),
          ],
        ),
      ],
    );
  }

  /// Download receipt (for web and mobile)
  static Future<void> downloadReceipt({
    required Sale sale,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    required String businessTIN,
    String? receiptNumber,
  }) async {
    final pdfData = await generateReceipt(
      sale: sale,
      businessName: businessName,
      businessAddress: businessAddress,
      businessPhone: businessPhone,
      businessTIN: businessTIN,
      receiptNumber: receiptNumber,
    );

    final String fileName =
        'receipt_${sale.id.substring(0, 8)}_${DateFormat('yyyyMMdd').format(sale.saleDate)}.pdf';

    if (kIsWeb) {
      // Web download using universal approach
      await _downloadWebFile(pdfData, fileName);
    } else {
      // Mobile/Desktop download
      await _downloadDesktopFile(pdfData, fileName);
    }
  }

  /// Download file on web platform
  static Future<void> _downloadWebFile(Uint8List data, String fileName) async {
    if (kIsWeb) {
      // Use the printing package's web support for downloads
      await Printing.sharePdf(bytes: data, filename: fileName);
    }
  }

  /// Download file on desktop/mobile platforms
  static Future<void> _downloadDesktopFile(
      Uint8List data, String fileName) async {
    if (!kIsWeb) {
      // Use the printing package's native support
      await Printing.sharePdf(bytes: data, filename: fileName);
    }
  }

  /// Get formatted receipt number
  static String generateReceiptNumber() {
    final now = DateTime.now();
    return 'RCP${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }
}

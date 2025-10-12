import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../services/DatabaseService.dart';

class ReportService {
  Future<pw.Document> generateSalesReport(
      DateTime startDate, DateTime endDate) async {
    final pdf = pw.Document();

    // Get sales data
    final sales =
        await DatabaseService.instance.getSalesByDateRange(startDate, endDate);
    final totalSales = await DatabaseService.instance
            .getTotalSalesForPeriod(startDate, endDate) ??
        0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                children: [
                  pw.Text(
                    'InventoryMaster',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('Electronics Shop Sales Report'),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(),
                ],
              ),
            ),
            // Sales Table
            pw.Table.fromTextArray(
              headers: [
                'Product Name',
                'Quantity',
                'Unit Price (TSH)',
                'Total Price (TSH)',
                'Customer Name',
                'Sale Date',
              ],
              data: sales
                  .map((sale) => [
                        sale.productName,
                        sale.quantity.toString(),
                        'TSH ${sale.unitPrice.toStringAsFixed(2)}',
                        'TSH ${sale.totalPrice.toStringAsFixed(2)}',
                        sale.customerName,
                        DateFormat('MMM dd, yyyy').format(sale.saleDate),
                      ])
                  .toList(),
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
            ),
            pw.SizedBox(height: 20),
            // Summary
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total Sales: TSH ${totalSales.toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }
}


import 'package:flutter/material.dart';
import '../services/report_service.dart';

class CustomReportScreen extends StatefulWidget {
  const CustomReportScreen({super.key});

  @override
  _CustomReportScreenState createState() => _CustomReportScreenState();
}

class _CustomReportScreenState extends State<CustomReportScreen> {
  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  final DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  _generateCustomReport() async {
    setState(() => _isLoading = true);
    try {
      final reportService = ReportService();
      await reportService.generateSalesReport(_startDate, _endDate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom report generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Report')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _generateCustomReport,
                child: const Text('Generate Custom Report'),
              ),
      ),
    );
  }
}
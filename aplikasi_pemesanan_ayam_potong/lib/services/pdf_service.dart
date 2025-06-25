// lib/services/pdf_service.dart

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:appwrite/models.dart' as models;
import 'database_service.dart';

class PdfService {
  final DatabaseService databaseService;
  PdfService({required this.databaseService});

  // --- FUNGSI UNTUK INVOICE TUNGGAL (TIDAK BERUBAH) ---
  Future<void> createSingleOrderPdf({
    required models.Document order,
    required List<models.Document> orderItems,
    required String customerName,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInvoiceHeader(order, customerName),
              pw.SizedBox(height: 20),
              _buildInvoiceItemsTable(orderItems),
              pw.Divider(),
              _buildInvoiceTotal(order.data),
              pw.SizedBox(height: 40),
              _buildInvoiceFooter(),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // --- FUNGSI LAPORAN RIWAYAT PESANAN (DIPERBARUI TOTAL) ---
  Future<void> createOrderHistoryPdf({
    required List<models.Document> orders,
    required String reportTitle,
    required String generatedBy,
  }) async {
    final pdf = pw.Document();

    final Map<String, List<models.Document>> orderItemsMap = {};
    for (var order in orders) {
      final items = await databaseService.getOrderItems(order.$id);
      orderItemsMap[order.$id] = items;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // Mode landscape
        header: (context) => _buildReportHeader(reportTitle, generatedBy),
        footer: (context) => _buildReportFooter(context),
        build: (pw.Context context) {
          return [
            _buildConsolidatedOrderTable(orders, orderItemsMap),
          ];
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // --- WIDGET PEMBANTU ---

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // WIDGET BARU UNTUK TABEL GABUNGAN
  pw.Widget _buildConsolidatedOrderTable(
    List<models.Document> orders,
    Map<String, List<models.Document>> orderItemsMap,
  ) {
    final headers = ['Tanggal', 'Order ID', 'Status', 'Item Produk', 'Qty', 'Potong', 'Subtotal'];
    
    final List<List<String>> allRows = [];

    for (var order in orders) {
      final orderData = order.data;
      final items = orderItemsMap[order.$id] ?? [];
      final orderDate = _formatDate(order.$createdAt);
      final orderId = '#${order.$id.substring(0, 8)}';
      final status = orderData['status']?.toUpperCase() ?? 'N/A';

      if (items.isNotEmpty) {
        for (var i = 0; i < items.length; i++) {
          final itemData = items[i].data;
          allRows.add([
            i == 0 ? orderDate : '', // Tampilkan hanya di baris pertama
            i == 0 ? orderId : '', // Tampilkan hanya di baris pertama
            i == 0 ? status : '', // Tampilkan hanya di baris pertama
            itemData['name'] ?? 'N/A',
            itemData['quantity'].toString(),
            itemData['pieces']?.toString() ?? '-',
            'Rp ${(itemData['priceAtOrder'] * itemData['quantity']).toStringAsFixed(0)}',
          ]);
        }
      } else {
        // Jika pesanan tidak memiliki item
        allRows.add([
          orderDate, orderId, status, '(Tidak ada item detail)', '', '', ''
        ]);
      }
      // Tambahkan baris total untuk setiap pesanan
      allRows.add(['', '', '', '', '', 'TOTAL', 'Rp ${orderData['totalPrice']?.toStringAsFixed(0) ?? '0'}']);
    }

    return pw.Table.fromTextArray(
      headers: headers,
      data: allRows,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      cellPadding: const pw.EdgeInsets.all(5),
      cellStyle: const pw.TextStyle(fontSize: 9),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(2.5),
        3: const pw.FlexColumnWidth(4),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.5),
        6: const pw.FlexColumnWidth(3),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.center,
        3: pw.Alignment.centerLeft, 4: pw.Alignment.center, 5: pw.Alignment.center,
        6: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildInvoiceItemsTable(List<models.Document> items) {
    final headers = ['No', 'Produk', 'Potong', 'Qty', 'Harga', 'Subtotal'];
    final data = items.asMap().entries.map((entry) {
      int index = entry.key;
      var itemData = entry.value.data;
      return [
        (index + 1).toString(),
        itemData['name'] ?? 'N/A',
        itemData['pieces']?.toString() ?? '-',
        '${itemData['quantity']}x',
        'Rp ${itemData['priceAtOrder']?.toStringAsFixed(0) ?? '0'}',
        'Rp ${(itemData['priceAtOrder'] * itemData['quantity']).toStringAsFixed(0)}',
      ];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers, data: data, border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      cellAlignment: pw.Alignment.centerLeft, cellPadding: const pw.EdgeInsets.all(8)
    );
  }

  pw.Widget _buildInvoiceHeader(models.Document order, String customerName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('INVOICE / FAKTUR PESANAN', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Nama Pelanggan: $customerName'),
              pw.Text('Tanggal Pesan: ${_formatDate(order.$createdAt)}'),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Order ID: #${order.$id.substring(0, 8)}'),
              pw.Text('Status: ${order.data['status']?.toUpperCase() ?? 'N/A'}'),
            ]),
          ],
        ),
        pw.Divider(height: 20),
      ],
    );
  }

  pw.Widget _buildInvoiceTotal(Map<String, dynamic> orderData) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Catatan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(orderData['description'] != null && orderData['description'].isNotEmpty ? orderData['description'] : '-'),
          ]),
        ),
        pw.SizedBox(width: 20),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Divider(),
          pw.Text('Total Bayar: Rp ${orderData['totalPrice']?.toStringAsFixed(0) ?? '0'}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ]),
      ],
    );
  }

  pw.Widget _buildInvoiceFooter() {
    return pw.Center(child: pw.Text('Terima kasih telah berbelanja!', style: pw.TextStyle(font: pw.Font.helveticaOblique())));
  }

  pw.Widget _buildReportHeader(String title, String user) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('Dibuat oleh: $user pada ${_formatDate(DateTime.now().toIso8601String())}'),
          pw.Divider(height: 10),
        ],
      ),
    );
  }

  pw.Widget _buildReportFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text('Halaman ${context.pageNumber} dari ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.grey)),
    );
  }

  pw.Widget _buildSingleOrderEntry(models.Document order, List<models.Document> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Order ID: #${order.$id.substring(0, 8)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(_formatDate(order.$createdAt)),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Status: ${order.data['status']?.toUpperCase() ?? 'N/A'}'),
          pw.Text('Total: Rp ${order.data['totalPrice']?.toStringAsFixed(0) ?? '0'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 10),
        pw.Text('Detail Item:', style: pw.TextStyle(font: pw.Font.helveticaBoldOblique())),
        _buildInvoiceItemsTable(items),
      ],
    );
  }
}
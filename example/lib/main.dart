import 'package:flutter/material.dart';
import 'package:max_print_dialog/max_print_dialog.dart';
import 'package:thermal_printer/esc_pos_utils_platform/esc_pos_utils_platform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var countryCode = 'ID';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
                onPressed: () {
                  _printReceiveTest();
                },
                child: Text('Click me')),
          ),
        ));
  }

  Future _printReceiveTest() async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'XP-N160I');

    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('MM TOYS',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text('Cikijing, Talaga, Bantarujeg, Rancah',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.row([
      PosColumn(
          width: 6,
          text: 'PENJUALAN :',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 6,
          text: '2024-03-14',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);

    bytes += generator.row([
      PosColumn(
          width: 8,
          text: 'PELANGGAN : UMUM-RCH',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 4,
          text: '15:30',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);

    bytes += generator.text('--------------------------------',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: 'Qty',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 6,
          text: 'Nama Produk',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
    ]);

    bytes += generator.row([
      PosColumn(
          width: 3,
          text: 'Harga',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
      PosColumn(
          width: 3,
          text: 'Dis.',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
      PosColumn(
          width: 3,
          text: 'PPn',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
      PosColumn(
          width: 3,
          text: 'Netto',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);

    bytes += generator.text('--------------------------------',
        styles: const PosStyles(align: PosAlign.center));

    // Dummy transaction data
    List<String> dummyProducts = [
      'Product 1',
      'Product 2',
      'Product 3',
    ];

    for (var productName in dummyProducts) {
      bytes += generator.row([
        PosColumn(
            width: 12,
            text: '2  ${productName.toUpperCase()}',
            styles: const PosStyles(
              align: PosAlign.left,
              codeTable: 'CP1252',
            )),
      ]);

      bytes += generator.row([
        PosColumn(
            width: 3,
            text: '10.0',
            styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
        PosColumn(
            width: 3,
            text: '0.0',
            styles:
                const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
        PosColumn(
            width: 3,
            text: '',
            styles:
                const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
        PosColumn(
            width: 3,
            text: '20.0',
            styles:
                const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
      ]);
    }

    bytes += generator.text('--------------------------------',
        styles: const PosStyles(align: PosAlign.center));

    // Dummy total and payment data
    bytes += generator.row([
      PosColumn(
          width: 4,
          text: 'Jumlah : 3',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 4,
          text: 'Item : 6',
          styles: const PosStyles(align: PosAlign.center, codeTable: 'CP1252')),
      PosColumn(
          width: 4,
          text: '33.0',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);

    // Dummy grand total, payment, change, and cashier data
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: 'Grand Total',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 1,
          text: ':',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 5,
          text: '33.0',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: 'Pembayaran',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 1,
          text: ':',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 5,
          text: '50.0',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: 'Kembalian',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 1,
          text: ':',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 5,
          text: '17.0',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: 'Kasir',
          styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(
          width: 6,
          text: 'Anisa',
          styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);

    bytes += generator.text('--------------------------------',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text(
        'BARANG YANG SUDAH DI BELI TIDAK DAPAT DITUKAR / DIKEMBALIKAN',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('TERIMA KASIH',
        styles: const PosStyles(align: PosAlign.center));

    _showPrintDialog(bytes, generator);
  }

  _showPrintDialog(List<int> bytes, Generator generator) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return PrintDialog(bytes: bytes, generator: generator);
      },
    );
  }
}

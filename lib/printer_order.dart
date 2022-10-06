import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

class PrinterOrder extends StatefulWidget {
  const PrinterOrder(
      {Key? key,
      required this.orderType,
      required this.orderNumber,
      required this.customerName,
      required this.deliveryTime,
      required this.instruction,
      required this.items})
      : super(key: key);
  final String orderType;
  final String orderNumber;
  final String customerName;
  final String deliveryTime;
  final String instruction;
  final List<String> items;
  @override
  State<PrinterOrder> createState() => _PrinterOrderState();
}

class _PrinterOrderState extends State<PrinterOrder> {
  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _devicesMsg = "";
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  void initPrinter() {
    print('init printer');

    _printerManager.startScan(const Duration(seconds: 2));
    _printerManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() => _devices = event);

      if (_devices.isEmpty) {
        setState(() {
          _devicesMsg = 'No devices';
        });
      }
    });
  }

  @override
  void initState() {
    if (Platform.isIOS) {
      initPrinter();
    } else {
      bluetoothManager.state.listen((val) {
        print("state = $val");
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() {
            _devicesMsg = 'Please enable bluetooth to print';
          });
        }
        print('state is $val');
      });
    }
    super.initState();
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final result = await _printerManager.printTicket(await testTicket());
    print(result);
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');

    bytes += generator.text(
      'Bold text',
      styles: const PosStyles(bold: true),
    );
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text(
      'Underlined text',
      styles: const PosStyles(underline: true),
      linesAfter: 1,
    );
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.text(
      'Bold text',
      styles: const PosStyles(
        bold: true,
      ),
    );
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text(
      'Underlined text',
      styles: const PosStyles(underline: true),
      linesAfter: 1,
    );
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    final encodedStr = const Utf8Encoder().convert("تجربة الطباعة العربية");
    bytes += generator.textEncoded(
        Uint8List.fromList([
          ...[0x1C, 0x26, 0x1C, 0x43, 0xFF],
          ...encodedStr,
        ]),
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
          align: PosAlign.center,
          
        ));
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Printer page"),
        ),
        backgroundColor: Colors.white,
        body: ListView.builder(
          itemBuilder: (context, position) {
            log("devices $_devices");
            return ListTile(
              onTap: () {
                _startPrint(_devices[position]);
              },
              leading: const Icon(Icons.print),
              title: Text(_devices[position].name!),
              subtitle: Text(_devices[position].address!),
            );
          },
          itemCount: _devices.length,
        ));
  }
}

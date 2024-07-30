library max_print_dialog;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:thermal_printer/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:thermal_printer/thermal_printer.dart';
import 'my_button.dart';
import 'printer_devices.dart';

class PrintDialog extends StatefulWidget {
  Function()? onSuccess;
  String? title, description;
  Color? btnOkTextColor,
      btnOkBorderColor,
      btnOkColor,
      btnCancelTextColor,
      btnCancelBorderColor,
      btnCancelColor;
  double? btnRadius, btnHeight, btnWidth;
  List<int> bytes;
  Generator generator;
  Function()? onCancelTap;

  PrintDialog(
      {Key? key,
      required this.bytes,
      required this.generator,
      this.onSuccess,
      this.description,
      this.title,
      this.btnOkBorderColor,
      this.btnOkColor,
      this.btnRadius,
      this.btnOkTextColor,
      this.btnCancelBorderColor,
      this.btnCancelColor,
      this.btnCancelTextColor,
      this.btnHeight,
      this.btnWidth,
      this.onCancelTap})
      : super(key: key);

  @override
  _PrintDialogState createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  bool isLoadingButton = false;

  // Thermal
  var defaultPrinterType = PrinterType.bluetooth;
  var _isBle = false;
  var _reconnect = false;
  var _isConnected = false;
  var printerManager = PrinterManager.instance;
  var devices = <PrinterDevices>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  StreamSubscription<TCPStatus>? _subscriptionTCPStatus;
  BTStatus _currentStatus = BTStatus.none;
  // ignore: unused_field
  TCPStatus _currentTCPStatus = TCPStatus.none;
  // _currentUsbStatus is only supports on Android
  // ignore: unused_field
  USBStatus _currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  final String _ipAddress = '';
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  PrinterDevices? selectedPrinter;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionTCPStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: _buildView(context));
  }

  _buildView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            widget.title!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.description!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7588),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          const Text(
            'Daftar perangkat :',
            style: TextStyle(color: Color(0xFF0E0F0F), fontSize: 16.0),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              _chipOption(label: 'BT', val: PrinterType.bluetooth),
              _chipOption(label: 'IP', val: PrinterType.network),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.grey.shade100),
            child: Material(
              color: Colors.transparent,
              child: Column(
                  children: devices
                      .map(
                        (device) => ListTile(
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${device.deviceName}',
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0),
                                ),
                                const SizedBox(
                                  width: 6.0,
                                ),
                                selectedPrinter != null &&
                                        ((device.typePrinter ==
                                                        PrinterType.usb &&
                                                    Platform.isWindows
                                                ? device.deviceName ==
                                                    selectedPrinter!.deviceName
                                                : device.vendorId != null &&
                                                    selectedPrinter!.vendorId ==
                                                        device.vendorId) ||
                                            (device.address != null &&
                                                selectedPrinter!.address ==
                                                    device.address))
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16.0,
                                      )
                                    : const SizedBox()
                              ],
                            ),
                            subtitle: Platform.isAndroid &&
                                    defaultPrinterType == PrinterType.usb
                                ? null
                                : Visibility(
                                    visible: !Platform.isWindows,
                                    child: Text("${device.address}")),
                            onTap: () {
                              // do something
                              selectDevice(device);
                            },
                            trailing: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  onPressed: selectedPrinter == null ||
                                          device.deviceName !=
                                              selectedPrinter?.deviceName
                                      ? null
                                      : () async {
                                          _connectDevice();
                                          await selectedPrinter!.saveToPrefs();
                                        },
                                  icon: Image.asset(
                                    device.deviceName ==
                                            selectedPrinter?.deviceName
                                        ? 'assets/ic_connect_on.png'
                                        : 'assets/ic_connect_off.png',
                                    package: 'max_print_dialog',
                                  )),
                            )),
                      )
                      .toList()),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              Flexible(
                  child: MyButton(
                      width: double.infinity,
                      text: 'Tutup',
                      textColor: widget.btnCancelTextColor,
                      borderColor: widget.btnCancelBorderColor,
                      color: widget.btnCancelColor,
                      press: widget.onCancelTap ??
                          () {
                            Navigator.pop(context);
                          })),
              const SizedBox(
                width: 16.0,
              ),
              Flexible(
                  child: MyButton(
                      width: double.infinity,
                      textColor: widget.btnOkTextColor,
                      borderColor: widget.btnOkBorderColor,
                      color: widget.btnOkColor,
                      text: 'Cetak',
                      press: () {
                        _printReceiveTest();
                      }))
            ],
          )
        ],
      ),
    );
  }

  void _scan() {
    devices.clear();
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      devices.add(PrinterDevices(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      setState(() {});
    });
  }

  _connectDevice() async {
    _isConnected = false;
    if (selectedPrinter == null) return;
    switch (selectedPrinter!.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter!.deviceName,
                productId: selectedPrinter!.productId,
                vendorId: selectedPrinter!.vendorId));
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName,
                address: selectedPrinter!.address!,
                isBle: selectedPrinter!.isBle ?? false,
                autoConnect: _reconnect));
        break;
      case PrinterType.network:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: TcpPrinterInput(ipAddress: selectedPrinter!.address!));
        _isConnected = true;
        break;
      default:
    }

    setState(() {});
  }

  void selectDevice(PrinterDevices device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter!.address) ||
          (device.typePrinter == PrinterType.usb &&
              selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance
            .disconnect(type: selectedPrinter!.typePrinter);
      }
    }

    selectedPrinter = device;
    setState(() {});
  }

  _printReceiveTest() {
    _printEscPos(widget.bytes, widget.generator);
    widget.onSuccess!();
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    var connectedTCP = false;
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter!;
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
                name: bluetoothPrinter.deviceName,
                productId: bluetoothPrinter.productId,
                vendorId: bluetoothPrinter.vendorId));
        pendingTask = null;
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!,
                isBle: bluetoothPrinter.isBle ?? false,
                autoConnect: _reconnect));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        connectedTCP = await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
        if (!connectedTCP) print(' --- please review your connection ---');
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  Future<void> _initialize() async {
    PrinterDevices? printer = await PrinterDevices.getFromPrefs();

    if (printer != null) {
      setState(() {
        selectedPrinter = printer;
      });
    }
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;
      if (status == BTStatus.connected) {
        setState(() {
          _isConnected = true;
        });
      }
      if (status == BTStatus.none) {
        setState(() {
          _isConnected = false;
        });
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      log(' ----------------- status usb $status ------------------ ');
      _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });

    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionTCPStatus = PrinterManager.instance.stateTCP.listen((status) {
      log(' ----------------- status tcp $status ------------------ ');
      _currentTCPStatus = status;
    });
  }

  _chipOption({required String label, required PrinterType val}) {
    return Row(
      children: [
        Radio(
            value: val,
            groupValue: defaultPrinterType,
            onChanged: (v) {
              setState(() {
                defaultPrinterType = v!;
                selectedPrinter = null;
                _isBle = false;
                _isConnected = false;
                _scan();
              });
            }),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16.0),
        )
      ],
    );
  }
}

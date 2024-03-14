import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterDevices {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;
  PrinterType typePrinter;
  bool? state;

  PrinterDevices(
      {this.deviceName,
      this.address,
      this.port,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,
      this.isBle = false});

  // Convert class instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'address': address,
      'port': port,
      'vendorId': vendorId,
      'productId': productId,
      'isBle': isBle,
      'typePrinter': typePrinter.toString(),
      'state': state,
    };
  }

  // Convert JSON map to class instance
  PrinterDevices.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        deviceName = json['deviceName'],
        address = json['address'],
        port = json['port'],
        vendorId = json['vendorId'],
        productId = json['productId'],
        isBle = json['isBle'],
        typePrinter = PrinterType.values
            .firstWhere((e) => e.toString() == json['typePrinter']),
        state = json['state'];

  // Save the class instance to SharedPreferences
  Future<void> saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('PrinterDevices', jsonEncode(toJson()));
  }

  // Retrieve the class instance from SharedPreferences
  static Future<PrinterDevices?> getFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('PrinterDevices');
    if (jsonString != null) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return PrinterDevices.fromJson(json);
    }
    return null;
  }
}

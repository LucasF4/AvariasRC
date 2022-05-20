import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class ButtonScanner extends StatefulWidget {
  final Function function;
  final bool permitScan;

  ButtonScanner({Key key, this.function, this.permitScan}) : super(key: key);

  @override
  _ButtonScannerState createState() => _ButtonScannerState();
}

class _ButtonScannerState extends State<ButtonScanner> {
  static const MethodChannel methodChannel =
      MethodChannel('br.com.gruporcarvalho.avarias/command');
  static const EventChannel scanChannel =
      EventChannel('br.com.gruporcarvalho.avarias/scan');

  //Incrementado a cada bipagem, criado para impedir a abertura de multiplas telas na pilha
  int _openInstances = 0;

  //  This example implementation is based on the sample implementation at
  //  https://github.com/flutter/flutter/blob/master/examples/platform_channel/lib/main.dart
  //  That sample implementation also includes how to return data from the method
  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = "{\"command\":$command,\"parameter\":$parameter}";
      await methodChannel.invokeMethod(
          'sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      //  Error invoking Android method
      print("ERRO!!!!!!");
    }
  }

  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      //  Error invoking Android method
      print('Erro no createProfile');
    }
  }

  String _barcodeString = "Barcode will be shown here";
  String _barcodeSymbology = "Symbology will be shown here";
  String _scanTime = "Scan Time will be shown here";

  @override
  void initState() {
    super.initState();
    try {
      scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      statusScan();
    } catch (e) {
      print('Erro de excessão ${e}');
    }
    _createProfile("DataWedgeFlutterDemo");
  }

  void _onEvent(Object event) {
    Map barcodeScan = jsonDecode(event);
    if (widget.permitScan) {
      widget.function(context, barcodeScan['scanData']);
    }
    print('Instancias abertas ${widget.permitScan}');
  }

  void _onError(Object error) {
    setState(() {
      _barcodeString = "Barcode: error";
      _barcodeSymbology = "Symbology: error";
      _scanTime = "At: error";
    });
    _openInstances = 0;
    print('Erro no sacanner');
  }

  void startScan() {
    Vibration.vibrate(duration: 300);
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
      //https://techdocs.zebra.com/datawedge/6-6/guide/api/softscantrigger/
    });
  }

  void stopScan() {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
    });
  }

  void statusScan() {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STATUS");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When the child is tapped, show a snackbar.
      onTapDown: (TapDownDetails) {
        startScan();
      },
      onTapUp: (TapUpDetails) {
        stopScan();
      },
      // The custom button
      child: FloatingActionButton(
        child: Image.asset(
          'assets/images/barcode.png',
          width: 30,
        ), //Icon(Icons.camera),
        backgroundColor: Colors.orange,
        onPressed: () {},
      ),
    );
  }
}

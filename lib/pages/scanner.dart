import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:avarias/models/presale_helper.dart';

class Scanner extends StatefulWidget {
  final Function function;
  final bool permitScan;
  Scanner({Key key, this.function, this.permitScan}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _camState = false;
  bool _erroScanner = false;
  int qtdeScans = 0;

  PresaleHelper helper = PresaleHelper();
  Product product = Product();

  _qrCallback(BuildContext context, String code) async {
    product.barCode = code;

    setState(() {
      _camState = true;
    });

    if (widget.permitScan && qtdeScans == 0) {
      bool result = await widget.function(context, code);
      qtdeScans++;
      if (result) {
        Navigator.pop(context, result);
      }
    }
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  _closeScan() {
    setState(() {
      _camState = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarWidth = MediaQuery.of(context).padding.top;

    return Scaffold(
        body: !_erroScanner
            ? ModalProgressHUD(
                inAsyncCall: !_camState,
                color: Colors.white,
                opacity: 1,
                //progressIndicator: Text('Processando...'),
                child: SizedBox(
                  height: screenHeight,
                  width: screenWidth,
                  child: QRBarScannerCamera(
                    fit: BoxFit.cover,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        overflow: Overflow
                            .visible, //Permite o uso do widget position dentro do stack
                        children: <Widget>[
                          Positioned(
                              width: screenWidth,
                              height: statusBarWidth + 60,
                              child: Opacity(
                                opacity: 0.6,
                                child: Container(
                                  //color: Colors.white,
                                  height: 70,
                                  color: Colors.grey[900],
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: statusBarWidth + 5),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    onError: (context, error) {
                      setState(() {
                        _erroScanner = true;
                        _camState = true;
                      });
                    },
                    qrCodeCallback: (code) {
                      _qrCallback(context, code);
                    },
                  ),
                ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Camera Desativada',
                      style: TextStyle(fontSize: 20),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FlatButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Ativar Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _camState = true;
                            });
                          },
                        ),
                        FlatButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Voltar para home',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ));
  }
}

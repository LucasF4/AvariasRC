import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Keyboard extends StatelessWidget {
  TextEditingController _eanCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          "Digite o EAN do produto",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, null);
            _eanCode.clear();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight / 3,
            child: Center(
                child: TextFormField(
              controller: _eanCode,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              decoration: InputDecoration(
                labelText: null,
                hintText: null,
                border: null,
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[50]),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[50]),
                ),
              ),
              onFieldSubmitted: (ean) {
                Navigator.pop(context, ean);
                _eanCode.clear();
              },
            )),
          ),
        ],
      ),
    );
  }
}

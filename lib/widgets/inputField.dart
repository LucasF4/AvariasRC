import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  TextEditingController controller;
  String label;
  String hintText;
  bool obscure; // Se true, substitui cada caracter digitado por um .
  TextInputType typeInput;
  int maxInputLength = 1000;
  bool stateField = true;
  Function onChange = null;
  Function validator = null;
  Function onFieldSubmitted = (){};
  Color colorInput;
  bool noDecoration = false;
  List<TextInputFormatter> formats = [];

  InputField(
      {Key key, this.controller, this.label, this.typeInput, this.obscure, this.hintText, this.maxInputLength, this.stateField, this.onChange, this.formats, this.validator, this.onFieldSubmitted, this.colorInput, this.noDecoration})
      : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChange,
      controller: widget.controller,
      keyboardType: widget.typeInput,
      obscureText: widget.obscure,
      maxLength: widget.maxInputLength,
      enabled: widget.stateField,
      inputFormatters: widget.formats,
      onFieldSubmitted: widget.onFieldSubmitted,
      cursorColor: widget.colorInput != null ? widget.colorInput : Theme.of(context).primaryColorDark,
      style: TextStyle(color: widget.colorInput != null ? widget.colorInput : Theme.of(context).primaryColorDark ),
      buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
      decoration: InputDecoration(
        labelText: widget.label != null ? widget.label : '',
        hintText: widget.hintText != null ? widget.hintText : '',
        border: OutlineInputBorder(),
        labelStyle: TextStyle(
          color: widget.noDecoration != null && widget.noDecoration == true ? Theme.of(context).primaryColorDark: widget.colorInput != null ? widget.colorInput : Theme.of(context).primaryColorDark,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.noDecoration != null && widget.noDecoration == true ? Colors.white : widget.colorInput != null ? widget.colorInput : Theme.of(context).primaryColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.noDecoration != null && widget.noDecoration == true ? Colors.white : widget.colorInput != null ? widget.colorInput : Theme.of(context).primaryColorDark),
        ),
      ),
      validator: widget.validator,
    );
  }
}

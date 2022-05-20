import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  String title;
  String hintText;
  List<dynamic> data;
  Function validator = null;
  Function onChange = null;
  String value = '';
  DropdownField(
      {Key key,
      this.title,
      this.hintText,
      this.data,
      this.validator,
      this.onChange,
      this.value})
      : super(key: key);

  @override
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(Radius.circular(4.0)),
      ),
      child: DropDownFormField(
        titleText: widget.title,
        hintText: widget.hintText,
        value: widget.value,
        validator: widget.validator,
        onChanged: widget.onChange,
        dataSource: widget.data,
        textField: 'display',
        valueField: 'value',
      ),
    );
  }
}

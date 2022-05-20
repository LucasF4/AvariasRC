import 'package:flutter/material.dart';
import 'package:avarias/models/customPopupMenu.dart';

class SelectedOption extends StatelessWidget {
  CustomPopupMenu choice;
  SelectedOption({Key key, this.choice}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(choice.icon, size: 140.0, color: Colors.white),
            Text(
              choice.title,
              style: TextStyle(color: Colors.white, fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}

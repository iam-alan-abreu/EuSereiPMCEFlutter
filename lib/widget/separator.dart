import 'package:flutter/material.dart';
import '../utils/appsettings.dart';
class Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
        height: 2.0,
        width: 18.0,
        color: new Color(int.parse(AppSettings.primaryColor))
    );
  }
}
import 'package:flutter/material.dart';

class Principal extends StatelessWidget {
  const Principal({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Pagina Principal"),
        ),
        body: new Column(children: <Widget>[
          new Text("estamos en Beneficiarios"),
        ]));
  }
}

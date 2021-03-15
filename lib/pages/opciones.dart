import 'package:flutter/material.dart';

class Opciones extends StatefulWidget {
  //Opciones({Key key}) : super(key: key);

  @override
  _OpcionesState createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
  /*ListView listView = new ListView(
    children: <Widget>[
      new ListTile(
        leading: new Icon(Icons.settings),
        title: new Text("Configuracion"),
      ),
      /*new ListTile(
          leading: new Icon(Icons.backspace),
          title: new Text("Borrar Beneficiario"),
          onTap: () {
            setState(() {
              Navigator.of(context).pushNamed("/Login");
            });
          }),*/
    ]);
    
    return new Drawer(
      child: listView,
    );*/

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        /*drawer: new Drawer(
        child: listView,
      ),*/
        );
  }
}

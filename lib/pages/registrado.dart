import 'package:aevivienda/models/projectsDoc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aevivienda/db/baseDatos.dart';
import 'package:aevivienda/models/photo1.dart';
import 'package:aevivienda/util/utility.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io' as io;

import 'package:aevivienda/util/loadDialogo.dart';

BaseDatos _db = BaseDatos();
List<ProjectsDoc> _proyectoDoc = [];
ProjectsDoc _proyecto = new ProjectsDoc();
int _registroId;
enum DialogAction { yes, no }

class Registrado extends StatefulWidget {
  Registrado({Key key}) : super(key: key);

  @override
  _RegistradoState createState() => _RegistradoState();
}

class _RegistradoState extends State<Registrado> {
  bool _loading = false;
  bool _enabled = false;
  LoadDialogo progresoDialog;

  Future<ProjectsDoc> buscarProyecto() async {
    _proyectoDoc = await _db.getProyectoDocs();
    _proyecto = _proyectoDoc[0];
    _registroId = _proyecto.registroId;
    //_verificarDatos();
    //_foto1 = await _db.getFotoGps(_registroId);
    //print("entro a ver lat1=" + _foto1.lat.toString());
    return _proyecto;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    List<ProjectsDoc> projDoc = [];
  }

  @override
  Widget build(BuildContext context) {
    progresoDialog = new LoadDialogo(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("PERSONA POSTULANTE"),
        centerTitle: true,
      ),
      // drawer: new Drawer(),
      body: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FutureBuilder<ProjectsDoc>(
                future: buscarProyecto(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Card(
                      child: new ListTile(
                        title: new Text(
                          snapshot.data.nombrePersona,
                          style: TextStyle(
                              fontSize: 25.0, color: Colors.orangeAccent),
                        ),
                        leading: new Icon(
                          Icons.person_pin,
                          size: 77.0,
                          color: Colors.orangeAccent,
                        ),
                        subtitle: new Text(
                          snapshot.data.codigoProj +
                              "\n" +
                              snapshot.data.nombreProj,
                          style: TextStyle(fontSize: 20.0, color: Colors.black),
                        ),
                      ),
                    );
                  } else {
                    return Text('Error ${snapshot.error}');
                  }
                }),
            new Text(""),
            new Text(
              "La Información ya ha sido confirmada \n por la Agencia Estatal de Vivienda.",
              style: TextStyle(fontSize: 21.0, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

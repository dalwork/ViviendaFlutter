import 'dart:io';

import 'package:aevivienda/models/projectsDoc.dart';
import 'package:flutter/material.dart';
import 'package:aevivienda/pages/beneficiario.dart';
import 'package:aevivienda/pages/opciones.dart';
import 'package:aevivienda/pages/registrado.dart';
import 'package:aevivienda/models/proyectos.dart';
import 'package:http/http.dart' as http;
import 'package:aevivienda/db/baseDatos.dart';
import 'package:aevivienda/models/photo1.dart';
import 'package:aevivienda/util/loadDialogo.dart';
//import 'package:aevivienda/pages/loader.dart';
//import 'package:progress_dialog/progress_dialog.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:ui';

//import 'dart:developer' as developer;

void main() => runApp(LoginApp());

String ci;
String ruta = "";

class LoginApp extends StatelessWidget {
  //const LoginApp({Key key}) : super//(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Ministerio de Vivienda",
        home: Login(),
        routes: <String, WidgetBuilder>{
          '/Login': (BuildContext context) => Login(),
          '/beneficiario': (BuildContext context) => new Beneficiario(),
          '/registrado': (BuildContext context) => new Registrado(),
          '/opciones': (BuildContext context) => new Opciones(),
        });
  }
}

class Login extends StatefulWidget {
  //Login({Key key}) : super(key: key);
  //@override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  BaseDatos _db = BaseDatos();
  List<ProjectsDoc> _proyectoDoc = [];
  Photo1 _foto1 = new Photo1();
  LoadDialogo progresoDialog;
  int _registroId;
  int _ai;
  //ProjectsDoc proyecto
  //ProgressDialog progressDialog;

  TextEditingController editCi = new TextEditingController();
  TextEditingController editExp = new TextEditingController();

  String mensaje = "";
  bool tiene = false;

  Proyectos proyecto = new Proyectos();

  Future<List<ProjectsDoc>> buscarProyecto() async {
    print("aqui 2");
    _proyectoDoc = await _db.getProyectoDocs();
    print("aqui 2.1");
    _ai = await _registrado(_proyectoDoc[0].registroId);
    print("aqui 3");
    _foto1 = await _db.getPhoto(_proyectoDoc[0].registroId);
    print("aqui 4");
    return _proyectoDoc;
  }

  Future<String> getDatosProyecto() async {
    progresoDialog.mostrar();
    Photo1 _foto = new Photo1();
    //String ruta = "";
    /* esto es para post
      final respuesta = await http.post("http://192.168.1.242/paola/login.php",
        body: {"ci": editCi.text, "exp": editExp.text});*/
    //* _proyectoDoc = await _db.getProyectoDocs();
    //String respuesta = "";
    String url = "http://siges.aevivienda.gob.bo/rub/rub/main/beneficiario/" +
        editCi.text;
    final respuesta = await http.get(url);
    String body =
        utf8.decode(respuesta.bodyBytes); //reconozca los caracteres especiales
    //String body = respuesta.body
    if (body.substring(0, 1) == 'D') {
      setState(() {
        mensaje = "Postulante no se encuentra";
        editCi.text = "";
        //ruta = "/Login";
      });
      progresoDialog.ocultar();
    } else {
      proyecto = Proyectos.fromJson(json.decode(body));
      try {
        _foto.ai = 0;
        _foto.registerId = proyecto.projectsDoc[0].registroId;
        _registroId = proyecto.projectsDoc[0].registroId;
        _foto.family = "";
        _foto.home = "";
        _foto.lat = "";
        _foto.lng = "";
        _foto = await _db.insertFoto(_foto);
        _proyectoDoc[0] = await _db.insertProyectoDoc(proyecto.projectsDoc[0]);
      } catch (e) {
        print(e);
      }
      setState(() {
        mensaje = "Beneficiario se encuentra";
      });
      int _reg1 = await _registrado(_registroId);
      _foto.ai = _reg1;
      progresoDialog.ocultar();
      if (_reg1 == 0) Navigator.pushReplacementNamed(context, "/beneficiario");
      if (_reg1 == 1) Navigator.pushReplacementNamed(context, "/registrado");
    }
    return mensaje;
  }

  Future<int> _registrado(int registroId) async {
    Photo1 _foto = new Photo1();
    _foto.registerId = registroId;
    String url1 =
        "http://siges.aevivienda.gob.bo/rub/rub/main/beneficiarioapp/" +
            registroId.toString();
    print("url1=" + url1);
    try {
      final respuesta1 = await http.get(url1);
      String body1 = utf8.decode(respuesta1.bodyBytes);
      print(body1);
      if (body1.substring(0, 1) == '0') {
        _ai = 0;
        _foto.ai = 0;
        _db.updateRegistrado(_foto);
        return 0;
      }
      if (body1.substring(0, 1) == '1') {
        _ai = 1;
        _foto.ai = 1;
        _db.updateRegistrado(_foto);
        return 1;
      }
    } on TimeoutException catch (e) {
      print('timeout ****************Timeout Error: $e');
      return 0;
    } on SocketException catch (e) {
      print('SocketException ****************Timeout Error: $e');
      return 0;
    } on Error catch (e) {
      print('general ****************General Error: $e');
      return 0;
    }
  }

  @override
  initState() {
    super.initState();
    List<ProjectsDoc> projDoc = [];
    print("aqui 1");
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      print("aqui 5");
      projDoc = await buscarProyecto();
      //_ai = await _registrado(_foto1.registerId);
      if (projDoc.length > 0) {
        if (_foto1.ai == 0)
          Navigator.pushReplacementNamed(context, '/beneficiario');
        if (_foto1.ai == 1)
          Navigator.pushReplacementNamed(context, '/registrado');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    progresoDialog = new LoadDialogo(context);
    // , ProgressDialogType.Normal);
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Form(
        child: new Container(
          //height: 10.0,
          //padding: EdgeInsets.only(top: 50.0),
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/images/fotocasa.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: new Column(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(top: 80.0),
                //width: 150.0,
                //height: 150.0,
                child: new CircleAvatar(
                  //backgroundColor: new Color(0xF81F7F3),
                  backgroundColor: Colors.greenAccent,
                  child: new Icon(
                    Icons.account_circle,
                    color: Colors.black,
                  ),
                  /*child: new Image(
                    width: 300.0,
                    height: 300.0,
                    image: new AssetImage("assets/images/cheque.jpg"),
                    icon: Icon(
                            Icons.vpn_key,
                            color: Colors.black,
                          ),
                  ),*/
                ),
                //decoration: BoxDecoration(
                //  shape: BoxShape.circle,
                //),
              ),
              new Container(
                //height: MediaQuery.of(context).size.height,
                //width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 93),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 50,
                      margin: EdgeInsets.only(
                        top: 32,
                      ),
                      padding: EdgeInsets.only(
                          top: 5, left: 16, right: 16, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: TextFormField(
                        controller: editCi,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.vpn_key,
                            color: Colors.black,
                          ),
                          hintText: "C.I. Postulante",
                        ),
                      ),
                    ),
                    //Spacer(),
                    new Align(
                      alignment: Alignment.centerRight,
                      child: new Padding(
                        padding: EdgeInsets.only(top: 6, right: 32),
                        child: new Text(
                          "Recordar C.I.",
                          style: TextStyle(
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ),
                    /*FutureBuilder<String>(
                        future: getDatosProyecto(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {}
                        }),*/
                    new RaisedButton(
                      child: new Text("Ingresar"),
                      color: Colors.greenAccent,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        if (editCi.text.isNotEmpty) getDatosProyecto();
                      },
                    ),
                    new Text(
                      mensaje,
                      style:
                          new TextStyle(fontSize: 25.0, color: Colors.white10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
////////////////////////////////////////
void main() {
  runApp(new MaterialApp(
    
  ));
}

*/

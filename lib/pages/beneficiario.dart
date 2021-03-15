import 'package:aevivienda/models/projectsDoc.dart';
import 'package:flutter/material.dart';
//import 'package:path/path.dart';
import 'package:aevivienda/models/proyectos.dart';
import 'package:http/http.dart' as http;
import 'package:aevivienda/pages/principal.dart';
import 'package:aevivienda/pages/registrado.dart';
import 'package:aevivienda/db/baseDatos.dart';
import 'package:aevivienda/models/photo1.dart';
import 'package:aevivienda/util/utility.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'dart:io' as io;

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:aevivienda/pages/getLocationPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:aevivienda/util/loadDialogo.dart';
//import 'package:aevivienda/pages/loader.dart';
//import 'package:permission_handler/permission_handler.dart';

BaseDatos _db = BaseDatos();
List<ProjectsDoc> _proyectoDoc = [];
ProjectsDoc _proyecto = new ProjectsDoc();
Photo1 _foto1 = new Photo1();
int _registroId;
//Future<File> imageFile;
io.File familiaFile;
io.File viviendaFile;
String familiaString;
String viviendaString;
String gpsString;
Image imagen;
Image imagen1;
Position _position;
List<Photo1> imagenes;
Geolocator _geolocator;

enum DialogAction { yes, no }

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: <String, WidgetBuilder>{
      '/': (context) => Beneficiario(),
      '/registrado': (context) => new Registrado(),
    },
  ));
}

class Beneficiario extends StatefulWidget {
  Beneficiario({Key key}) : super(key: key);

  @override
  _BeneficiarioState createState() => _BeneficiarioState();
}

class _BeneficiarioState extends State<Beneficiario> {
  bool _loading = false;
  bool _enabled = false;
  LoadDialogo progresoDialog;

  Future<bool> _verificarDatos() async {
    List<Photo1> fotos = [];
    fotos = await _db.getPhotos();
    if (fotos.length > 0) if ((fotos[0].family != "") &&
        (fotos[0].home != "") &&
        (fotos[0].lat != "") &&
        (fotos[0].lng != ""))
      setState(() {
        _enabled = true;
      });
    else
      setState(() {
        _enabled = false;
      });
    return _enabled;
  }

  Future<ProjectsDoc> buscarProyecto() async {
    _proyectoDoc = await _db.getProyectoDocs();
    _proyecto = _proyectoDoc[0];
    _registroId = _proyecto.registroId;
    //_verificarDatos();
    //_foto1 = await _db.getFotoGps(_registroId);
    //print("entro a ver lat1=" + _foto1.lat.toString());
    return _proyecto;
  }

  /*Future<void> permisoLlenado() async {

  }*/

  void _resultadoAlerta(String valor) {
    AlertDialog resultado = new AlertDialog(
      content: new Text(valor),
    );
    showDialog(context: context, child: resultado);
  }

  Future<String> _showAccionDialogo(DialogAction action) async {
    String __resultado = "";
    if (action.index == 0) {
      //setState(() {
      //});
      if (_loading) {
        progresoDialog.mostrar();
      }
      Future.delayed(Duration(milliseconds: 100)).then((_) async {
        __resultado = await _subirServidor();
        progresoDialog.ocultar();
        _resultadoAlerta(__resultado);
        if (__resultado == "No se puede actualizar")
          Navigator.pushReplacementNamed(context, "/registrado");
        print("salio por navigator=/registrador");
      });
    }
    return "Tranferencia Completada";
  }

  void _showDialogo() {
    AlertDialog dialogo = new AlertDialog(
      content: new Text("Se enviará los datos al servidor."),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              setState(() {
                _loading = true;
              });
              Future.delayed(Duration(milliseconds: 10)).then((_) async {
                _showAccionDialogo(DialogAction.yes);
              });
              Navigator.pop(context);
            },
            child: new Text("Si")),
        new FlatButton(
            onPressed: () {
              _showAccionDialogo(DialogAction.no);
              Navigator.pop(context);
            },
            child: new Text("No")),
      ],
    );
    showDialog(context: context, child: dialogo);
  }

  void checkPermission() async {
    _geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });
    _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });
    _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationWhenInUse)
        .then((status) {
      print('whenInUse status: $status');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    List<ProjectsDoc> projDoc = [];
    imagenes = [];
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      _verificarDatos();
    });
     
  }

  @override
  Widget build(BuildContext context) {
    progresoDialog = new LoadDialogo(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("PERSONA POSTULANTE"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.cloud_upload,
            ),
            color: Colors.white,
            disabledColor: Colors.blue,
            onPressed: _enabled ? _showDialogo : null,
          ),
        ],
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
            const SizedBox(height: 30,
                            width: 60 ),
            new RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: new Text("Paso (3) Foto Familia",
               style: TextStyle(fontSize: 16),),
              onPressed: _openCamera,
            ),
            FutureBuilder<String>(
                future: _fotoFamiliaBase(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _setImageView();
                  }
                }),
            new RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: new Text("Paso (2) Foto Vivienda",
               style: TextStyle(fontSize: 16),),
              onPressed: _openCamera1,
            ),
            FutureBuilder<String>(
                future: _fotoCasaBase(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _setImageView1();
                  }
                }),
        new RaisedButton(
              textColor: Colors.white,
              color: Colors.orangeAccent,
              child: Text("Paso (1) GPS Vivienda", 
               style: TextStyle(fontSize: 16),),                                                                                                
              onPressed: () {
                _getCurrentLocation();
              },
            ),
            FutureBuilder<String>(
                future: _ubicacionGps(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _setPositionView();
                  }
                }),
          ],
        ),
      ),
    );
  }

  /////////////////////////////
  // FOTO para la familia
  ////////////////////////////
  void _openCamera() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      familiaFile = picture;
    });
    //String path = await getApplicationDocumentsDirectory();
    io.Directory documentoDirectorio = await getApplicationDocumentsDirectory();
    String path = documentoDirectorio.path;
    //String path = join(documentoDirectorio.path, DB_NAME);
    io.File tempLocalFile = io.File('$path/imagenFamilia.jpg');
    if (tempLocalFile.existsSync()) {
      await tempLocalFile.delete(
        recursive: true,
      );
    }
    Future.delayed(Duration(milliseconds: 500)).then((_) async {
      await familiaFile.copy('$path/imagenFamilia.jpg');
    });
    Photo1 fotoFamilia = new Photo1();
    fotoFamilia.family = '$path/imagenFamilia.jpg';
    fotoFamilia.registerId = _registroId;
    _db.updateFotoFamilia(fotoFamilia);
    _verificarDatos();
  }

  Future<String> _fotoFamiliaBase() async {
    familiaString = "";
    familiaString = await _db.getFotoFamilia();
    if (familiaString == null) familiaString = "";
    return familiaString;
  }

  Widget _setImageView() {
    if (familiaFile != null) {
      return new Image.file(familiaFile,
          width: 300, height: 300); //imagen de camara
    } else {
      if (familiaString.length > 0) {
        //print("direccion imagen Familia " + imgString);
        return new Image.file(io.File(familiaString),
            width: 300, height: 300); //recuperado de BD
        //return Utility.imageFromBase64String(imgString);
      } else {
        return new Text("Seleccione una imagen de Familia"); //no tiene imagen
      }
    }
  }

  ///////////////////////////////////
  ///PARA EL DOMICILIO
  //////////////////////////////////
  void _openCamera1() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      viviendaFile = picture;
    });
    io.Directory documentoDirectorio = await getApplicationDocumentsDirectory();
    String path = documentoDirectorio.path;

    io.File tempLocalFile = io.File('$path/imagenCasa.jpg');
    if (tempLocalFile.existsSync()) {
      await tempLocalFile.delete(
        recursive: true,
      );
    }
    Future.delayed(Duration(milliseconds: 500)).then((_) async {
      await viviendaFile.copy('$path/imagenCasa.jpg');
    });

    Photo1 fotoCasa = new Photo1();
    fotoCasa.home = '$path/imagenCasa.jpg';
    fotoCasa.registerId = _registroId;
    _db.updateFotoCasa(fotoCasa);
    _verificarDatos();
  }

  Future<String> _fotoCasaBase() async {
    viviendaString = "";
    viviendaString = await _db.getFotoCasa();
    if (viviendaString == null) viviendaString = "";
    return viviendaString;
  }

  Widget _setImageView1() {
    if (viviendaFile != null) {
      return Image.file(viviendaFile,
          width: 300, height: 300); //imagen de camara
    } else {
      if (viviendaString.length > 0) {
        return Image.file(io.File(viviendaString),
            width: 300, height: 300); //recuperado
      } else {
        return Text("Seleccione una imagen de Vivienda");
      }
    }
  }

  /////////////////////////////////////////////////////
  //CARGAR EL GPS
  //////////////////////////////////////////////////////

  Future<String> _ubicacionGps() async {
    gpsString = "";
    _foto1 = await _db.getFotoGps();
    //Imagen image = null;
    gpsString = " LATITUD: " +
        _foto1.lat.toString() +
        "\n LONGITUD: " +
        _foto1.lng.toString();
    return gpsString;
  }

  Widget _setPositionView() {
    if (_position != null) {
      return Text(" LATITUD: " +
          _position.latitude.toString() +
          "\n LONGITUD: " +
          _position.longitude.toString());
    } else {
      if (gpsString.length > 0) {
        return Text("" + gpsString);
      } else {
        return Text("Seleccione la Ubicación de la Vivienda");
      }
    }
  }

//  ARCHIVO PARA EL GPS
  Future<Position> _getCurrentLocation() async {
    //bool isOpened = await LocationPermissions().openAppSettings();
    //PermissionStatus permission =
    //await LocationPermissions().requestPermissions();
    checkPermission();
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 5));
      setState(() {
        _position = position;
      });
      Photo1 fotoGps = new Photo1();
      //fotoGps = await _db.getPhotos();
      fotoGps.ai = 1;
      fotoGps.lat = _position.latitude.toString();
      fotoGps.lng = _position.longitude.toString();
      fotoGps.registerId = _registroId;
      _db.updateFotoGps(fotoGps);
      _verificarDatos();
    } catch (e) {
      _position = null;
    }
    return _position;
  }

  /* void _openGallery() {
    var picture = ImagePicker.pickImage(source: ImageSource.gallery);
  }*/

  Future<String> _subirServidor() async {
    //print("entro subirServidor");
    String _resultado = "Se guardo correctamente la información.";
    Photo1 foto = await _db.getPhoto(_registroId);
    familiaFile = null;
    familiaString = "";
    if (foto.family.length > 0) {
      familiaFile = io.File(foto.family);
      familiaString = Utility.base64String(familiaFile.readAsBytesSync());
    }

    viviendaFile = null;
    viviendaString = "";
    if (foto.home.length > 0) {
      viviendaFile = io.File(foto.home);
      viviendaString = Utility.base64String(viviendaFile.readAsBytesSync());
    }
    int reg1 = await _registrado(_registroId);
    print("antes de Navigator.push entro a reg1=" + reg1.toString());
    if (reg1 == 1) {
      return "No se puede actualizar";
    }

    //var client = http.Client();
    //var respuesta;
    int _resultadoWS = 0;
    try {
      var respuesta = await http.post(
          "http://siges.aevivienda.gob.bo/rub/rub/main/savebeneficiarioPhoto",
          body: json.encode({
            "familiy": familiaString,
            "home": viviendaString,
            "registerId": foto.registerId.toString()
          }),
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json"
          });
    } catch (e) {
      _resultado = "No guardo servicio de fotografias \n";
    }
    //client = http.Client();
    //var respuesta1;
    try {
      var respuesta1 = await http.post(
          "http://siges.aevivienda.gob.bo/rub/rub/main/savebeneficiarioLatLng",
          body: json.encode({
            "lat": foto.lat,
            "lng": foto.lng,
            "ai": foto.ai.toString(),
            "registerId": foto.registerId.toString()
          }),
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json"
          });
    } catch (e) {
      _resultado = _resultado + "No guardo los GPS, latitud y longitud";
    }
    setState(() {
      _loading = false;
    });
    return _resultado;
  }

  Future<int> _registrado(int registroId) async {
    print("_registrado ************************* ");
    Photo1 _foto = new Photo1();
    _foto.registerId = registroId;
    String url1 =
        "http://siges.aevivienda.gob.bo/rub/rub/main/beneficiarioapp/" +
            registroId.toString();
    print("url1=" + url1);
    try {
      final respuesta1 = await http.get(url1);
      String body1 = utf8.decode(respuesta1.bodyBytes);
      print("body***************************'" +
          body1 +
          "' '" +
          body1.substring(0, 1) +
          "'");
      if (body1.substring(0, 1) == '0') {
        _foto.ai = 0;
        _db.updateRegistrado(_foto);
        return 0;
      }
      if (body1.substring(0, 1) == '1') {
        _foto.ai = 1;
        _db.updateRegistrado(_foto);
        return 1;
      }
    } on TimeoutException catch (e) {
      print('timeout ****************Timeout Error: $e');
      return 0;
    } on io.SocketException catch (e) {
      print('SocketException ****************Timeout Error: $e');
      return 0;
    } on Error catch (e) {
      print('general ****************General Error: $e');
      return 0;
    }
  }
}

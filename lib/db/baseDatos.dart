import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/projectsDoc.dart';
import '../models/photo1.dart';

class BaseDatos {
  static Database _db;

  static const String TABLE = 'photos1';
  static const String REGISTER_ID = 'registerId';
  static const String FAMILY = 'family';
  static const String HOME = 'home';
  static const String LAT = 'lat';
  static const String LNG = 'lng';
  static const String AI = 'ai';

  static const String TABLE1 = 'projectsDoc';
  static const String PERSONA_ID = 'personaId';
  static const String REGISTRO_ID = 'registroId';
  static const String NOMBRE_PERSONA = 'nombrePersona';
  static const String CODIGO_PROJ = 'codigoProj';
  static const String NOMBRE_PROJ = 'nombreProj';
  static const String DOCUMENTO = 'documento';

  static const String DB_NAME = 'proyectos.db';

  Future<Database> get db async {
    //Obtenga el directorio de documentos del dispositivo para almacenar la base de datos sin conexión
    if (null != _db) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async {
    io.Directory documentoDirectorio = await getApplicationDocumentsDirectory();
    String path = join(documentoDirectorio.path, DB_NAME);
    //var db = await openDatabase(path, version: 1, onCreate: onCreate: (db, version) => _createDb(db), version: 1);
    var db = await openDatabase(path,
        onCreate: (db, version) => _createDb(db), version: 1);
    print("INICIAR BASE DE DATOS->" + path);
    return db;
  }

  static void _createDb(Database db) {
    //_onCreate() async {
    //Crea la tabla
    db.execute(
        "CREATE TABLE $TABLE($REGISTER_ID INTEGER PRIMARY KEY, $FAMILY TEXT, $HOME TEXT, $LAT TEXT, $LNG TEXT, $AI INTEGER)");
    db.execute(
        "CREATE TABLE $TABLE1($PERSONA_ID INTEGER PRIMARY KEY, $REGISTRO_ID INTEGER, $NOMBRE_PERSONA TEXT, $CODIGO_PROJ TEXT, $NOMBRE_PROJ TEXT, $DOCUMENTO TEXT)");
  }

  //metodo para insertar el registro photo en el DataBase

  Future<Photo1> insertFoto(Photo1 photo1) async {
    var dbClient = await db;
    photo1.registerId = await dbClient.insert(TABLE, photo1.toJson());
    return photo1;
  }

  Future<ProjectsDoc> insertProyectoDoc(ProjectsDoc proyectoDoc) async {
    var dbClient = await db;
    proyectoDoc.personaId = await dbClient.insert(TABLE1, proyectoDoc.toJson());
    return proyectoDoc;
  }

  //metodo para actualizar el registro de DataBase
  Future<int> updateFoto(Photo1 photo1) async {
    var dbClient = await db;
    return dbClient.update(TABLE, photo1.toJson(),
        where: '$REGISTER_ID= ?', whereArgs: [photo1.registerId]);
  }

  /*Future<int> updateFotoTodo(Photo1 photo1) async {
    var dbClient = await db;
    return dbClient.update(TABLE, photo1.toJson(),
        where: '$REGISTER_ID= ?', whereArgs: [photo1.registerId]);
  }*/

  /*Future<int> updateFotoFamilia(Photo1 photo1) async {
    var dbClient = await db;
    return dbClient.update(TABLE, photo1.toJson(),
        where: '$REGISTER_ID= ?', whereArgs: [photo1.registerId]);
  }*/

  Future<int> updateFotoFamilia(Photo1 photo2) async {
    var dbClient = await db;
    return dbClient.rawUpdate(
        'UPDATE photos1 SET family = ? WHERE registerId = ?',
        [photo2.family, photo2.registerId]);
  }

  /*Future<int> updateFotoCasa(Photo1 photo2) async {
    var dbClient = await db;
    return dbClient.update(TABLE, photo2.toJson(),
        where: '$REGISTER_ID= ?', whereArgs: [photo2.registerId]);
  }*/

  Future<int> updateFotoCasa(Photo1 photo2) async {
    var dbClient = await db;
    return dbClient.rawUpdate(
        'UPDATE photos1 SET home = ?  WHERE registerId = ?',
        [photo2.home, photo2.registerId]);
  }

  /*Future<int> updateFotoGps(Photo1 photo1) async {
    var dbClient = await db;
    return dbClient.update(TABLE, photo1.toJson(),
        where: '$REGISTER_ID= ?', whereArgs: [photo1.registerId]);
  }*/

  Future<int> updateFotoGps(Photo1 photo2) async {
    var dbClient = await db;
    return dbClient.rawUpdate(
        'UPDATE photos1 SET lat= ?, lng = ? WHERE registerId = ?',
        [photo2.lat, photo2.lng, photo2.registerId]);
  }

  Future<int> updateRegistrado(Photo1 photo2) async {
    var dbClient = await db;
    return dbClient.rawUpdate('UPDATE photos1 SET ai = ?  WHERE registerId = ?',
        [photo2.ai, photo2.registerId]);
  }

  Future<int> updateProyectoDoc(ProjectsDoc proyectoDoc) async {
    var dbClient = await db;
    return dbClient.update(TABLE1, proyectoDoc.toJson(),
        where: '$PERSONA_ID= ?', whereArgs: [proyectoDoc.personaId]);
    //return proyectoDoc;
  }

//metodo para borrar el registro de DataBase
  Future<int> deleteFoto(int registerId) async {
    var dbClient = await db;
    return dbClient
        .delete(TABLE, where: '$REGISTER_ID= ?', whereArgs: [registerId]);
    //return registerId;
  }

  Future<int> deleteProyectoDoc(int registroId) async {
    var dbClient = await db;
    return dbClient
        .delete(TABLE1, where: '$REGISTRO_ID= ?', whereArgs: [registroId]);
    //return registroId;
  }

  Future<List<Photo1>> getPhotos() async {
    var dbClient = await db;
    //especificar las columnas de la tabla
    List<Map> maps = await dbClient
        .query(TABLE, columns: [REGISTER_ID, FAMILY, HOME, LAT, LNG, AI]);
    List<Photo1> photos = [];
    //photos.add(Photo1.fromJson(maps[i]));
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        photos.add(Photo1.fromJson(maps[i]));
      }
    }
    return photos;
  }

  Future<Photo1> getPhoto(int registerId) async {
    var dbClient = await db;
    Photo1 photo = null;
    //especificar las columnas de la tabla
    List<Map> maps = await dbClient.query(TABLE,
        columns: [REGISTER_ID, FAMILY, HOME, LAT, LNG, AI],
        where: '$REGISTER_ID= ?',
        whereArgs: [registerId.toString()]);
    List<Photo1> photos = [];
    //print("bd photos " + maps.length.toString());
    photos.add(Photo1.fromJson(maps[0]));
    if (photos.length > 0) photo = photos[0];
    return photo;
  }

  Future<String> getFotoFamilia() async {
    String familia = "";
    var dbClient = await db;
    //especificar las columnas de la tabla
    List<Map> maps =
        await dbClient.query(TABLE, columns: [REGISTER_ID, FAMILY]);
    List<Photo1> photos = [];
    if (maps.length > 0) {
      photos.add(Photo1.fromJson(maps[0]));
    }
    familia = photos[0].family;
    return familia;
  }

  Future<String> getFotoCasa() async {
    String casa = "";
    var dbClient = await db;
    //especificar las columnas de la tabla
    List<Map> maps = await dbClient.query(TABLE, columns: [REGISTER_ID, HOME]);
    List<Photo1> photos = [];
    if (maps.length > 0) {
      photos.add(Photo1.fromJson(maps[0]));
      casa = photos[0].home;
    }
    return casa;
  }

  Future<Photo1> getFotoGps() async {
    var dbClient = await db;
    String gps = "";
    Photo1 photo = new Photo1();
    //especificar las columnas de la tabla
    List<Map> maps =
        await dbClient.query(TABLE, columns: [REGISTER_ID, LAT, LNG, AI]);
    /*List<Map> maps = await dbClient.query(TABLE,
        columns: [REGISTER_ID, LAT, LNG, AI],
        where: '$REGISTER_ID= ?',
        whereArgs: [registerId.toString()]);*/
    List<Photo1> photos = [];
    //print("bd photos " + maps.length.toString());
    photos.add(Photo1.fromJson(maps[0]));
    if (photos.length > 0) photo = photos[0];
    return photo;
  }

  Future<List<ProjectsDoc>> getProyectoDocs() async {
    var dbClient = await db;
    //especificar las columnas de la tabla
    List<Map> maps = await dbClient.query(TABLE1, columns: [
      PERSONA_ID,
      REGISTRO_ID,
      NOMBRE_PERSONA,
      CODIGO_PROJ,
      NOMBRE_PROJ,
      DOCUMENTO
    ]);
    List<ProjectsDoc> proyectoDoc = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        proyectoDoc.add(ProjectsDoc.fromJson(maps[i]));
      }
    }
    return proyectoDoc;
  }

  Future<int> getRegistroId() async {
    var dbClient = await db;
    //especificar las columnas de la tabla
    List<Map> maps = await dbClient.query(TABLE1, columns: [REGISTRO_ID]);
    List<ProjectsDoc> photos = [];
    if (maps.length > 0) {
      photos.add(ProjectsDoc.fromJson(maps[0]));
    }
    return photos[0].registroId;
  }

  Future<void> truncatePhoto1() async {
    var dbClient = await db;
    return await dbClient.delete(TABLE);
  }

  Future<void> truncateProjectsDoc() async {
    var dbClient = await db;
    return await dbClient.delete(TABLE1);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

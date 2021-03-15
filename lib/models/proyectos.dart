import 'package:aevivienda/models/projectsDoc.dart';
//import 'package:json_annotation/json_annotation.dart';

//@JsonSerializable()
class Proyectos {
  final num rolId;
  final String projects;
  final List<ProjectsDoc> projectsDoc;

  Proyectos({this.rolId, this.projects, this.projectsDoc});

  factory Proyectos.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['projectsDoc'] as List;
    List<ProjectsDoc> projectsList =
        list.map((i) => ProjectsDoc.fromJson(i)).toList();
    return Proyectos(
      rolId: parsedJson['rolId'],
      projects: parsedJson['projects'],
      projectsDoc: projectsList,
    );
  }
}

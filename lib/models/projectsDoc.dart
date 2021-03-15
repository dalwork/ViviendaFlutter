class ProjectsDoc {
  int personaId;
  int registroId;
  String nombrePersona;
  String codigoProj;
  String nombreProj;
  String documento;

  ProjectsDoc(
      {this.personaId,
      this.registroId,
      this.nombrePersona,
      this.codigoProj,
      this.nombreProj,
      this.documento});

  factory ProjectsDoc.fromJson(Map<String, dynamic> parsedJson) {
    return ProjectsDoc(
        personaId: parsedJson['personaId'],
        registroId: parsedJson['registroId'],
        nombrePersona: parsedJson['nombrePersona'],
        codigoProj: parsedJson['codigoProj'],
        nombreProj: parsedJson['nombreProj'],
        documento: parsedJson['documento']);
  }

  Map<String, dynamic> toJson() {
    return {
      "personaId": personaId,
      "registroId": registroId,
      "nombrePersona": nombrePersona,
      "codigoProj": codigoProj,
      "nombreProj": nombreProj,
      "documento": documento
    };
  }
}

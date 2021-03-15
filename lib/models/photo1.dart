class Photo1 {
  int registerId;
  String family;
  String home;
  String lat;
  String lng;
  int ai;

  Photo1(
      {this.registerId, this.family, this.home, this.lat, this.lng, this.ai});

  factory Photo1.fromJson(Map<String, dynamic> parsedJson) {
    return Photo1(
        registerId: parsedJson['registerId'],
        family: parsedJson['family'],
        home: parsedJson['home'],
        lat: parsedJson['lat'],
        lng: parsedJson['lng'],
        ai: parsedJson['ai']);
  }

  Map<String, dynamic> toJson() {
    return {
      "registerId": registerId,
      "family": family,
      "home": home,
      "lat": lat,
      "lng": lng,
      "ai": ai
    };
  }
}

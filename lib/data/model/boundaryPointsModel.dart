class BoundaryPoints {
  double? lat;
  double? lng;

  BoundaryPoints({this.lat, this.lng});

  BoundaryPoints.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

}
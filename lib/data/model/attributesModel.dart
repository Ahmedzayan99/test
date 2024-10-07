class AttributesModel {
  String? ids;
  String? value;
  String? attrName;
  String? name;
  String? swatcheType;
  String? swatcheValue;

  AttributesModel(
      {this.ids,
        this.value,
        this.attrName,
        this.name,
        this.swatcheType,
        this.swatcheValue});

  AttributesModel.fromJson(Map<String, dynamic> json) {
    ids = json['ids'];
    value = json['value'];
    attrName = json['attr_name'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

}
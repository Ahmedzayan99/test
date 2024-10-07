class FiltersModel {
  String? attributeValues;
  String? attributeValuesId;
  String? name;
  String? swatcheType;
  String? swatcheValue;

  FiltersModel(
      {this.attributeValues,
        this.attributeValuesId,
        this.name,
        this.swatcheType,
        this.swatcheValue});

  FiltersModel.fromJson(Map<String, dynamic> json) {
    attributeValues = json['attribute_values'];
    attributeValuesId = json['attribute_values_id'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

}
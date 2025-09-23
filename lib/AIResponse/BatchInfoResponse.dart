class MedicineData {
  final String? batch;
  final String? name;

  MedicineData({
    this.batch,
    this.name,
  });

  factory MedicineData.fromJson(Map<String, dynamic> json) {
    return MedicineData(
      batch: json['batch']??'',
      name: json['name']??'',
    );
  }
}

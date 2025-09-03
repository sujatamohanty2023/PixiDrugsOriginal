class MedicineData {
  final String? brandName;
  final String? genericName;
  final BatchDetails? batchDetails;

  MedicineData({
    this.brandName,
    this.genericName,
    this.batchDetails,
  });

  factory MedicineData.fromJson(Map<String, dynamic> json) {
    return MedicineData(
      brandName: json['brand_name']??'',
      genericName: json['generic_name']??'',
      batchDetails: json['batch_details'] != null
          ? BatchDetails.fromJson(json['batch_details'])
          : null,
    );
  }
}

class BatchDetails {
  final String? batchNumber;
  final String? mfgDate;
  final String? expDate;

  BatchDetails({
    this.batchNumber,
    this.mfgDate,
    this.expDate,
  });

  factory BatchDetails.fromJson(Map<String, dynamic> json) {
    return BatchDetails(
      batchNumber: json['batch_number']??'',
      mfgDate: json['mfg_date']??'',
      expDate: json['exp_date']??'',
    );
  }
}

class DisputeDetailsModel {
  final int id;
  final int customerId;
  final int supplierId;
  final String disputeAmt;
  final String settelledAmt;
  final String date;
  final String disputeImagePath;

  DisputeDetailsModel({
    required this.id,
    required this.customerId,
    required this.supplierId,
    required this.disputeAmt,
    required this.settelledAmt,
    required this.date,
    required this.disputeImagePath,
  });

  factory DisputeDetailsModel.fromJson(Map<String, dynamic> json) {
    return DisputeDetailsModel(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? 0,
      supplierId: json['supplierId'] ?? 0,
      disputeAmt: (json['disputeAmt'] ?? 0).toString(),
      settelledAmt: (json['settelledAmt'] ?? 0).toString(),
      date: json['date'] ?? '',
      disputeImagePath: json['disputeImagePath'] ?? '',
    );
  }
}



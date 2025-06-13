class Honharlist {
  final String name;
  final String mobile;
  final String station;
  final String address;

  Honharlist({
    required this.name,
    required this.mobile,
    required this.station,
    required this.address,
  });

  factory Honharlist.fromJson(Map<String, dynamic> json) {
    return Honharlist(
      name: json['accountName'] ?? '',
      mobile: json['mobileNo'] ?? '',
      station: json['station'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

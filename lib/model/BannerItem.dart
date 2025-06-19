class BannerItem {
  final int? id;
  final String? title;
  final String? description;
  final String? category;
  final String? startDate;
  final String? expiryDate;
  final String? visibleTo;
  final String? entryType;
  final int? bannerOrder;
  final bool? status;
  final String? date;
  final String? bannerImagePath;

  BannerItem({
    this.id,
    this.title,
    this.description,
    this.category,
    this.startDate,
    this.expiryDate,
    this.visibleTo,
    this.entryType,
    this.bannerOrder,
    this.status,
    this.date,
    this.bannerImagePath,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      startDate: json['startDate'],
      expiryDate: json['expiryDate'],
      visibleTo: json['visibleTo'],
      entryType: json['entryType'],
      bannerOrder: json['bannerOrder'],
      status: json['status'],
      date: json['date'],
      bannerImagePath: json['bannerImagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'visibleTo': visibleTo,
      'entryType': entryType,
      'bannerOrder': bannerOrder,
      'status': status,
      'date': date,
      'bannerImagePath': bannerImagePath,
    };
  }
}


class BannerResponse {
  final List<BannerItem>? data;
  final String? message;
  final bool? success;
  final bool? error;
  final String? responseCode;

  BannerResponse({
    this.data,
    this.message,
    this.success,
    this.error,
    this.responseCode,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      data: (json['data'] as List?)?.map((item) => BannerItem.fromJson(item)).toList() ?? [],
      message: json['message'],
      success: json['success'],
      error: json['error'],
      responseCode: json['responsecode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((item) => item.toJson()).toList(),
      'message': message,
      'success': success,
      'error': error,
      'responsecode': responseCode,
    };
  }
}


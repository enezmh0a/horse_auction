import 'package:flutter/foundation.dart';

enum ServiceType { veterinary, transportation }

enum RequestStatus { pending, confirmed, completed, cancelled }

@immutable
class ServiceRequest {
  final String id;
  final ServiceType type;
  final String customerName;
  final String phone;
  final String horseName;
  final DateTime createdAt;
  final RequestStatus status;
  final String? notes;

  const ServiceRequest({
    required this.id,
    required this.type,
    required this.customerName,
    required this.phone,
    required this.horseName,
    required this.createdAt,
    this.status = RequestStatus.pending,
    this.notes,
  });

  ServiceRequest copyWith({
    ServiceType? type,
    String? customerName,
    String? phone,
    String? horseName,
    DateTime? createdAt,
    RequestStatus? status,
    String? notes,
  }) {
    return ServiceRequest(
      id: id,
      type: type ?? this.type,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      horseName: horseName ?? this.horseName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      type: ServiceType.values.firstWhere(
        (e) => describeEnum(e) == json['type'],
        orElse: () => ServiceType.veterinary,
      ),
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      horseName: json['horseName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: RequestStatus.values.firstWhere(
        (e) => describeEnum(e) == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': describeEnum(type),
    'customerName': customerName,
    'phone': phone,
    'horseName': horseName,
    'createdAt': createdAt.toIso8601String(),
    'status': describeEnum(status),
    'notes': notes,
  };
}

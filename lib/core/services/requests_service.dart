import 'dart:math';
import 'package:flutter/foundation.dart';

/// -------------------------
/// Service model + enums
/// -------------------------

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

/// -------------------------
/// In-memory service
/// -------------------------

class RequestsService {
  RequestsService._();
  static final RequestsService instance = RequestsService._();

  final List<ServiceRequest> _store = <ServiceRequest>[];
  final ValueNotifier<List<ServiceRequest>> requests =
      ValueNotifier<List<ServiceRequest>>(<ServiceRequest>[]);

  /// Read-only snapshot
  List<ServiceRequest> get all => List.unmodifiable(_store);

  /// Seed demo data (call once)
  void seedIfEmpty() {
    if (_store.isNotEmpty) return;
    final now = DateTime.now();

    _store.addAll([
      ServiceRequest(
        id: _newId(),
        type: ServiceType.veterinary,
        customerName: 'Fahad',
        phone: '0550001111',
        horseName: 'Desert Comet',
        createdAt: now.subtract(const Duration(minutes: 20)),
        status: RequestStatus.confirmed,
        notes: 'Pre-purchase vet check',
      ),
      ServiceRequest(
        id: _newId(),
        type: ServiceType.transportation,
        customerName: 'Noura',
        phone: '0562223333',
        horseName: 'Golden Mirage',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: RequestStatus.pending,
        notes: 'Riyadh farm → main arena',
      ),
    ]);

    _emit();
  }

  ServiceRequest add({
    required ServiceType type,
    required String customerName,
    required String phone,
    required String horseName,
    String? notes,
  }) {
    final req = ServiceRequest(
      id: _newId(),
      type: type,
      customerName: customerName,
      phone: phone,
      horseName: horseName,
      createdAt: DateTime.now(),
      status: RequestStatus.pending,
      notes: notes,
    );
    _store.add(req);
    _emit();
    return req;
  }

  void updateStatus(String id, RequestStatus status) {
    final i = _store.indexWhere((r) => r.id == id);
    if (i == -1) return;
    _store[i] = _store[i].copyWith(status: status);
    _emit();
  }

  void remove(String id) {
    _store.removeWhere((r) => r.id == id);
    _emit();
  }

  List<ServiceRequest> byStatus(RequestStatus status) =>
      _store.where((r) => r.status == status).toList(growable: false);

  List<ServiceRequest> search(String q) {
    final query = q.toLowerCase();
    return _store
        .where((r) {
          return r.customerName.toLowerCase().contains(query) ||
              r.horseName.toLowerCase().contains(query) ||
              describeEnum(r.type).toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  /// Demo helper to advance a random request
  void randomAdvance() {
    if (_store.isEmpty) return;
    final i = Random().nextInt(_store.length);
    final r = _store[i];
    final next = switch (r.status) {
      RequestStatus.pending => RequestStatus.confirmed,
      RequestStatus.confirmed => RequestStatus.completed,
      RequestStatus.completed => RequestStatus.completed,
      RequestStatus.cancelled => RequestStatus.cancelled,
    };
    updateStatus(r.id, next);
  }

  // ---- helpers ----
  void _emit() => requests.value = List.unmodifiable(_store);

  String _newId() =>
      'SR-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999).toString().padLeft(4, '0')}';
}

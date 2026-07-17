import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/promo_code_entity.dart';

class PromoCodeModel {
  final String code;
  final double discountPercent;
  final int maxUses;
  final int currentUses;
  final DateTime? expiresAt;
  final bool isActive;

  const PromoCodeModel({
    required this.code,
    required this.discountPercent,
    this.maxUses = 0,
    this.currentUses = 0,
    this.expiresAt,
    this.isActive = true,
  });

  factory PromoCodeModel.fromFirestore(Map<String, dynamic> data) {
    return PromoCodeModel(
      code: data['code'] ?? '',
      discountPercent: (data['discountPercent'] ?? 0).toDouble(),
      maxUses: (data['maxUses'] ?? 0).toInt(),
      currentUses: (data['currentUses'] ?? 0).toInt(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    if (maxUses > 0 && currentUses >= maxUses) return false;
    return true;
  }

  bool get isUnlimited => maxUses == 0;

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'discountPercent': discountPercent,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
    };
  }

  PromoCodeEntity toEntity() {
    return PromoCodeEntity(
      code: code,
      discountPercent: discountPercent,
    );
  }
}

/// Utilitas parsing JSON longgar untuk payload API legacy Aurora (PHP).
///
/// Backend lama tidak konsisten tipe: angka bisa datang sebagai String
/// ("12500") maupun num (12500). Semua `fromJson` model legacy memakai
/// helper ini supaya tidak crash karena perbedaan tipe antar-endpoint.
library;

String? asString(Object? v) {
  if (v == null) return null;
  if (v is String) return v;
  return '$v';
}

int? asInt(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

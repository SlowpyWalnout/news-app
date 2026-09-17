// Ausente en Firestore == "nunca moderado" (ver backend/docs/DB_SCHEMA.md).
// AuthoredArticleModel.fromFirestore mapea ese caso a null, no a un valor
// de este enum — nunca inventar un cuarto estado "none" aquí.
enum ModerationState {
  suspended,
  approved,
  removed;

  static ModerationState? fromValue(String? value) {
    if (value == null) return null;
    return ModerationState.values.firstWhere((s) => s.name == value);
  }

  String get value => name;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/data/models/authored_article_model.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';

const int kSuspendedPageSize = 15;

class ModerationFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final fb_auth.FirebaseAuth _auth;

  ModerationFirestoreDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _articles => _firestore.collection('articles');

  // El id del documento es el uid del reportero — un create() sobre un id que
  // ya existe falla sola, sin necesidad de comprobar duplicados aparte
  // (firestore.rules lo refuerza igual, esto es solo la escritura).
  Future<void> reportArticle(ReportArticleParams params) {
    final reporterUid = _auth.currentUser!.uid;
    return _articles.doc(params.articleId).collection('reports').doc(reporterUid).set({
      'reason': params.reason.name,
      if (params.note != null && params.note!.isNotEmpty) 'note': params.note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasReported(String articleId) async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _articles.doc(articleId).collection('reports').doc(uid).get();
    return snapshot.exists;
  }

  Future<bool> isStaff() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data()?['role'] == 'staff';
  }

  // Republica (approve) o retira (remove) un artículo suspendido. Solo estos
  // campos — firestore.rules exige exactamente este set en la rama de staff.
  Future<void> decideOnArticle(DecideParams params) {
    final staffUid = _auth.currentUser!.uid;
    final approved = params.decision == ModerationDecision.approve;
    return _articles.doc(params.articleId).update({
      'status': approved ? 'published' : 'draft',
      'moderationState': approved ? 'approved' : 'removed',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': staffUid,
    });
  }

  Future<PaginatedResult<AuthoredArticleModel>> listSuspended({String? cursor}) async {
    Query<Map<String, dynamic>> query = _articles
        .where('moderationState', isEqualTo: 'suspended')
        .orderBy('suspendedAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
    query = _applyCursor(query, cursor);
    final snapshot = await query.limit(kSuspendedPageSize).get();
    final items = snapshot.docs.map(AuthoredArticleModel.fromFirestore).toList();
    String? nextCursor;
    if (items.length == kSuspendedPageSize) {
      final last = items.last;
      nextCursor = '${last.suspendedAt!.millisecondsSinceEpoch}|${last.id}';
    }
    return PaginatedResult(items: items, nextCursor: nextCursor);
  }

  Query<Map<String, dynamic>> _applyCursor(Query<Map<String, dynamic>> query, String? cursor) {
    if (cursor == null) return query;
    final separator = cursor.indexOf('|');
    final millis = int.parse(cursor.substring(0, separator));
    final docId = cursor.substring(separator + 1);
    return query.startAfter([Timestamp.fromMillisecondsSinceEpoch(millis), docId]);
  }
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:uuid/uuid.dart';

class AuthoredArticleStorageDataSource {
  final FirebaseStorage _storage;
  final fb_auth.FirebaseAuth _auth;
  final Uuid _uuid;

  AuthoredArticleStorageDataSource(
    this._storage,
    this._auth, {
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  // Path shape from docs/DB_SCHEMA.md: media/articles/{uid}/{articleId}/{imageId}.{ext}.
  // `uid` lets storage.rules validate ownership without a Firestore read.
  Future<UploadThumbnailResult> uploadThumbnail(String articleId, String filePath) async {
    final uid = _auth.currentUser!.uid;
    final dotIndex = filePath.lastIndexOf('.');
    final ext = dotIndex == -1 ? 'jpg' : filePath.substring(dotIndex + 1);
    final path = 'media/articles/$uid/$articleId/${_uuid.v4()}.$ext';

    final ref = _storage.ref(path);
    await ref.putFile(File(filePath));
    final url = await ref.getDownloadURL();
    return UploadThumbnailResult(url: url, path: path);
  }

  // `object-not-found` is treated as success so a delete retry is idempotent
  // (see ROADMAP.md, "Borrado: Storage primero, Firestore después").
  Future<void> deleteThumbnail(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}

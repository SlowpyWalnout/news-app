import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Progress in [0, 1], reported while the (already compressed) file uploads.
typedef UploadProgressCallback = void Function(double progress);

/// Cap matching `kMaxCoverSizeBytes` in `ArticleEditorBloc` — compression
/// targets well under the 5 MB Storage rule, not just the original limit.
const int _kCompressedMaxDimension = 1600;
const int _kCompressedQuality = 80;

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
  Future<UploadThumbnailResult> uploadThumbnail(
    String articleId,
    String filePath, {
    UploadProgressCallback? onProgress,
  }) async {
    final uid = _auth.currentUser!.uid;
    // Compressed output is always JPEG regardless of the source format.
    final path = 'media/articles/$uid/$articleId/${_uuid.v4()}.jpg';
    final compressedPath = await _compress(filePath);

    final ref = _storage.ref(path);
    final task = ref.putFile(File(compressedPath));
    if (onProgress != null) {
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
    }
    await task;
    final url = await ref.getDownloadURL();
    return UploadThumbnailResult(url: url, path: path);
  }

  Future<String> _compress(String filePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${_uuid.v4()}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      minWidth: _kCompressedMaxDimension,
      minHeight: _kCompressedMaxDimension,
      quality: _kCompressedQuality,
      format: CompressFormat.jpeg,
    );
    // Some formats (e.g. already-tiny images) can't be compressed further;
    // fall back to the original file rather than fail the whole upload.
    return result?.path ?? filePath;
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

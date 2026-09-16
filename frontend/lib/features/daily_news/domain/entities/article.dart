import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable{
  final int ? id;
  // Firestore doc id of the AuthoredArticleEntity this row was saved from,
  // when it came from that flow (null for the legacy NewsAPI path). Lets a
  // saved row be matched back to its Firestore article without relying on
  // the Floor `id` (an int, unrelated to the Firestore string id) or on
  // title matching.
  final String ? sourceId;
  final String ? author;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;
  final bool isRead;

  const ArticleEntity({
    this.id,
    this.sourceId,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.isRead = false,
  });

  @override
  List < Object ? > get props {
    return [
      id,
      sourceId,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      isRead,
    ];
  }
}
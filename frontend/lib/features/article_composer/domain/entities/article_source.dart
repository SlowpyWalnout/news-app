/// Origin of an `articles` document that isn't community-authored. Written
/// only by the backend crons (`syncGuardianNews`/`syncGnewsHeadlines`) —
/// `firestore.rules` keeps it out of every client-writable field list, so a
/// user can never attach this to their own article. See
/// backend/docs/DB_SCHEMA.md.
enum ArticleSource {
  guardian,
  gnews;

  String get value => name;
}

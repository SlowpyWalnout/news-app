// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appWordmark => 'NEWS';

  @override
  String get loginHeroTitle => 'Local news, written by the locals.';

  @override
  String get loginHeroSubtitle => 'Sign in to read and publish.';

  @override
  String get networkErrorTitle => 'We couldn\'t connect';

  @override
  String get networkErrorBody =>
      'Check your connection. We retry when you tap \"Sign in\".';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailPlaceholder => 'name@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordPlaceholder => 'At least 6 characters';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get noAccountYet => 'No account yet?';

  @override
  String get signUp => 'Sign up';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleSignInError =>
      'We couldn\'t sign you in with Google. Try again.';

  @override
  String get loginCredentialError =>
      'That email and password don\'t match. Try again or reset your password.';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'Enter a valid email, with @ and a dot.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get passwordTooShort => 'Password needs 6 characters or more.';

  @override
  String get back => 'Back';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountSubtitle => 'Three fields and you\'re in.';

  @override
  String get registerEmailTaken =>
      'An account already uses that email. Sign in or use another.';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNamePlaceholder => 'How readers will see you';

  @override
  String displayNameCounter(int count) {
    return '$count / 60';
  }

  @override
  String get displayNameEmpty => 'Write at least 1 character.';

  @override
  String get displayNameTooLong => '60 characters max.';

  @override
  String get passwordValid => 'Password looks good';

  @override
  String get createAccount => 'Create account';

  @override
  String get creatingAccount => 'Creating…';

  @override
  String get searchPlaceholder => 'Search News';

  @override
  String get searchClear => 'Clear search';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryScience => 'Science';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryPolitics => 'Politics';

  @override
  String get categoryOther => 'Other';

  @override
  String get feedLoadingCaption => 'Fetching the latest news…';

  @override
  String get feedNetworkErrorTitle => 'The server isn\'t responding';

  @override
  String get feedNetworkErrorBody =>
      'Error 503 requesting the feed. Your drafts are still saved on this phone.';

  @override
  String get retry => 'Retry';

  @override
  String get feedEmptySearchTitle => 'No results';

  @override
  String get feedEmptySearchBody =>
      'We couldn\'t find news with those words. Try fewer words.';

  @override
  String get feedEmptyFilterTitle => 'No news here yet';

  @override
  String get feedEmptyFilterBody =>
      'Nobody posted in this category this week. You could be the first.';

  @override
  String get viewAllCategories => 'View all categories';

  @override
  String readTimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get backToFeed => 'Feed';

  @override
  String get readLaterAdd => 'Read it later';

  @override
  String get readLaterAdded => 'Read it later ✓';

  @override
  String get readLaterAddedToast => 'Added to Read it later';

  @override
  String get readLaterRemovedToast => 'Removed from Read it later';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get notYoursTitle => 'This article isn\'t yours';

  @override
  String notYoursBody(String author) {
    return '$author published it, so you can\'t edit or delete it. You can mark it Read it later or write your own story.';
  }

  @override
  String get exit => 'Exit';

  @override
  String get newArticleTitle => 'New article';

  @override
  String get editArticleTitle => 'Edit article';

  @override
  String get titleLabel => 'Title';

  @override
  String get titlePlaceholder => 'Sum up what happened in one line';

  @override
  String titleCounter(int count) {
    return '$count / 120';
  }

  @override
  String get titleEmptyError => 'The title can\'t be empty.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get coverLabel => 'Cover image';

  @override
  String get chooseCoverImage => 'Choose image';

  @override
  String get removeCoverImage => 'Remove image';

  @override
  String get coverHint => 'JPG · PNG · WEBP — up to 5 MB';

  @override
  String coverTooLarge(String sizeMb) {
    return 'That image is $sizeMb MB and the limit is 5 MB. Try a smaller photo or lower the quality.';
  }

  @override
  String get bodyLabel => 'Story body';

  @override
  String get bodyPlaceholder =>
      'Write what you saw, who told you, and when it happened.';

  @override
  String bodyCounter(String count) {
    return '$count / 20,000';
  }

  @override
  String get bodyEmptyError => 'The story body is missing.';

  @override
  String get writeTab => 'Write';

  @override
  String get previewTab => 'Preview';

  @override
  String get previewEmpty => 'Nothing to preview yet.';

  @override
  String get markdownBold => 'Bold';

  @override
  String get markdownItalic => 'Italic';

  @override
  String get markdownHeading2 => 'Heading';

  @override
  String get markdownHeading3 => 'Subheading';

  @override
  String get markdownQuote => 'Quote';

  @override
  String get markdownBullet => 'Bullet list';

  @override
  String get markdownPlaceholder => 'text';

  @override
  String get saveDraft => 'Save';

  @override
  String get publish => 'Publish';

  @override
  String get publishing => 'Publishing…';

  @override
  String get emptyDraftToast => 'Write a title or body before saving';

  @override
  String get draftSavedToast => 'Draft saved on this phone';

  @override
  String get publishedToast => 'Published! It\'s live on the feed';

  @override
  String get myArticlesTitle => 'My articles';

  @override
  String get tabAll => 'All';

  @override
  String get tabDrafts => 'Drafts';

  @override
  String get tabPublished => 'Published';

  @override
  String get myArticlesNetErrorTitle => 'We couldn\'t load your list';

  @override
  String get myArticlesNetErrorBody =>
      'The connection dropped while requesting page 1. Your local drafts are still here.';

  @override
  String get myArticlesEmptyTitle => 'You haven\'t written anything yet';

  @override
  String get myArticlesEmptyBody =>
      'Your first story can be short: what happened, where, and when. It saves itself as a draft.';

  @override
  String get myArticlesEmptyDraftTitle => 'No drafts';

  @override
  String get myArticlesEmptyDraftBody =>
      'Everything you started is already published.';

  @override
  String get writeFirstArticle => 'Write my first article';

  @override
  String get draftPill => 'Draft';

  @override
  String get publishedPill => 'Published';

  @override
  String get loadMore => 'Load more';

  @override
  String get noMore => 'No more';

  @override
  String get publishedStatLabel => 'published';

  @override
  String get draftsStatLabel => 'drafts';

  @override
  String get myArticlesRow => 'My articles';

  @override
  String get writeArticleRow => 'Write an article';

  @override
  String get readLaterRow => 'Read it later';

  @override
  String get appearanceRow => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accessibleModeRow => 'Accessible mode';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get languageRow => 'Language';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get logOut => 'Log out';

  @override
  String get profileStaleDataTitle => 'Your data is out of date';

  @override
  String get profileStaleDataBody =>
      'We\'re showing the last copy saved on this phone. We\'ll retry automatically once you\'re back online.';

  @override
  String get confirmDeleteTitle => 'Delete this article?';

  @override
  String confirmDeleteBody(String title) {
    return '\"$title\" is deleted forever, including for people who marked it Read it later.';
  }

  @override
  String get confirmDeleteYes => 'Yes, delete';

  @override
  String get confirmDeleteNo => 'No, go back';

  @override
  String get articleDeletedToast => 'Article deleted';

  @override
  String get navFeed => 'Feed';

  @override
  String get navMyArticles => 'My articles';

  @override
  String get navProfile => 'Profile';

  @override
  String get readLaterTitle => 'Read it later';

  @override
  String get readLaterEmpty =>
      'You haven\'t marked any articles Read it later yet.';

  @override
  String get readLaterAlreadyRead => 'Already read';

  @override
  String get readLaterErrorTitle => 'Couldn\'t load your list';

  @override
  String get readLaterErrorBody =>
      'Something went wrong loading Read it later. Your saved articles are still on this phone.';

  @override
  String get reportAction => 'Report';

  @override
  String get reportAlreadyDone => 'Already reported';

  @override
  String get reportSheetTitle => 'Why are you reporting this article?';

  @override
  String get reportSheetBody =>
      'Your report is anonymous to the author. We review articles with multiple reports.';

  @override
  String get reportReasonSexual => 'Sexual content';

  @override
  String get reportReasonViolence => 'Violence';

  @override
  String get reportReasonHate => 'Hate speech';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonMisinformation => 'Misinformation';

  @override
  String get reportReasonOther => 'Other reason';

  @override
  String get reportNoteLabel => 'Details (optional)';

  @override
  String get reportSubmit => 'Send report';

  @override
  String get reportCancel => 'Cancel';

  @override
  String get reportSentToast => 'Report sent';

  @override
  String get reportErrorToast => 'Couldn\'t send the report';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get suspendedBannerTitle => 'This article was suspended';

  @override
  String get suspendedBannerBody =>
      'It received multiple reports from the community. Edit it to fix what\'s needed and publish it again.';

  @override
  String get staffReviewRow => 'Report review';

  @override
  String get staffReviewQueueTitle => 'Suspended articles';

  @override
  String get staffReviewQueueEmpty => 'No suspended articles to review.';

  @override
  String get staffApprove => 'Approve';

  @override
  String get staffRemove => 'Remove';

  @override
  String get staffDecisionApprovedToast => 'Article republished';

  @override
  String get staffDecisionRemovedToast => 'Article removed';
}

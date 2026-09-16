import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }

    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  void open() {
    openedAt = DateTime.now();
  }

  String report() {
    return _cachedReport ??= items
        .map((item) => item.describe())
        .join('\n');
  }

  List<String> get allTitles =>
      items.map((item) => item.title).toList();

  List<Book> get recentBooks =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  double get averagePages {
    final books = items.whereType<Book>();

    // fold is used because reduce would throw on an empty collection.
    return books.isEmpty
        ? 0
        : books.fold<int>(0, (sum, book) => sum + book.pages) /
        books.length;
  }

  Map<String, int> get authorBookCounts =>
      items.whereType<Book>().fold<Map<String, int>>(
        {},
            (counts, book) {
          counts[book.author.name] =
              (counts[book.author.name] ?? 0) + 1;
          return counts;
        },
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    for (final book in items.whereType<Book>())
      '${book.title} (${book.year})',
    ...items.whereType<Book>().map((book) => book.author.name),
    if (items.whereType<Book>().any((book) => book.pages == 0))
      '(incomplete data)',
  ];
}
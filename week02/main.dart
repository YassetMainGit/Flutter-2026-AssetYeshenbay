import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final rawBook in rawBooks) {
    library.add(Book.fromJson(rawBook));
  }

  library.open();

  print('--- FIND BY TITLE ---');
  final book = library.findByTitle('Clean Code');
  print(book);

  print('\n--- COUNTRY ---');
  print(library.countryOf('Clean Code'));

  print('\n--- REPORT ---');
  print(library.report());

  print('\n--- ALL TITLES ---');
  print(library.allTitles);

  print('\n--- RECENT BOOKS ---');
  print(library.recentBooks);

  print('\n--- AVERAGE PAGES ---');
  print(library.averagePages);

  print('\n--- AUTHOR BOOK COUNTS ---');
  print(library.authorBookCounts);

  print('\n--- AUTHOR NAMES ---');
  print(library.authorNames);

  print('\n--- GENRES ---');
  print(library.genres);

  print('\n--- DISPLAY LIST ---');
  for (final line in library.displayList) {
    print(line);
  }

  final books = library.items.whereType<Book>().toList();

  print('\n--- STATS ---');
  final stats = statsOf(books);
  print('Count: ${stats.count}');
  print('Average pages: ${stats.avgPages}');

  print('\n--- SHELF STATES ---');
  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('Shelf error')));
}
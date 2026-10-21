import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('fromMap keeps an omitted year null and defaults to unread', () {
    final book = Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10});

    expect(book.year, isNull);
    expect(book.read, isFalse);
    expect(book.toString(), 'X — Y, 10 pp.');
  });

  test('fromMap reads all fields and toString includes a known year', () {
    final book = Book.fromMap({
      'title': 'Null Safety for Humans',
      'author': 'B. Seitkali',
      'pages': 196,
      'year': 2022,
      'read': true,
    });

    expect(book.read, isTrue);
    expect(
      book.toString(),
      'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
    );
  });

  test('fromMap rejects missing or incorrectly typed required data', () {
    expect(
      () => Book.fromMap({'author': 'Y', 'pages': 10}),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => Book.fromMap({'title': 'X', 'pages': 10}),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => Book.fromMap({'title': 'X', 'author': 'Y', 'pages': '10'}),
      throwsA(isA<TypeError>()),
    );
  });

  test('seed contains 1220 pages and four unread books', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
  });

  test('collection helpers preserve order without changing their input', () {
    final first = Book(title: 'First', author: 'One', pages: 10);
    final second = Book(title: 'Second', author: 'Two', pages: 20, read: true);
    final third = Book(title: 'Third', author: 'One', pages: 30);
    final books = [first, second, third];

    expect(totalPages(books), 60);
    expect(unread(books), [first, third]);
    expect(authors(books), ['One', 'Two']);
    expect(books, [first, second, third]);
    expect(totalPages([]), 0);
    expect(unread([]), isEmpty);
    expect(authors([]), isEmpty);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/add_book_screen.dart';
import 'package:reading_list/detail_screen.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';
import 'package:reading_list/widgets/book_tile.dart';

const secondTitle = 'Null Safety for Humans';
const longTitle =
    'A Very Long Title About Forms, Focus, the Keyboard '
    'and Everything That Overflows';

Finder chip(String label) => find.widgetWithText(ChoiceChip, label);

Finder tile(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(BookTile));

List<String> errors(WidgetTester tester) => tester
    .widgetList<InputDecorator>(find.byType(InputDecorator))
    .map((widget) => widget.decoration.errorText)
    .whereType<String>()
    .toList();

Future<void> startApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> openForm(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    for (var i = 0; i < seed.length; i++) {
      seed[i].read = i == 0;
    }
  });

  testWidgets('unread filter reacts to a checkbox and remembers changes', (
    tester,
  ) async {
    await startApp(tester);
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);

    await tester.tap(chip('Unread'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(chip('Unread')).selected, isTrue);

    final checkbox = find.descendant(
      of: tile(secondTitle),
      matching: find.byType(Checkbox),
    );
    expect(
      find.descendant(of: tile(secondTitle), matching: find.byType(Positioned)),
      findsOneWidget,
    );
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(find.text(secondTitle), findsNothing);
    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(chip('Read'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (2)'), findsOneWidget);
    expect(
      tester
          .widget<Checkbox>(
            find.descendant(
              of: tile(secondTitle),
              matching: find.byType(Checkbox),
            ),
          )
          .value,
      isTrue,
    );
    expect(
      find.descendant(of: tile(secondTitle), matching: find.byType(Positioned)),
      findsNothing,
    );

    await tester.tap(chip('All'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(chip('All')).selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'detail back leaves the list unchanged and read action updates it',
    (tester) async {
      await startApp(tester);
      await tester.tap(find.text(secondTitle));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Mark as read'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Reading list (5)'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      await tester.tap(find.text(secondTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as read'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsNothing);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.text(secondTitle));
      await tester.pumpAndSettle();
      expect(find.text('Mark as unread'), findsOneWidget);
      await tester.tap(find.text('Mark as unread'));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('delete requires confirmation and updates book and page totals', (
    tester,
  ) async {
    await startApp(tester);
    await tester.tap(find.text(secondTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(DetailScreen), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsNothing);
    expect(find.text(secondTitle), findsNothing);
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(find.text('1024'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty form shows exactly three errors and keeps year optional', (
    tester,
  ) async {
    await startApp(tester);
    await openForm(tester);
    await save(tester);
    expect(find.byType(AddBookScreen), findsOneWidget);
    expect(errors(tester), hasLength(3));
    expect(errors(tester), contains('A whole number above 0'));

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('form rejects short titles, blank authors and invalid numbers', (
    tester,
  ) async {
    await startApp(tester);
    await openForm(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), ' A ');
    await tester.enterText(fields.at(1), '   ');
    await tester.enterText(fields.at(2), 'abc');
    await tester.enterText(fields.at(3), '1449');
    await save(tester);
    expect(errors(tester), hasLength(4));

    await tester.enterText(fields.at(0), 'New book');
    await tester.enterText(fields.at(1), 'New author');
    for (final pages in ['0', '-1', '2.5']) {
      await tester.enterText(fields.at(2), pages);
      await save(tester);
      expect(errors(tester), contains('A whole number above 0'));
      expect(find.byType(AddBookScreen), findsOneWidget);
    }

    await tester.enterText(fields.at(2), '100');
    for (final year in ['abc', '${DateTime.now().year + 1}']) {
      await tester.enterText(fields.at(3), year);
      await save(tester);
      expect(errors(tester), hasLength(1));
      expect(find.byType(AddBookScreen), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving a book trims text and keeps an empty year null', (
    tester,
  ) async {
    await startApp(tester);
    await openForm(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '  New book  ');
    await tester.enterText(fields.at(1), '  New author  ');
    await tester.enterText(fields.at(2), '100');
    await save(tester);

    expect(find.text('Reading list (6)'), findsOneWidget);
    expect(find.text('1320'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('New book'), 150);
    final newTile = tester.widget<BookTile>(tile('New book'));
    expect(newTile.book.title, 'New book');
    expect(newTile.book.author, 'New author');
    expect(newTile.book.year, isNull);
    expect(newTile.book.read, isFalse);

    await tester.tap(find.text('New book'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list fits narrow portrait and landscape layouts', (
    tester,
  ) async {
    await startApp(tester);
    await tester.tap(chip('Unread'));
    await tester.pumpAndSettle();

    for (final size in [const Size(360, 740), const Size(844, 390)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(longTitle), 150);
      final title = tester.widget<Text>(find.text(longTitle));
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    }
  });
}

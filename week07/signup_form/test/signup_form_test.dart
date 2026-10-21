import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';
import 'package:signup_form/summary_card.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Finder get signUpButton => find.widgetWithText(FilledButton, 'Sign up');

String? errorFor(WidgetTester tester, String label) =>
    tester.state<FormFieldState<String>>(field(label)).errorText;

List<String> errors(WidgetTester tester) => tester
    .widgetList<InputDecorator>(find.byType(InputDecorator))
    .map((widget) => widget.decoration.errorText)
    .whereType<String>()
    .toList();

EditableText editable(WidgetTester tester, String label) =>
    tester.widget<EditableText>(
      find.descendant(of: field(label), matching: find.byType(EditableText)),
    );

Future<void> startApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String label, String text) async {
  await tester.ensureVisible(field(label));
  await tester.enterText(field(label), text);
  await tester.pumpAndSettle();
}

Future<void> agree(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester) async {
  await tester.ensureVisible(signUpButton);
  await tester.tap(signUpButton);
  await tester.pumpAndSettle();
}

Future<void> chooseGroup(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('IT-2303').last);
  await tester.pumpAndSettle();
}

Future<void> openDatePicker(WidgetTester tester) async {
  await tester.ensureVisible(field('Date of birth'));
  await tester.tap(field('Date of birth'));
  await tester.pumpAndSettle();
}

Future<void> chooseBirthDate(WidgetTester tester) async {
  await openDatePicker(tester);
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  final input = find.descendant(
    of: find.byType(DatePickerDialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(input, '10/20/2007');
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> fillValidForm(WidgetTester tester) async {
  await enter(tester, 'Name', '  Ayan  ');
  await enter(tester, 'Email', '  ayan@kbtu.kz  ');
  await enter(tester, 'Password', 'secret123');
  await enter(tester, 'Confirm password', 'secret123');
  await chooseGroup(tester);
  await chooseBirthDate(tester);
}

void main() {
  testWidgets('pristine form has no errors and cannot be submitted', (
    tester,
  ) async {
    await startApp(tester);
    expect(errors(tester), isEmpty);
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNull);
    expect(find.text('0 of 8'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('empty submit shows six errors and fixing one clears only it', (
    tester,
  ) async {
    await startApp(tester);
    await agree(tester);
    await submit(tester);
    expect(errors(tester), hasLength(6));
    expect(find.text('Choose a group'), findsOneWidget);
    expect(errorFor(tester, 'Confirm password'), isNotNull);

    await enter(tester, 'Name', 'Al');
    expect(errorFor(tester, 'Name'), isNull);
    expect(errors(tester), hasLength(5));
    expect(find.byType(SummaryCard), findsNothing);
  });

  testWidgets('name and email validators reject trimmed or malformed input', (
    tester,
  ) async {
    await startApp(tester);
    await enter(tester, 'Name', ' A ');
    expect(errorFor(tester, 'Name'), isNotNull);
    await enter(tester, 'Name', ' Al ');
    expect(errorFor(tester, 'Name'), isNull);

    for (final email in ['name.kbtu.kz', 'name@kbtu', 'name.surname@kbtu']) {
      await enter(tester, 'Email', email);
      expect(errorFor(tester, 'Email'), isNotNull);
    }
    await enter(tester, 'Email', 'name@kbtu.kz');
    expect(errorFor(tester, 'Email'), isNull);
  });

  testWidgets(
    'counter rebuild keeps text and confirm follows password changes',
    (tester) async {
      await startApp(tester);
      await enter(tester, 'Name', 'Ayan');
      await enter(tester, 'Password', '1234567');
      expect(find.text('7 of 8'), findsOneWidget);
      expect(errorFor(tester, 'Password'), isNotNull);

      await enter(tester, 'Password', '12345678');
      await enter(tester, 'Confirm password', '12345678');
      expect(errorFor(tester, 'Password'), isNull);
      expect(errorFor(tester, 'Confirm password'), isNull);

      await enter(tester, 'Password', '87654321');
      expect(errorFor(tester, 'Confirm password'), isNotNull);
      expect(editable(tester, 'Name').controller.text, 'Ayan');
      expect(editable(tester, 'Confirm password').controller.text, '12345678');
      expect(find.text('8 of 8'), findsOneWidget);
    },
  );

  testWidgets(
    'group and birth date validate and a cancelled picker keeps date',
    (tester) async {
      await startApp(tester);
      await agree(tester);
      await submit(tester);
      expect(errorFor(tester, 'Date of birth'), isNotNull);
      expect(find.text('Choose a group'), findsOneWidget);

      await chooseGroup(tester);
      expect(find.text('Choose a group'), findsNothing);
      await chooseBirthDate(tester);
      expect(editable(tester, 'Date of birth').controller.text, '20.10.2007');
      expect(errorFor(tester, 'Date of birth'), isNull);

      await openDatePicker(tester);
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(TextField),
        ),
        '06/15/2008',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(editable(tester, 'Date of birth').controller.text, '20.10.2007');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unchecked rules block both button and keyboard Done', (
    tester,
  ) async {
    await startApp(tester);
    await fillValidForm(tester);
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNull);

    await tester.ensureVisible(field('Confirm password'));
    await tester.showKeyboard(field('Confirm password'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(SummaryCard), findsNothing);
    expect(find.byType(Form), findsOneWidget);

    await agree(tester);
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNotNull);
    await agree(tester);
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNull);
  });

  testWidgets('keyboard actions move through fields and submit a valid form', (
    tester,
  ) async {
    await startApp(tester);
    await fillValidForm(tester);
    await agree(tester);
    await tester.ensureVisible(field('Name'));
    await tester.showKeyboard(field('Name'));
    expect(editable(tester, 'Name').focusNode.hasFocus, isTrue);

    for (final next in ['Email', 'Password', 'Confirm password']) {
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(editable(tester, next).focusNode.hasFocus, isTrue);
    }
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard insets keep confirm and the submit button reachable', (
    tester,
  ) async {
    await startApp(tester);
    await tester.ensureVisible(field('Confirm password'));
    await tester.showKeyboard(field('Confirm password'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(field('Confirm password'));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(field('Confirm password')).bottom,
      lessThanOrEqualTo(524),
    );

    await tester.ensureVisible(signUpButton);
    await tester.pumpAndSettle();
    expect(tester.getRect(signUpButton).bottom, lessThanOrEqualTo(524));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping outside a field removes keyboard focus', (tester) async {
    await startApp(tester);
    await tester.showKeyboard(field('Name'));
    await tester.pumpAndSettle();
    expect(editable(tester, 'Name').focusNode.hasFocus, isTrue);
    await tester.tapAt(const Offset(375, 25));
    await tester.pumpAndSettle();
    expect(editable(tester, 'Name').focusNode.hasFocus, isFalse);
  });

  testWidgets('successful summary contains submitted values and no password', (
    tester,
  ) async {
    await startApp(tester);
    await fillValidForm(tester);
    await agree(tester);
    await submit(tester);
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.byType(Form), findsNothing);
    expect(find.text('Ayan'), findsOneWidget);
    expect(find.text('ayan@kbtu.kz'), findsOneWidget);
    expect(find.text('IT-2303'), findsOneWidget);
    expect(find.text('20.10.2007'), findsOneWidget);
    expect(find.text('secret123'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(4));
  });

  testWidgets('summary uses its own width and changes to a grid at 600', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final cardWidth in [607.0, 608.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: cardWidth,
                child: const SummaryCard(
                  name: 'Alex',
                  email: 'alex@kbtu.kz',
                  group: 'IT-2303',
                  birthDate: '20.10.2007',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final localWidth = tester.getSize(find.byType(LayoutBuilder)).width;
      expect(localWidth, cardWidth - 8);
      expect(
        MediaQuery.sizeOf(tester.element(find.byType(SummaryCard))).width,
        1000,
      );
      expect(find.byType(ListTile), findsNWidgets(4));
      if (localWidth < 600) {
        expect(find.byType(GridView), findsNothing);
      } else {
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
        expect(delegate.childAspectRatio, 4);
        expect(grid.shrinkWrap, isTrue);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('start over clears all fields and can validate a new form', (
    tester,
  ) async {
    await startApp(tester);
    await fillValidForm(tester);
    await agree(tester);
    await submit(tester);
    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();

    for (final label in [
      'Name',
      'Email',
      'Password',
      'Confirm password',
      'Date of birth',
    ]) {
      expect(editable(tester, label).controller.text, isEmpty);
    }
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .value,
      isNull,
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(tester.widget<FilledButton>(signUpButton).onPressed, isNull);
    expect(find.text('0 of 8'), findsOneWidget);
    expect(errors(tester), isEmpty);
    expect(tester.takeException(), isNull);

    await agree(tester);
    await submit(tester);
    expect(errors(tester), hasLength(6));
    expect(tester.takeException(), isNull);
  });
}

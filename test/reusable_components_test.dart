import 'package:daily_task_app/core/widgets/category_chip.dart';
import 'package:daily_task_app/core/widgets/custom_button.dart';
import 'package:daily_task_app/core/widgets/custom_text_field.dart';
import 'package:daily_task_app/core/widgets/empty_state.dart';
import 'package:daily_task_app/core/widgets/loading_indicator.dart';
import 'package:daily_task_app/core/widgets/task_card.dart';
import 'package:daily_task_app/features/tasks/domain/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buttons invoke their callbacks', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppPrimaryButton(label: 'Save', onPressed: () => tapCount++),
              AppSecondaryButton(label: 'Cancel', onPressed: () => tapCount++),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.tap(find.text('Cancel'));

    expect(tapCount, 2);
  });

  testWidgets('custom text field accepts input', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Task name',
            hintText: 'Task name',
            controller: controller,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Plan the day');

    expect(controller.text, 'Plan the day');
  });

  testWidgets('task card and category chip report user selections', (
    tester,
  ) async {
    bool? completed;
    bool? categorySelected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TaskCard(
                task: const TaskEntity(id: 'test', title: 'Plan the day'),
                onToggle: (value) => completed = value,
              ),
              CategoryChip(
                label: 'Work',
                onSelected: (value) => categorySelected = value,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byType(FilterChip));

    expect(completed, isTrue);
    expect(categorySelected, isTrue);
  });

  testWidgets('empty and loading states render visible feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: EmptyState(
                  title: 'Nothing here yet',
                  message: 'Your tasks will appear here.',
                ),
              ),
              LoadingIndicator(label: 'Loading tasks'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Your tasks will appear here.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

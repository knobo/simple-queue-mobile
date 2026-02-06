import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to pump a widget wrapped in ProviderScope and MaterialApp
Future<void> pumpConsumerWidget(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: widget,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Helper to create a ProviderContainer with overrides
ProviderContainer createContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
  );
  addTearDown(container.dispose);
  return container;
}

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Spheroscopic/panorama/select_panorama.dart';

class DeferredSelector extends FileSelectorPlatform {
  late final result = Completer<List<XFile>>();

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) =>
      result.future;
}

void main() {
  late FileSelectorPlatform originalSelector;
  late DeferredSelector selector;

  setUp(() {
    originalSelector = FileSelectorPlatform.instance;
    selector = DeferredSelector();
    FileSelectorPlatform.instance = selector;
  });
  tearDown(() => FileSelectorPlatform.instance = originalSelector);

  testWidgets('cancelling file selection clears loading state', (tester) async {
    late BuildContext context;
    final status = ValueNotifier(false);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    final loading = PanoramaHandler.openPanorama([], status, context);
    expect(status.value, isTrue);
    selector.result.complete([]);
    await loading;
    expect(status.value, isFalse);
    status.dispose();
  });

  testWidgets('closing the caller during selection cancels navigation',
      (tester) async {
    late BuildContext context;
    final status = ValueNotifier(false);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    final loading = PanoramaHandler.openPanorama([], status, context);
    await tester.pumpWidget(const SizedBox());
    status.dispose();
    selector.result.complete([XFile('unused.jpg')]);
    await loading;
    expect(tester.takeException(), isNull);
  });
}

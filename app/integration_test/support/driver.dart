import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real-device steps: data arrives from the emulators asynchronously, so
/// every step waits for its widget instead of settling.
extension Driver on WidgetTester {
  static const _step = Duration(milliseconds: 200);

  Future<void> idle([Duration time = const Duration(milliseconds: 600)]) async {
    final end = DateTime.now().add(time);
    while (DateTime.now().isBefore(end)) {
      await Future<void>.delayed(_step);
      await pump();
    }
  }

  Future<void> waitFor(Finder finder,
          {Duration timeout = const Duration(seconds: 30)}) =>
      waitUntil(() => finder.evaluate().isNotEmpty, '$finder',
          timeout: timeout);

  Future<void> waitUntil(bool Function() condition, String description,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final end = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(end)) {
        throw TestFailure('Timed out waiting for $description');
      }
      await Future<void>.delayed(_step);
      await pump();
    }
  }

  /// Retries [check] until it stops throwing, for writes that land later.
  Future<void> eventually(Future<void> Function() check,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final end = DateTime.now().add(timeout);
    while (true) {
      try {
        return await check();
      } catch (_) {
        if (DateTime.now().isAfter(end)) rethrow;
        await idle(const Duration(milliseconds: 400));
      }
    }
  }

  /// Taps once nothing (a snackbar, a closing dialog) covers the target.
  Future<void> tapOn(Finder finder) async {
    await waitFor(finder);
    await ensureVisible(finder.first);
    await waitFor(finder.first.hitTestable(),
        timeout: const Duration(seconds: 10));
    await tap(finder.first);
    await idle();
  }

  Future<void> tapKey(String key) => tapOn(find.byKey(Key(key)));

  /// Taps a form's save button and waits for the form to close.
  Future<void> submit(String key) async {
    final button = find.byKey(Key(key));
    await tapOn(button);
    await waitUntil(() => button.evaluate().isEmpty, 'the $key form to close');
  }

  Future<void> type(String key, String text) async {
    final field = find.byKey(Key(key));
    await waitFor(field);
    await ensureVisible(field);
    await enterText(field, text);
    await idle(const Duration(milliseconds: 300));
  }

  /// Picks [option] from a dropdown, retrying the tap until the menu opens.
  Future<void> choose(String key, String option) async {
    hideKeyboard();
    final scrollables = find.byType(Scrollable);
    final before = scrollables.evaluate().length;
    for (var attempt = 0;; attempt++) {
      await tapKey(key);
      try {
        await waitUntil(
            () => scrollables.evaluate().length > before, 'the $key menu',
            timeout: const Duration(seconds: 3));
        break;
      } on TestFailure {
        if (attempt == 2) rethrow;
      }
    }
    final menu = scrollables.last;
    final item = find.descendant(of: menu, matching: find.text(option));
    await scrollUntilVisible(item, 60, scrollable: menu);
    await tap(item);
    await idle();
  }

  /// Opens a date or time picker field and accepts its preselected value.
  Future<void> acceptPicker(String key) async {
    await tapKey(key);
    await tapOn(find.text('OK'));
  }

  void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  /// The shared profile fields; [pickDates] for forms that start them empty.
  Future<void> fillProfile(
      {required String name,
      required String rank,
      bool pickDates = false}) async {
    await type('profile-name', name);
    await type('profile-appointment', 'Section IC');
    await choose('profile-ration', 'NM');
    await choose('profile-rank', rank);
    await choose('profile-blood', 'O+');
    await type('profile-company', 'Alpha');
    await type('profile-platoon', '1');
    await type('profile-section', '2');
    hideKeyboard();
    if (pickDates) {
      for (final key in ['profile-dob', 'profile-enlistment', 'profile-ord']) {
        await acceptPicker(key);
      }
    }
  }
}

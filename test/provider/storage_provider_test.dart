import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_queue_mobile/providers/storage_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsNotifier', () {
    test('loads default values', () async {
      final container = ProviderContainer();
      // Trigger build
      container.read(settingsProvider);
      
      // Wait for async init
      await Future.delayed(const Duration(milliseconds: 50));
      
      final state = container.read(settingsProvider);
      expect(state['darkMode'], false);
      expect(state['language'], 'nb');
    });

    test('loads saved values', () async {
      SharedPreferences.setMockInitialValues({
        'darkMode': true,
        'language': 'en',
      });

      final container = ProviderContainer();
      container.read(settingsProvider);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      final state = container.read(settingsProvider);
      expect(state['darkMode'], true);
      expect(state['language'], 'en');
    });

    test('updates values', () async {
      final container = ProviderContainer();
      final notifier = container.read(settingsProvider.notifier);
      
      // Wait for init
      await Future.delayed(const Duration(milliseconds: 50));
      
      await notifier.setDarkMode(true);
      
      final state = container.read(settingsProvider);
      expect(state['darkMode'], true);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('darkMode'), true);
    });
  });

  group('SavedQueuesNotifier', () {
    test('loads saved queues', () async {
      SharedPreferences.setMockInitialValues({
        'saved_queue_codes': ['Q1', 'Q2'],
      });

      final container = ProviderContainer();
      container.read(savedQueuesProvider);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      final state = container.read(savedQueuesProvider);
      expect(state, contains('Q1'));
      expect(state, contains('Q2'));
    });

    test('saves queue', () async {
      final container = ProviderContainer();
      final notifier = container.read(savedQueuesProvider.notifier);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      await notifier.saveQueue('Q1');
      
      final state = container.read(savedQueuesProvider);
      expect(state, contains('Q1'));
      expect(notifier.isSaved('Q1'), true);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('saved_queue_codes'), contains('Q1'));
    });

    test('removes queue', () async {
      SharedPreferences.setMockInitialValues({
        'saved_queue_codes': ['Q1'],
      });

      final container = ProviderContainer();
      final notifier = container.read(savedQueuesProvider.notifier);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      await notifier.removeQueue('Q1');
      
      final state = container.read(savedQueuesProvider);
      expect(state, isEmpty);
      expect(notifier.isSaved('Q1'), false);
    });
  });

  group('RecentQueuesNotifier', () {
    test('adds recent queue and limits to 10', () async {
      final container = ProviderContainer();
      final notifier = container.read(recentQueuesProvider.notifier);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      for (int i = 0; i < 15; i++) {
        await notifier.addRecent('Q$i');
      }
      
      final state = container.read(recentQueuesProvider);
      expect(state.length, 10);
      expect(state.first, 'Q14'); // Most recent first
    });
    
    test('clears recent queues', () async {
       final container = ProviderContainer();
       final notifier = container.read(recentQueuesProvider.notifier);
       await notifier.addRecent('Q1');
       
       await notifier.clearRecent();
       expect(container.read(recentQueuesProvider), isEmpty);
    });
  });
}

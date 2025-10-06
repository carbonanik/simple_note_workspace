import 'package:simple_note/core/sl/sl.dart';
import 'package:test/test.dart';

// Test classes
class TestService {
  final String id;
  bool isDisposed = false;

  TestService(this.id);

  void dispose() {
    isDisposed = true;
  }
}

class Logger {
  final List<String> logs = [];
  bool isDisposed = false;

  void log(String message) => logs.add(message);

  void dispose() {
    isDisposed = true;
  }
}

class Database {
  final Logger logger;
  bool isDisposed = false;

  Database(this.logger) {
    logger.log('Database initialized');
  }

  void dispose() {
    isDisposed = true;
    logger.log('Database disposed');
  }
}

void main() {
  late SL di;

  setUp(() {
    di = SL();
    di.dispose(); // Clean up from previous tests
  });

  group('Basic Registration and Retrieval', () {
    test('should register and get lazy dependency', () {
      di.register<TestService>(() => TestService('test1'));

      expect(di.isRegistered<TestService>(), true);
      final service = di.get<TestService>();
      expect(service.id, 'test1');
    });

    test('should register and get eager dependency', () {
      final result = di.register<TestService>(
        () => TestService('test2'),
        isLazy: false,
      );

      expect(result, isNotNull);
      expect(result!.id, 'test2');
      expect(di.isRegistered<TestService>(), true);
    });

    test('should return same instance for multiple get calls (singleton)', () {
      di.register<TestService>(() => TestService('test3'));

      final service1 = di.get<TestService>();
      final service2 = di.get<TestService>();

      expect(identical(service1, service2), true);
    });

    test('should throw exception when getting unregistered dependency', () {
      expect(() => di.get<TestService>(), throwsA(isA<Exception>()));
    });

    test('should return null with tryGet for unregistered dependency', () {
      final result = di.tryGet<TestService>();
      expect(result, isNull);
    });

    test('should return instance with tryGet for registered dependency', () {
      di.register<TestService>(() => TestService('test4'));
      final result = di.tryGet<TestService>();
      expect(result, isNotNull);
      expect(result!.id, 'test4');
    });
  });

  group('Named/Keyed Dependencies', () {
    test('should register and get dependency with key', () {
      di.register<TestService>(() => TestService('keyed1'), key: 'key1');

      final service = di.get<TestService>(key: 'key1');
      expect(service.id, 'keyed1');
      expect(di.isRegistered<TestService>(key: 'key1'), true);
    });

    test('should keep different instances for different keys', () {
      di.register<TestService>(() => TestService('key1'), key: 'key1');
      di.register<TestService>(() => TestService('key2'), key: 'key2');

      final service1 = di.get<TestService>(key: 'key1');
      final service2 = di.get<TestService>(key: 'key2');

      expect(service1.id, 'key1');
      expect(service2.id, 'key2');
      expect(identical(service1, service2), false);
    });

    test('should keep keyed and non-keyed instances separate', () {
      di.register<TestService>(() => TestService('default'));
      di.register<TestService>(() => TestService('keyed'), key: 'key1');

      final defaultService = di.get<TestService>();
      final keyedService = di.get<TestService>(key: 'key1');

      expect(defaultService.id, 'default');
      expect(keyedService.id, 'keyed');
      expect(identical(defaultService, keyedService), false);
    });

    test('should not find keyed dependency without key', () {
      di.register<TestService>(() => TestService('keyed'), key: 'key1');

      expect(() => di.get<TestService>(), throwsA(isA<Exception>()));
    });
  });

  group('Disposal and Cleanup', () {
    test('should call onDispose when reset is called', () {
      bool disposeCalled = false;

      di.register<TestService>(
        () => TestService('test'),
        onDispose: (instance) {
          disposeCalled = true;
          instance.dispose();
        },
        isLazy: false,
      );

      final service = di.get<TestService>();
      di.reset<TestService>();

      expect(disposeCalled, true);
      expect(service.isDisposed, true);
      expect(di.isRegistered<TestService>(), true); // Factory still registered
    });

    test('should recreate instance after reset (lazy re-initialization)', () {
      int createCount = 0;

      di.register<TestService>(() {
        createCount++;
        return TestService('test$createCount');
      });

      final service1 = di.get<TestService>();
      expect(service1.id, 'test1');

      di.reset<TestService>();

      final service2 = di.get<TestService>();
      expect(service2.id, 'test2');
      expect(identical(service1, service2), false);
    });

    test('should unregister dependency completely', () {
      di.register<TestService>(() => TestService('test'));
      di.get<TestService>(); // Create instance

      di.unregister<TestService>();

      expect(di.isRegistered<TestService>(), false);
      expect(() => di.get<TestService>(), throwsA(isA<Exception>()));
    });

    test('should call onDispose when unregister is called', () {
      bool disposeCalled = false;

      di.register<TestService>(
        () => TestService('test'),
        onDispose: (instance) {
          disposeCalled = true;
          instance.dispose();
        },
        isLazy: false,
      );

      di.unregister<TestService>();

      expect(disposeCalled, true);
    });

    test('should dispose all dependencies when dispose is called', () {
      final service1 = di.register<TestService>(
        () => TestService('test1'),
        onDispose: (instance) => instance.dispose(),
        isLazy: false,
      )!;

      final service2 = di.register<Logger>(
        () => Logger(),
        onDispose: (instance) => instance.dispose(),
        isLazy: false,
      )!;

      di.dispose();

      expect(service1.isDisposed, true);
      expect(service2.isDisposed, true);
      expect(di.isRegistered<TestService>(), false);
      expect(di.isRegistered<Logger>(), false);
    });
  });

  group('Dependency Injection with Dependencies', () {
    test('should inject dependencies', () {
      di.register<Logger>(() => Logger());
      di.register<Database>(() => Database(di.get<Logger>()));

      final db = di.get<Database>();
      expect(db.logger.logs, contains('Database initialized'));
    });

    test('should share singleton dependencies', () {
      di.register<Logger>(() => Logger());
      di.register<Database>(() => Database(di.get<Logger>()));

      final db1 = di.get<Database>();
      final db2 = di.get<Database>();
      final logger = di.get<Logger>();

      expect(identical(db1.logger, logger), true);
      expect(identical(db2.logger, logger), true);
    });
  });

  group('Edge Cases', () {
    test('should handle reset on non-existent instance', () {
      di.register<TestService>(() => TestService('test'));
      // Don't call get, so no instance exists

      expect(() => di.reset<TestService>(), returnsNormally);
    });

    test('should handle unregister on non-registered type', () {
      expect(() => di.unregister<TestService>(), returnsNormally);
    });

    test('should handle multiple types', () {
      di.register<TestService>(() => TestService('service'));
      di.register<Logger>(() => Logger());
      di.register<Database>(() => Database(di.get<Logger>()));

      expect(di.isRegistered<TestService>(), true);
      expect(di.isRegistered<Logger>(), true);
      expect(di.isRegistered<Database>(), true);

      expect(di.get<TestService>().id, 'service');
      expect(di.get<Logger>(), isA<Logger>());
      expect(di.get<Database>(), isA<Database>());
    });

    test('should handle keyed dependencies with disposal', () {
      bool key1Disposed = false;
      bool key2Disposed = false;

      di.register<TestService>(
        () => TestService('key1'),
        key: 'key1',
        onDispose: (_) => key1Disposed = true,
      );

      di.register<TestService>(
        () => TestService('key2'),
        key: 'key2',
        onDispose: (_) => key2Disposed = true,
      );

      di.get<TestService>(key: 'key1');
      di.get<TestService>(key: 'key2');

      di.reset<TestService>(key: 'key1');

      expect(key1Disposed, true);
      expect(key2Disposed, false);
    });
  });

  group('Singleton Behavior', () {
    test('should maintain singleton across DI() calls', () {
      final di1 = SL();
      di1.register<TestService>(() => TestService('singleton'));

      final di2 = SL();
      final service = di2.get<TestService>();

      expect(service.id, 'singleton');
      expect(identical(di1, di2), true);
    });
  });
}

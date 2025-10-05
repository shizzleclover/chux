import 'package:flutter_test/flutter_test.dart';
import 'package:chux/chux.dart';

void main() {
  group('Chunk', () {
    test('should initialize with correct value', () {
      final chunk = Chunk<int>(42);
      expect(chunk.get(), 42);
      chunk.destroy();
    });

    test('should update value and emit to stream', () async {
      final chunk = Chunk<int>(0);
      
      expectLater(
        chunk.stream,
        emitsInOrder([1, 2, 3]),
      );

      chunk.set(1);
      chunk.set(2);
      chunk.set(3);

      await Future.delayed(const Duration(milliseconds: 100));
      chunk.destroy();
    });

    test('should not emit when value is the same', () async {
      final chunk = Chunk<int>(5);
      
      expectLater(
        chunk.stream,
        emitsInOrder([10]),
      );

      chunk.set(5); // Same value, should not emit
      chunk.set(10); // Different value, should emit

      await Future.delayed(const Duration(milliseconds: 100));
      chunk.destroy();
    });

    test('update method should modify value correctly', () {
      final chunk = Chunk<int>(10);
      chunk.update((value) => value + 5);
      
      expect(chunk.get(), 15);
      chunk.destroy();
    });

    test('should throw when accessing destroyed chunk', () {
      final chunk = Chunk<int>(0);
      chunk.destroy();

      expect(() => chunk.get(), throwsA(isA<ChunkDestroyedException>()));
      expect(() => chunk.set(1), throwsA(isA<ChunkDestroyedException>()));
    });

    test('isDestroyed should return correct state', () {
      final chunk = Chunk<int>(0);
      expect(chunk.isDestroyed, false);
      
      chunk.destroy();
      expect(chunk.isDestroyed, true);
    });

    test('should handle complex types', () {
      final chunk = Chunk<Map<String, dynamic>>({'count': 0});
      
      chunk.update((value) => {...value, 'count': value['count'] + 1});
      
      expect(chunk.get()['count'], 1);
      chunk.destroy();
    });

    test('should handle nullable types', () {
      final chunk = Chunk<int?>(null);
      expect(chunk.get(), null);
      
      chunk.set(42);
      expect(chunk.get(), 42);
      
      chunk.set(null);
      expect(chunk.get(), null);
      
      chunk.destroy();
    });
  });
}
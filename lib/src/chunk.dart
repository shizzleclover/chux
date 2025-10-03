import 'dart:async';

class Chunk<T> {
  /// The curent state value
  T _value;

  ///stream controller for state changes
  final StreamController<T> _controller = StreamController<T>.broadcast();

  bool _isDestroyed = false;

  Chunk(this._value);

  T get() {
    _assertNotDestroyed();
    return _value;
  }

  void set(T newValue) {
    _assertNotDestroyed();
    if (_value != newValue) {
      _value = newValue;
      _controller.add(_value);
    }
  }

  void update(T Function(T current) updater) {
    set(updater(get()));
  }

  void destroy() {
    if (!_isDestroyed) {
      _isDestroyed = true;
      _controller.close();
    }
  }

  Stream<T> get stream => _controller.stream;

  bool get isDestroyed => _isDestroyed;

  void _assertNotDestroyed() {
    if (_isDestroyed) {
      throw ChunkDestroyedException();
    }
  }
}

class ChunkDestroyedException implements Exception {
  final String message;

  ChunkDestroyedException([
    this.message =
        'Cannot use a destroyed Chunk. Create a new instance instead.',
  ]);

  @override
  String toString() => 'ChunkDestroyedException: $message';
}

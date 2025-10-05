import 'dart:async';
import 'package:flutter/widgets.dart';
import 'chunk.dart';

/// A widget that rebuilds when a [Chunk] changes.
/// 
/// Example:
/// ```dart
/// final counter = Chunk<int>(0);
/// 
/// ChuxBuilder<int>(
///   chunk: counter,
///   builder: (context, value) {
///     return Text('Count: $value');
///   },
/// );
/// ```
class ChuxBuilder<T> extends StatefulWidget {
  /// The chunk to listen to
  final Chunk<T> chunk;

  /// Builder function that receives the current value
  final Widget Function(BuildContext context, T value) builder;

  /// Optional callback when chunk updates
  final void Function(BuildContext context, T value)? onUpdate;

  const ChuxBuilder({
    Key? key,
    required this.chunk,
    required this.builder,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<ChuxBuilder<T>> createState() => _ChuxBuilderState<T>();
}

class _ChuxBuilderState<T> extends State<ChuxBuilder<T>> {
  late T _currentValue;
  late StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.chunk.get();
    _subscription = widget.chunk.stream.listen(_onChunkUpdate);
  }

  void _onChunkUpdate(T newValue) {
    if (mounted) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onUpdate?.call(context, newValue);
    }
  }

  @override
  void didUpdateWidget(ChuxBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chunk != widget.chunk) {
      _subscription.cancel();
      _currentValue = widget.chunk.get();
      _subscription = widget.chunk.stream.listen(_onChunkUpdate);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
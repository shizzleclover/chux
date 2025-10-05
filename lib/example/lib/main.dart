import 'package:flutter/material.dart';
import 'package:chux/chux.dart';

void main() {
  runApp(const ChuxCounterApp());
}

class ChuxCounterApp extends StatelessWidget {
  const ChuxCounterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chux Counter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // Create a chunk of state - that's it!
  final counter = Chunk<int>(0);

  @override
  void dispose() {
    counter.destroy(); // Clean up when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chux Counter'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Reactive UI with ChuxBuilder
            ChuxBuilder<int>(
              chunk: counter,
              builder: (context, value) {
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                );
              },
              onUpdate: (context, value) {
                // Optional: react to updates
                if (value == 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You reached 10! 🎉')),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => counter.update((v) => v - 1),
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: () => counter.set(0),
                  tooltip: 'Reset',
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: () => counter.update((v) => v + 1),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
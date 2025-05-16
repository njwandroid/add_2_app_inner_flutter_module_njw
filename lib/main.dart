// lib/main.dart
import 'dart:js_interop'; // Required for JS interop features
import 'dart:js_interop_unsafe'; // Required for globalContext.setProperty
import 'package:flutter/material.dart';

// Global ValueNotifier to hold the name.
// This allows the JS interface to update the name and the Flutter UI to react to it.
// Initialize with a default name.
final ValueNotifier<String> nameNotifier = ValueNotifier<String>("World");

// This class will be exposed to JavaScript.
// Methods within this class annotated with @JSExport can be called from JS.
@JSExport() // Marks the class as exportable to JavaScript.
class MyFlutterAppJsInterface {
  // This is the method that JavaScript will call.
  // It receives a JSString, converts it to a Dart String, and updates the notifier.
  @JSExport('updateName') // Exposes this method as 'updateName' on the JS object.
  void updateNameInFlutter(JSString nameFromJs) {
    nameNotifier.value = nameFromJs.toDart; // Convert JSString to Dart String and update
    // Optional: Print to console to verify data reception in Flutter.
    debugPrint('Flutter app received name from JS: ${nameNotifier.value}');
  }
}

void main() {
  // Create an instance of our JS interface class.
  final jsInterfaceInstance = MyFlutterAppJsInterface();

  // Expose the instance to JavaScript.
  // It will be available as `window.myFlutterApp` in the browser's JavaScript context.
  // 'myFlutterApp'.toJS converts the Dart string to a JSString for the property name.
  // createJSInteropWrapper wraps the Dart object for JS consumption.
  globalContext.setProperty('myFlutterApp'.toJS, createJSInteropWrapper(jsInterfaceInstance));

  // Run the Flutter application.
  runApp(const MyApp());
}

// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Add-to-App POC Phase 1',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Changed theme color for distinction
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Using a common web font
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false, // Hides the debug banner
    );
  }
}

// The home page widget for the application.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Add a listener to the nameNotifier.
    // When the notifier's value changes, _onNameChanged will be called.
    nameNotifier.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed to prevent memory leaks.
    nameNotifier.removeListener(_onNameChanged);
    super.dispose();
  }

  // Callback function for the notifier.
  // It calls setState to trigger a UI rebuild, reflecting the new name.
  void _onNameChanged() {
    if (mounted) { // Check if the widget is still in the tree
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Says Hello'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // So the container wraps content
            children: <Widget>[
              Image.network( // Adding a Flutter logo for visual appeal
                'https://flutter.dev/assets/flutter-lockup-1caf6476beed760ac9328458c644a6ba7251cc7921921a7d28272d77d52de098.svg',
                height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.flutter_dash, size: 80),
              ),
              const SizedBox(height: 20),
              // Display the greeting. Uses nameNotifier.value to get the current name.
              Text(
                'Hello, ${nameNotifier.value} from Flutter!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.teal.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '(This content is rendered by Flutter)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200], // Background for the whole page
    );
  }
}

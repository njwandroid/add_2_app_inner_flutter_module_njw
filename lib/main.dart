// lib/main.dart
import 'dart:js_interop'; // Required for JS interop features
import 'dart:js_interop_unsafe'; // Required for globalContext.setProperty
import 'package:flutter/material.dart';

// This allows the JS interface to update the name and the Flutter UI to react to it.
final ValueNotifier<String> nameNotifier = ValueNotifier<String>("World");

// Methods within this class annotated with @JSExport can be called from JS.
@JSExport() // Marks the class as exportable to JavaScript.
class MyFlutterAppJsInterface {
  // JS receives a JSString, converts it to a Dart String, and updates the notifier.
  @JSExport('updateName') // Exposes this method as 'updateName' on the JS object.
  void updateNameInFlutter(JSString nameFromJs) {
    nameNotifier.value = nameFromJs.toDart; // Convert JSString to Dart String and update
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) => MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal, // Changed theme color for distinction
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Using a common web font
      ),
      home: MyHomePage(),
    );
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    nameNotifier.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    nameNotifier.removeListener(_onNameChanged);
    super.dispose();
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Says Hello'),
      ),
      body: Center(
        child: Column(spacing: 10, mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlutterLogoWidget(),
            Text('..Hello, ${nameNotifier.value} from Flutter!',
             style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.teal.shade700)
            ),
            Text('(This content is rendered by Flutter)'),
          ],
        ),
      ),
    );
}

class FlutterLogoWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) => Image.network( // Adding a Flutter logo for visual appeal
      'https://flutter.dev/assets/flutter-lockup-1caf6476beed760ac9328458c644a6ba7251cc7921921a7d28272d77d52de098.svg',
      height: 80,
      errorBuilder: (_, __, ___) => const Icon(Icons.flutter_dash, size: 80),
    );
}
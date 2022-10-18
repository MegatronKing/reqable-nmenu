import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';
import 'package:native_context_menu/native_context_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? action;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NativeContextMenuRegion(
          onDismissed: () => setState(() => action = 'Menu was dismissed'),
          onItemSelected: (item) => setState(() {
            action = '${item.title} was selected';
          }),
          menuItems: const [
            NativeMenuItem(
              title: 'First item',
              activator: SingleActivator(
                LogicalKeyboardKey.keyA,
                shift: true
              )
            ),
            NativeMenuItem(title: 'Second item', isEnabled: false),
            NativeMenuItem(
              title: 'Third item with submenu',
              items: [
                NativeMenuItem(title: 'First subitem'),
                NativeMenuItem(title: 'Second subitem'),
                NativeMenuItem(title: 'Third subitem'),
              ],
            ),
            NativeMenuItem(
              title: 'Fourth item',
              activator: SingleActivator(
                LogicalKeyboardKey.keyZ,
                alt: true
              )
            ),
            NativeMenuItem(
              title: 'Fifth item',
              activator: SingleActivator(
                LogicalKeyboardKey.keyB,
              )
            ),
          ],
          child: Center(
            child: Text(action ?? 'Right click me'),
          ),
        ),
      ),
    );
  }
}

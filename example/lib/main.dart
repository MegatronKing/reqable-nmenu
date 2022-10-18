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
          menuItems: [
            NativeMenuItem(
              title: 'First item',
              activator: const SingleActivator(
                LogicalKeyboardKey.keyA,
                shift: true
              ),
              onTap: () {
                setState(() => action = 'First item');
              }
            ),
            NativeMenuItem(
              title: 'Second item selected',
              isEnabled: false,
              onTap: () {
                setState(() => action = 'Second item selected');
              }
            ),
            const NativeSeparatorMenuItem(),
            NativeMenuItem(
              title: 'Third item with submenu',
              items: [
                NativeMenuItem(
                  title: 'First subitem',
                  onTap: () {
                    setState(() => action = 'First subitem selected');
                  }
                ),
                NativeMenuItem(
                  title: 'Second subitem',
                  onTap: () {
                    setState(() => action = 'Second subitem selected');
                  }
                ),
                NativeMenuItem(
                  title: 'Third subitem',
                  isEnabled: false,
                  onTap: () {
                    setState(() => action = 'Third subitem selected');
                  }
                ),
              ],
            ),
            NativeMenuItem(
              title: 'Fourth item',
              activator: const SingleActivator(
                LogicalKeyboardKey.keyZ,
                alt: true
              ),
              onTap: () {
                setState(() => action = 'Fourth item selected');
              }
            ),
            NativeMenuItem(
              title: 'Fifth item',
              activator: const SingleActivator(
                LogicalKeyboardKey.keyB,
              ),
              onTap: () {
                setState(() => action = 'Fifth item selected');
              }
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

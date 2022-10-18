import 'package:flutter/widgets.dart';

import 'native_context_menu_channel.dart';

class NativeMenuItem {
  
  const NativeMenuItem({
    required this.title,
    this.isEnabled = true,
    this.items = const <NativeMenuItem>[],
    this.activator,
  });

  final String title;
  final bool isEnabled;
  final List<NativeMenuItem> items;
  final SingleActivator? activator;

  bool get hasSubitems => items.isNotEmpty;

}

class ShowMenuArgs {

  ShowMenuArgs({
    required this.devicePixelRatio,
    required this.position,
    required this.items,
  });

  final double devicePixelRatio;
  final Offset position;
  final List<NativeMenuItem> items;

}

Future<NativeMenuItem?> showContextMenu(ShowMenuArgs args) {
  return NativeContextMenuChannel.instance.showContextMenu(args);
}
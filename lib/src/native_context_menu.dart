import 'package:flutter/widgets.dart';

import 'native_context_menu_channel.dart';

class NativeMenuItem {

  const NativeMenuItem({
    required this.title,
    this.isEnabled = true,
    this.isSeparator = false,
    this.items = const <NativeMenuItem>[],
    this.activator,
    this.onTap,
  });

  final String title;
  final bool isEnabled;
  final bool isSeparator;
  final List<NativeMenuItem> items;
  final SingleActivator? activator;
  final VoidCallback? onTap;

  bool get hasSubitems => items.isNotEmpty;

}

class NativeSeparatorMenuItem extends NativeMenuItem {

  const NativeSeparatorMenuItem() : super(
    title: '',
    isEnabled: false,
    isSeparator: true,
  );

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

void showContextMenu({
  required BuildContext context,
  required Offset position,
  required List<NativeMenuItem> items,
  VoidCallback? onDismissed,
}) {
  NativeContextMenuChannel.instance.showContextMenu(
    ShowMenuArgs(
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      position: position,
      items: items,
    ),
  ).then((selectedItem) {
    if (selectedItem != null) {
      selectedItem.onTap?.call();
    } else {
      onDismissed?.call();
    }
  });
}
import 'package:flutter/widgets.dart';
import 'native_context_menu.dart';

class NativeContextMenuRegion extends StatelessWidget {

  const NativeContextMenuRegion({
    Key? key,
    required this.menuItems,
    required this.child,
    this.onDismissed,
  }) : super(key: key);

  final List<NativeMenuItem> menuItems;
  final Widget child;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        showContextMenu(
          context: context,
          position: details.globalPosition,
          items: menuItems,
        );
      },
      child: child,
    );
  }

}

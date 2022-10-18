import 'package:flutter/widgets.dart';
import 'native_context_menu.dart';

class NativeContextMenuRegion extends StatelessWidget {

  const NativeContextMenuRegion({
    Key? key,
    required this.child,
    required this.menuItems,
    this.onDismissed,
    this.menuOffset = Offset.zero,
  }) : super(key: key);

  final Widget child;
  final List<NativeMenuItem> menuItems;
  final Offset menuOffset;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        showContextMenu(
          context: context,
          position: details.globalPosition + menuOffset,
          items: menuItems,
        );
      },
      child: child,
    );
  }

}

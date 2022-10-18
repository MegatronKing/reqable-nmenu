import 'package:flutter/widgets.dart';
import 'native_context_menu.dart';

class NativeContextMenuRegion extends StatelessWidget {

  const NativeContextMenuRegion({
    Key? key,
    required this.child,
    required this.menuItems,
    this.onItemSelected,
    this.onDismissed,
    this.menuOffset = Offset.zero,
  }) : super(key: key);

  final Widget child;
  final List<NativeMenuItem> menuItems;
  final Offset menuOffset;
  final void Function(NativeMenuItem item)? onItemSelected;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final Offset position = details.globalPosition + menuOffset;
        final NativeMenuItem? selectedItem = await showContextMenu(
          ShowMenuArgs(
            devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
            position: position,
            items: menuItems,
          ),
        );
        if (selectedItem != null) {
          onItemSelected?.call(selectedItem);
        } else {
          onDismissed?.call();
        }
      },
      child: child,
    );
  }

}

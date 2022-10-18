import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter/widgets.dart';
import 'native_context_menu.dart';

/// Method channel name of the plugin.
const String _kChannelName = 'native_context_menu';

/// Show menu call.
/// Shows context menu at passed position or cursor position.
/// Pass `devicePixelRatio` and `position` from Dart to show menu at specified position.
/// If it is not defined, native code will show the context menu at the cursor's position.
const String _kShowMenu = "showMenu";

/// Called when an item is selected from the context menu.
const String _kOnItemSelected = "onItemSelected";

/// Called when menu is dismissed without clicking any item.
const String _kOnMenuDismissed = "onMenuDismissed";


class NativeContextMenuChannel {
  /// Private constructor.
  NativeContextMenuChannel._();

  final MethodChannel _channel = const MethodChannel(_kChannelName);

  /// The static instance of the menu channel.
  static final NativeContextMenuChannel instance = NativeContextMenuChannel._();

  Future<NativeMenuItem?> showContextMenu(ShowMenuArgs args) async {
    final List<_NativeMenuItem> _items = _wrapWithId(0, args.items);
    final _ShowMenuArgs _args = _ShowMenuArgs(args.devicePixelRatio, args.position, _items);
    final Completer<int?> completer = Completer<int?>();
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case _kOnItemSelected: {
          completer.complete(call.arguments);
          break;
        }
        case _kOnMenuDismissed: {
          completer.complete(null);
          break;
        }
        default: {
          completer.completeError(
            Exception('$_kChannelName: Invalid method call received.'),
          );
        }
      }
    });
    _channel.invokeMethod(_kShowMenu, _args.toJson());
    final int? id = await completer.future;
    return id != null ? _args.findOriginItemById(id) : null;
  }

  List<_NativeMenuItem> _wrapWithId(int index, List<NativeMenuItem> items) {
    final List<_NativeMenuItem> results = [];
    for (final NativeMenuItem item in items) {
      results.add( _NativeMenuItem(
        id: ++index,
        title: item.title,
        isEnabled: item.isEnabled,
        isSeparator: item.isSeparator,
        activator: item.activator,
        items: _wrapWithId(index * 100, item.items),
        origin: item,
      ));
    }
    return results;
  }


}

class _NativeMenuItem {

  const _NativeMenuItem({
    required this.id,
    required this.title,
    required this.isEnabled,
    required this.isSeparator,
    required this.activator,
    required this.items,
    required this.origin,
  });

  final int id;
  final String title;
  final bool isEnabled;
  final bool isSeparator;
  final SingleActivator? activator;
  final List<_NativeMenuItem> items;
  final NativeMenuItem origin;

  NativeMenuItem? findOriginItemById(int id) {
    if (this.id == id) {
      return origin;
    }
    for (final _NativeMenuItem item in items) {
      NativeMenuItem? result = item.findOriginItemById(id);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isEnabled': isEnabled,
      'isSeparator': isSeparator,
      'keyId': activator?.keyId,
      'keyShift': activator?.shift ?? false,
      'keyMeta': activator?.meta ?? false,
      'keyControl': activator?.control ?? false,
      'keyAlt': activator?.alt ?? false,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

}

class _ShowMenuArgs {
  _ShowMenuArgs(
    this.devicePixelRatio,
    this.position,
    this.items,
  );

  final double devicePixelRatio;
  final Offset position;
  final List<_NativeMenuItem> items;

  Map<String, dynamic> toJson() {
    return {
      'devicePixelRatio': devicePixelRatio,
      'position': <double>[position.dx, position.dy],
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  NativeMenuItem? findOriginItemById(int id) {
    for (final _NativeMenuItem item in items) {
      NativeMenuItem? result = item.findOriginItemById(id);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

}

extension _SingleActivatorExtension on SingleActivator {

  dynamic get keyId {
    String label = trigger.keyLabel;
    if (Platform.isMacOS) {
      if (label.length == 1) {
        label = label.toLowerCase();
      }
    }
    return label;
  }

}
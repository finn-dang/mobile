import 'package:flutter/material.dart';

/// Cho phép [Header] / menu mở dock chat mà không cần `BuildContext` của [ShellLayout].
class ChatDockScope extends InheritedWidget {
  final VoidCallback openDock;

  const ChatDockScope({
    super.key,
    required this.openDock,
    required super.child,
  });

  static ChatDockScope? _scopeFrom(BuildContext context) {
    final el = context.getElementForInheritedWidgetOfExactType<ChatDockScope>();
    final w = el?.widget;
    return w is ChatDockScope ? w : null;
  }

  static void open(BuildContext context) {
    _scopeFrom(context)?.openDock();
  }

  @override
  bool updateShouldNotify(ChatDockScope oldWidget) => false;
}

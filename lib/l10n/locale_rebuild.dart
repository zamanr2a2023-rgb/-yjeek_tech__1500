import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';

/// Rebuilds the whole routed tree when the app language changes.
///
/// UI copy uses [L10n.tr] (no BuildContext), so screens would otherwise keep
/// the English strings from their last build.
class LocaleTreeRebuilder extends ConsumerStatefulWidget {
  const LocaleTreeRebuilder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LocaleTreeRebuilder> createState() =>
      _LocaleTreeRebuilderState();
}

class _LocaleTreeRebuilderState extends ConsumerState<LocaleTreeRebuilder> {
  int? _revision;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    if (_revision != null && _revision != locale.revision) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _markDirty(context);
      });
    }
    _revision = locale.revision;
    return widget.child;
  }

  void _markDirty(BuildContext context) {
    void visit(Element el) {
      el.markNeedsBuild();
      el.visitChildren(visit);
    }

    context.visitChildElements(visit);
  }
}

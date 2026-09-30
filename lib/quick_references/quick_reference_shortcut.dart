import 'package:flutter/material.dart';

/// Observes the active route, including unnamed detail routes and dialogs.
class QuickReferenceRouteObserver extends NavigatorObserver {
  final visible = ValueNotifier<bool>(false);
  final List<Route<dynamic>> _routes = [];
  static const _hidden = {
    '/',
    '/account',
    '/subscribe',
    '/ce-halo',
    '/ce-purchase',
    '/quick-references',
    '/quick-reference-detail',
  };

  void _update() {
    final route = _routes.isEmpty ? null : _routes.last;
    final path = Uri.tryParse(route?.settings.name ?? '')?.path;
    final show = route is PageRoute && !_hidden.contains(path);
    // Navigator can notify during build; defer the overlay update.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visible.value = show;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
    _update();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _update();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _update();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0) {
      if (newRoute == null) {
        _routes.removeAt(index);
      } else {
        _routes[index] = newRoute;
      }
    } else if (newRoute != null) {
      _routes.add(newRoute);
    }
    _update();
  }
}

class QuickReferenceShortcut extends StatefulWidget {
  const QuickReferenceShortcut({
    super.key,
    required this.child,
    required this.observer,
    required this.navigatorKey,
  });
  final Widget child;
  final QuickReferenceRouteObserver observer;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<QuickReferenceShortcut> createState() => _QuickReferenceShortcutState();
}

class _QuickReferenceShortcutState extends State<QuickReferenceShortcut> {
  late final OverlayEntry _entry = OverlayEntry(builder: _buildContents);

  @override
  void didUpdateWidget(QuickReferenceShortcut oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  void dispose() {
    _entry.remove();
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);

  Widget _buildContents(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: widget.observer.visible,
    builder: (context, visible, _) => Stack(
      children: [
        widget.child,
        if (visible && MediaQuery.viewInsetsOf(context).bottom == 0)
          Positioned(
            right: 18,
            bottom: MediaQuery.paddingOf(context).bottom + 18,
            child: Tooltip(
              message: 'Quick References',
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCFAF6),
                  foregroundColor: const Color(0xFF205D9F),
                  surfaceTintColor: Colors.transparent,
                  elevation: 2,
                  shadowColor: const Color(0x3308192B),
                  minimumSize: const Size(112, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(
                    side: BorderSide(color: Color(0xFFDCD5C9)),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => widget.navigatorKey.currentState?.pushNamed(
                  '/quick-references',
                ),
                icon: const ExcludeSemantics(
                  child: CustomPaint(
                    size: Size(18, 24),
                    painter: _QuickReferenceBoltPainter(),
                  ),
                ),
                label: const Text(
                  'Quick Ref',
                  semanticsLabel: 'Quick References',
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Original slender bolt used in the selected option D concept.
class _QuickReferenceBoltPainter extends CustomPainter {
  const _QuickReferenceBoltPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 28, size.height / 34);
    final bolt = Path()
      ..moveTo(16, 2)
      ..lineTo(4, 19)
      ..lineTo(13, 19)
      ..lineTo(11, 32)
      ..lineTo(24, 13)
      ..lineTo(14, 13)
      ..close();
    canvas.drawPath(bolt, Paint()..color = const Color(0xFF205D9F));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QuickReferenceBoltPainter oldDelegate) => false;
}

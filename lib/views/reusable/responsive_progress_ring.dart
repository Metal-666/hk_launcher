import 'package:fluent_ui/fluent_ui.dart';

class ResponsiveProgressRing extends StatelessWidget {
  final int fraction;

  const ResponsiveProgressRing({Key? key, this.fraction = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) => CustomSingleChildLayout(
      delegate: _LayoutDelegate(3), child: const ProgressRing());
}

class _LayoutDelegate extends SingleChildLayoutDelegate {
  final int fraction;
  Size? lastSize;

  _LayoutDelegate(this.fraction);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double side = constraints.biggest.shortestSide / fraction;
    return BoxConstraints.expand(width: side, height: side);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
      (size.width / 2) - (childSize.width / 2),
      (size.height / 2) - (childSize.height / 2));

  @override
  Size getSize(BoxConstraints constraints) => lastSize = constraints.biggest;

  @override
  bool shouldRelayout(covariant _LayoutDelegate oldDelegate) =>
      oldDelegate.lastSize != lastSize;
}

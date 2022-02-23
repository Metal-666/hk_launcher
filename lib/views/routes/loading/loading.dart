import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/loading/bloc.dart';
import '../../../bloc/loading/state.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocListener<LoadingBloc, LoadingState>(
        listener: (context, state) {
          if (state.loaded) {
            GoRouter.of(context).go('/');
          }
        },
        child: CustomSingleChildLayout(
            delegate: LoadingPageProgressLayoutDelegate(fraction: 3),
            child: const ProgressRing()),
      );
}

class LoadingPageProgressLayoutDelegate extends SingleChildLayoutDelegate {
  Size? lastSize;
  int fraction;

  LoadingPageProgressLayoutDelegate({required this.fraction});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double side = constraints.biggest.shortestSide / fraction;
    return BoxConstraints.expand(width: side, height: side);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
      (size.width / 2) - (childSize.width / 2),
      (size.height / 2) - (childSize.height / 2));

  @override
  Size getSize(BoxConstraints constraints) => lastSize = constraints.biggest;

  @override
  bool shouldRelayout(
          covariant LoadingPageProgressLayoutDelegate oldDelegate) =>
      oldDelegate.lastSize != lastSize;
}

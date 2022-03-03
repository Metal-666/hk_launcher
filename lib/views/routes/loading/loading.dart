import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hk_launcher/views/reusable/responsive_progress_ring.dart';

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
      child: const ScaffoldPage(content: ResponsiveProgressRing()));
}

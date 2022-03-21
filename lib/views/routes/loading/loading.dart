import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../reusable/responsive_progress_ring.dart';

import '../../../bloc/loading/bloc.dart';
import '../../../bloc/loading/events.dart';
import '../../../bloc/loading/state.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocConsumer<LoadingBloc, LoadingState>(
        listener: (context, state) {
          if (state.loaded) {
            GoRouter.of(context).go('/');
          }
        },
        builder: (context, state) => state.disclaimer
            ? ContentDialog(
                title: const Text('Read this!'),
                backgroundDismiss: false,
                content: RichText(
                  text: TextSpan(
                    style: FluentTheme.of(context).typography.bodyLarge,
                    children: const <InlineSpan>[
                      TextSpan(
                          text:
                              'Since this application makes separate save files for all modpacks that you create, your original saves folder will be deleted. The '),
                      WidgetSpan(child: Icon(FluentIcons.folder)),
                      TextSpan(
                          text:
                              ' button below will take you to its location - move it somewhere safe. You can later copy it to a specific modpack.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: IconButton(
                          icon: const Icon(FluentIcons.folder),
                          onPressed: () => context
                              .read<LoadingBloc>()
                              .add(OpenSavesFolder()),
                        ),
                      ),
                      Button(
                        child: const Text('Okay'),
                        onPressed: () => context
                            .read<LoadingBloc>()
                            .add(DismissedDisclaimer()),
                      ),
                    ],
                  ),
                ],
              )
            : const ScaffoldPage(content: ResponsiveProgressRing()),
      );
}

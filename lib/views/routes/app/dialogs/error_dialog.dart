import 'package:fluent_ui/fluent_ui.dart';

import '../../../../util/translations.dart';

// Uhh... this is a dialog.. with 2 text boxes... I guess?
class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;

  final void Function() onClose;

  const ErrorDialog(
    this.title,
    this.content,
    this.onClose, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ContentDialog(
        title: Text(title),
        backgroundDismiss: false,
        content: Text(
          content,
          style: FluentTheme.of(context).typography.bodyLarge,
        ),
        actions: <Widget>[
          Button(
            child: Text(tr([
              'dialogs',
              'error',
              'actions',
              'close',
            ])),
            onPressed: onClose,
          ),
        ],
      );
}

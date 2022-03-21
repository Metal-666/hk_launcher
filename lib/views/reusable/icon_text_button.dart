import 'package:fluent_ui/fluent_ui.dart';

// Essentially combines IconButton and TextButton. Why is this not part of fluent_ui???
class IconTextButton extends StatelessWidget {
  final IconData iconData;
  final String buttonText;
  final Function()? buttonCallback;
  final ButtonType buttonType;

  const IconTextButton(
    this.iconData,
    this.buttonText,
    this.buttonCallback, {
    this.buttonType = ButtonType.simple,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Row child = Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(iconData),
        ),
        Text(buttonText)
      ],
    );

    switch (buttonType) {
      case ButtonType.simple:
        {
          return Button(child: child, onPressed: buttonCallback);
        }
      case ButtonType.filled:
        {
          return FilledButton(child: child, onPressed: buttonCallback);
        }
      case ButtonType.text:
        {
          return TextButton(child: child, onPressed: buttonCallback);
        }
    }
  }
}

enum ButtonType { simple, filled, text }

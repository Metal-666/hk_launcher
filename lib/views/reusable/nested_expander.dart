import 'package:fluent_ui/fluent_ui.dart';

// Puts one Expander inside another. Yes, very useful
class NestedExpander extends StatelessWidget {
  final Widget headerOuter;
  final Widget headerInner;
  final Widget contentOuter;
  final Widget contentInner;

  const NestedExpander({
    Key? key,
    required this.headerOuter,
    required this.headerInner,
    required this.contentOuter,
    required this.contentInner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expander(
        header: headerOuter,
        content: Column(
          children: [
            contentOuter,
            const SizedBox(height: 15),
            Expander(
              header: headerInner,
              content: contentInner,
            ),
          ],
        ),
      );
}

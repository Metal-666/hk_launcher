abstract class MainEvent {}

class Navigate extends MainEvent {
  final int index;

  Navigate(this.index);
}

class AppLoaded extends MainEvent {}

class OpenGitHub extends MainEvent {}

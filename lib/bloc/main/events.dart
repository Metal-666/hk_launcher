abstract class MainEvent {}

class Navigate extends MainEvent {
  int index;

  Navigate(this.index);
}

class AppLoaded extends MainEvent {}

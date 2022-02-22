abstract class MainEvent {}

class Navigate extends MainEvent {
  int index;

  Navigate(this.index);
}

class AppLoaded extends MainEvent {}

class HKPathProvided extends MainEvent {
  String path;

  HKPathProvided(this.path);
}

class HKPathDialogDismissed extends MainEvent {}

class PickHKFolder extends MainEvent {}

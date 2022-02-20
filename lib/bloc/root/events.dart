abstract class RootEvent {}

class Navigate extends RootEvent {
  int index;

  Navigate(this.index);
}

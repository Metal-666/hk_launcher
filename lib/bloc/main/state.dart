class MainState {
  int navIndex;

  MainState(this.navIndex);

  MainState copyWith({int Function()? navIndex}) =>
      MainState(navIndex == null ? this.navIndex : navIndex.call());
}

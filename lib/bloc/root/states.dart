class RootState {
  int navIndex;

  RootState(this.navIndex);

  RootState copyWith({int Function()? navIndex}) =>
      RootState(navIndex == null ? this.navIndex : navIndex.call());
}

class MainState {
  final int navIndex;

  const MainState(this.navIndex);

  MainState copyWith({int Function()? navIndex}) => MainState(
        navIndex == null ? this.navIndex : navIndex.call(),
      );
}

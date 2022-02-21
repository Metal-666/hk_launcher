class MainState {
  int navIndex;
  bool hkPathPresent;

  MainState(this.navIndex, this.hkPathPresent);

  MainState copyWith(
          {int Function()? navIndex, bool Function()? hkPathPresent}) =>
      MainState(navIndex == null ? this.navIndex : navIndex.call(),
          hkPathPresent == null ? this.hkPathPresent : hkPathPresent.call());
}

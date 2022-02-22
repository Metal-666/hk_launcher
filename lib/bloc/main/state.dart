class MainState {
  int navIndex;
  HKPathDialog? hkPathDialog;

  MainState(this.navIndex, this.hkPathDialog);

  MainState copyWith(
          {int Function()? navIndex, HKPathDialog? Function()? hkPathDialog}) =>
      MainState(navIndex == null ? this.navIndex : navIndex.call(),
          hkPathDialog == null ? this.hkPathDialog : hkPathDialog.call());
}

class HKPathDialog {
  String? path, error;

  HKPathDialog(this.path, this.error);
}

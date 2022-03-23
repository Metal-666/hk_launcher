class SavesState {
  final bool backupCooldown;

  const SavesState({this.backupCooldown = false});

  SavesState copyWith({bool Function()? backupCooldown}) => SavesState(
      backupCooldown:
          backupCooldown == null ? this.backupCooldown : backupCooldown.call());
}

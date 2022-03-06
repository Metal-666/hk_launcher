import 'state.dart';

abstract class ProfilesEvent {}

class ChangeTab extends ProfilesEvent {
  final int index;

  ChangeTab(this.index);
}

class AddTab extends ProfilesEvent {}

class CloseNewTabDialog extends ProfilesEvent {}

class SubmitNewTabDialog extends ProfilesEvent {}

class PickHKFolder extends ProfilesEvent {}

class ChangeNewProfileName extends ProfilesEvent {
  final String name;

  ChangeNewProfileName(this.name);
}

class ChangeNewProfilePath extends ProfilesEvent {
  final String path;

  ChangeNewProfilePath(this.path);
}

class ChangeNewProfileVersion extends ProfilesEvent {
  final int version;

  ChangeNewProfileVersion(this.version);
}

class DeleteProfile extends ProfilesEvent {
  final Profile profile;

  DeleteProfile(this.profile);
}

class MakeProfileCurrent extends ProfilesEvent {
  final Profile profile;

  MakeProfileCurrent(this.profile);
}

class SelectModpack extends ProfilesEvent {
  final Profile profile;
  final Modpack modpack;

  SelectModpack(this.profile, this.modpack);
}

class CloseModpackErrorDialog extends ProfilesEvent {}

class DuplicateModpack extends ProfilesEvent {
  final Modpack modpack;

  DuplicateModpack(this.modpack);
}

class ShowModpackInExplorer extends ProfilesEvent {
  final Profile profile;
  final Modpack modpack;

  ShowModpackInExplorer(this.profile, this.modpack);
}

class SubmitNewModpackDialog extends ProfilesEvent {
  final Profile profile;
  final Modpack modpack;

  SubmitNewModpackDialog(this.profile, this.modpack);
}

class ChangeNewModpackName extends ProfilesEvent {
  final String name;

  ChangeNewModpackName(this.name);
}

class CloseNewModpackDialog extends ProfilesEvent {}

import 'state.dart';

abstract class ProfilesEvent {}

class ChangeTab extends ProfilesEvent {
  int index;

  ChangeTab(this.index);
}

class AddTab extends ProfilesEvent {}

class CloseNewTabDialog extends ProfilesEvent {}

class SubmitNewTabDialog extends ProfilesEvent {
  String name, path;

  SubmitNewTabDialog(this.name, this.path);
}

class PickHKFolder extends ProfilesEvent {}

class DeleteProfile extends ProfilesEvent {
  Profile profile;

  DeleteProfile(this.profile);
}

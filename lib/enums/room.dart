// ignore_for_file: constant_identifier_names

enum RoomType {
  DUET('duet'),
  GROUP('group');

  const RoomType(this.value);
  final String value;

  @override
  String toString() => value;
}

enum RoomUserRole {
  DUET_CREATOR("duet_creator"),
  DUET_NORMAL("duet_normal"),
  GROUP_CREATOR("group_creator"),
  GROUP_ADMIN("group_admin"),
  GROUP_NORMAL("group_normal");

  const RoomUserRole(this.value);
  final String value;

  @override
  String toString() => value;
}

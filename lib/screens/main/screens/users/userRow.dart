import 'package:connects_you/models/user.dart';
import 'package:connects_you/widgets/avatar.dart';
import 'package:flutter/material.dart';

class UserRow extends StatelessWidget {
  final User user;
  final bool isSelected;
  final Function() onLongPress;
  final Function() onTap;

  const UserRow({
    Key? key,
    required this.user,
    this.isSelected = false,
    required this.onLongPress,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.primaryColor.withOpacity(0.25),
      key: ValueKey(user.userId),
      leading: Avatar(photoUrl: user.photo),
      title: Text(user.name),
      subtitle: Text(
        user.email,
        style: TextStyle(
          color: theme.primaryColor.withOpacity(0.75),
        ),
      ),
      onLongPress: onLongPress,
      onTap: onTap,
    );
  }
}

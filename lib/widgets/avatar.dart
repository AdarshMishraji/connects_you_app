import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? photoUrl;
  const Avatar({Key? key, this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return photoUrl == null
        ? CircleAvatar(
            backgroundColor: theme.primaryColor,
            radius: 99,
            child: const Icon(Icons.person, color: Colors.white),
          )
        : CircleAvatar(
            backgroundImage: NetworkImage(photoUrl!),
          );
  }
}

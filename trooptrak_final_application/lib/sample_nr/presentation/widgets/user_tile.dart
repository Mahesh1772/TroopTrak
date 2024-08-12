import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text('Rank: ${user.rank} | Company: ${user.company}'),
    );
  }
}
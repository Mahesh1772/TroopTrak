import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/sample_nr/domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../widgets/user_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: StreamBuilder<List<User>>(
        stream: context.read<UserProvider>().users,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return UserTile(user: users[index]);
            },
          );
        },
      ),
    );
  }
}

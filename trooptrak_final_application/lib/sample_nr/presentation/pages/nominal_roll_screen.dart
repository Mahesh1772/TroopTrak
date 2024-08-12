import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/sample_nr/domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../widgets/user_tile.dart';

class NominalRollPage extends StatelessWidget {
  const NominalRollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nominal Roll'),
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

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              childAspectRatio: 2 / 3, // Width to height ratio of each tile
              crossAxisSpacing: 5.0, // Spacing between columns
              mainAxisSpacing: 10.0, // Spacing between rows
            ),
            padding: const EdgeInsets.all(10.0),
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

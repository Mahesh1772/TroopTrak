import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/sample_nr/domain/entities/user.dart';
import 'package:trooptrak_final_application/sample_nr/presentation/pages/qr_scanner_page.dart';
import '../providers/user_provider.dart';
import '../widgets/user_tile.dart';

class NominalRollPage extends StatelessWidget {
  const NominalRollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 72, 30, 229),
         onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerPage()),
          );
          if (result != null) {
            // Handle the scanned soldier data
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Soldier ${result.name} added')),
            );
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
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


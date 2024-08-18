// lib/sample_nr/presentation/pages/nominal_roll_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../widgets/user_tile.dart';
import 'qr_scanner_page.dart';

class NominalRollPage extends StatelessWidget {
  const NominalRollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 72, 30, 229),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const QRScannerPage();
            },
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          );
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
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 10.0,
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

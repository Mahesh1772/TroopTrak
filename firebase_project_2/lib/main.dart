import 'package:flutter/material.dart';
import 'package:firebase_project_2/src/utils/themes/thems.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppHome(),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(".appable/"),
        leading: const Icon(Icons.ondemand_video_rounded),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(
          Icons.add_shopping_cart_outlined,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Heading",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              "Sub-Heading",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "Para",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Image(
                height: 200,
                width: 200,
                image: AssetImage('assets/images/books.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

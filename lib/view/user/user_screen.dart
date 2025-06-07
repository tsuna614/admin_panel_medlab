import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Center(
        child: Text(
          'User Management Screen',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

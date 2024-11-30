import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:flutter/material.dart';



class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Notifications Page!'),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false,false,true,false],
      ),
    );
  }
}

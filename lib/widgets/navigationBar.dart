import 'package:dailyflow/main.dart';
import 'package:dailyflow/notificationsPage.dart';
import 'package:dailyflow/searchPage.dart';
import 'package:dailyflow/userProfilePage.dart';
import 'package:dailyflow/widgets/standardButton.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final List<bool> enabledButtons;
  const CustomNavigationBar({super.key, required this.enabledButtons});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StandardButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                NoAnimationPageRoute(builder: (context) => const MyHomePage()),
              );
            },
            selected: enabledButtons[0],
          ),
          StandardButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                NoAnimationPageRoute(builder: (context) => const SearchPage()),
              );
            },
            selected: enabledButtons[1],
          ),
          StandardButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                NoAnimationPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            selected: enabledButtons[2],
          ),
          StandardButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                NoAnimationPageRoute(builder: (context) => const UserProfilePage()),
              );
            },
            selected: enabledButtons[3],
          ),
        ],
      ),
    );
  }
}

class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  NoAnimationPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 0),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        );
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'new_workout_screen.dart';
import 'welcome_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeScreen(
        onStartWorkout: () {
          setState(() {
            selectedIndex = 2;
          });
        },
      ),
      const StatsScreen(),
      const NewWorkoutScreen(),
      const FriendsScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF7C5CFF) : Colors.white54,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF7C5CFF) : Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[selectedIndex],

      bottomNavigationBar: Container(
        height: 82,
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          border: Border(top: BorderSide(color: Color(0xFF1F2937), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _navItem(
                icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                label: "Home",
                index: 0,
              ),
            ),

            Expanded(
              child: _navItem(
                icon: selectedIndex == 1
                    ? Icons.track_changes
                    : Icons.track_changes_outlined,
                label: "Stats",
                index: 1,
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                },
                child: Transform.translate(
                  offset: const Offset(0, -17),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5511B8), Color(0xFF7C3AED)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.25),
                              blurRadius: 7,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        "Workout",
                        style: TextStyle(
                          color: selectedIndex == 2
                              ? const Color(0xFF7C5CFF)
                              : Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: _navItem(
                icon: selectedIndex == 3 ? Icons.groups : Icons.groups_outlined,
                label: "Friends",
                index: 3,
              ),
            ),

            Expanded(
              child: _navItem(
                icon: selectedIndex == 4 ? Icons.person : Icons.person_outline,
                label: "Profile",
                index: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1224),
      body: Center(
        child: Text(
          "Stats",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Friends")));
  }
}

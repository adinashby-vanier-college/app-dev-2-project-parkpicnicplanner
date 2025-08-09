import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/all_parks_screen.dart';
import 'screens/profile_screen.dart';
import 'models/user.dart';

void main() {
  runApp(const ParkPicnicPlannerApp());
}

class ParkPicnicPlannerApp extends StatelessWidget {
  const ParkPicnicPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Picnic Planner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(user: currentUser),
        '/event': (context) => EventDetailScreen(attendees: demoAttendees),
        '/parks': (context) => const AllParksScreen(),
        '/profile': (context) => ProfileScreen(user: currentUser),
      },
    );
  }
}

// Demo data
final User currentUser = User(
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  bio: 'Nature lover and picnic enthusiast',
  isPrivate: false,
);

final List<User> demoAttendees = [
  currentUser,
  User(id: '2', name: 'Alex Johnson', email: 'alex@example.com', isPrivate: false),
  User(id: '3', name: 'Sean Jefferies', email: 'sean@example.com', isPrivate: true),
  User(id: '4', name: 'Danielle Watson', email: 'danielle@example.com', isPrivate: false),
  User(id: '5', name: 'Tiffany Myers', email: 'tiffany@example.com', isPrivate: true),
];
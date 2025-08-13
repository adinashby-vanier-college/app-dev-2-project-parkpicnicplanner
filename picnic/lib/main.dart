import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:picnic/screens/picnic_chats_screen.dart';

import 'package:picnic/screens/register_screen.dart';
import 'config/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/all_parks_screen.dart';
import 'screens/profile_screen.dart';
import 'models/user.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: "Park Picnic Planner",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sign in anonymously and wait for completion
  // await auth.FirebaseAuth.instance.signInAnonymously();

  runApp(const ParkPicnicPlannerApp());
}

class ParkPicnicPlannerApp extends StatelessWidget {
  const ParkPicnicPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Picnic Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreenWrapper(),
        '/event': (context) => EventDetailScreenWrapper(),
        '/parks': (context) => const AllParksScreen(),
        '/profile': (context) => ProfileScreenWrapper(),
        '/register': (context) => const RegisterScreen(),
        '/debug': (context) => const PicnicChatsScreen()
      },
    );
  }
}

// Wrapper to handle user loading for HomeScreen
class HomeScreenWrapper extends StatefulWidget {
  @override
  _HomeScreenWrapperState createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await getCurrentUser();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading user data'),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return HomeScreen(user: currentUser!);
  }
}

// Wrapper to handle user loading for ProfileScreen
class ProfileScreenWrapper extends StatefulWidget {
  @override
  _ProfileScreenWrapperState createState() => _ProfileScreenWrapperState();
}

class _ProfileScreenWrapperState extends State<ProfileScreenWrapper> {
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await getCurrentUser();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading user data'),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return ProfileScreen(user: currentUser!);
  }
}

// Wrapper for EventDetailScreen with demo attendees
class EventDetailScreenWrapper extends StatefulWidget {
  @override
  _EventDetailScreenWrapperState createState() => _EventDetailScreenWrapperState();
}

class _EventDetailScreenWrapperState extends State<EventDetailScreenWrapper> {
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await getCurrentUser();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('Error loading user data')),
      );
    }

    // Create demo attendees with proper IDs
    final List<User> demoAttendees = [
      currentUser!,
      User(id: 'demo_2', name: 'Alex Johnson', email: 'alex@example.com', isPrivate: false),
      User(id: 'demo_3', name: 'Sean Jefferies', email: 'sean@example.com', isPrivate: true),
      User(id: 'demo_4', name: 'Danielle Watson', email: 'danielle@example.com', isPrivate: false),
      User(id: 'demo_5', name: 'Tiffany Myers', email: 'tiffany@example.com', isPrivate: true),
    ];

    return EventDetailScreen(attendees: demoAttendees);
  }
}

// Function to get or create current user with proper Firebase Auth ID
Future<User?> getCurrentUser() async {
  try {
    // Get current Firebase Auth user
    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    // Try to get existing user from Firestore
    final firestoreService = FirestoreService();
    User? existingUser = await firestoreService.getUser(firebaseUser.uid);

    if (existingUser != null) {
      return existingUser;
    }

    // Create new user with Firebase Auth data
    final newUser = User(
      id: firebaseUser.uid,  // Use Firebase Auth UID
      name: firebaseUser.displayName ?? 'Anonymous User',
      email: firebaseUser.email ?? 'anonymous@example.com',
      bio: 'Nature lover and picnic enthusiast',
      isPrivate: false,
      profileImageUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to Firestore
    await firestoreService.createUser(newUser);

    return newUser;

  } catch (e) {
    return null;
  }
}
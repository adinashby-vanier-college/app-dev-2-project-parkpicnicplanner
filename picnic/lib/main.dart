import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:picnic/screens/picnic_chats_screen.dart';
import 'package:picnic/screens/picnic_creation_screen.dart';
import 'package:picnic/screens/register_screen.dart';
import 'config/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/all_parks_screen.dart';
import 'screens/profile_screen.dart';

import 'models/user.dart';
import 'services/firestore_service.dart';
import 'services/service_locator.dart' as sl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  sl.setupServices();
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
        '/parks': (context) => const AllParksScreen(),
        '/register': (context) => const RegisterScreen(),
        '/debug': (context) => const PicnicChatsScreen(),
        '/create': (context) => const PicnicCreationScreen(),

        '/home': (context) => UserLoader(
          onLoaded: (user) => HomeScreen(user: user),
        ),
        '/profile': (context) => UserLoader(
          appBarTitle: 'Profile',
          onLoaded: (user) => ProfileScreen(user: user),
        ),
        '/event': (context) => UserLoader(
          onLoaded: (user) {
            // Demo attendees that include the current user
            final attendees = <User>[
              user,
              User(id: 'demo_2', name: 'Alex Johnson', email: 'alex@example.com', isPrivate: false),
              User(id: 'demo_3', name: 'Sean Jefferies', email: 'sean@example.com', isPrivate: true),
              User(id: 'demo_4', name: 'Danielle Watson', email: 'danielle@example.com', isPrivate: false),
              User(id: 'demo_5', name: 'Tiffany Myers', email: 'tiffany@example.com', isPrivate: true),
            ];
            return EventDetailScreen(attendees: attendees);
          },
        ),
      },
    );
  }
}

/// - Shows a spinner while loading
/// - Shows a simple error with a button back to login if user is null
class UserLoader extends StatefulWidget {
  const UserLoader({
    super.key,
    required this.onLoaded,
    this.appBarTitle,
  });

  final Widget Function(User user) onLoaded;
  final String? appBarTitle;

  @override
  State<UserLoader> createState() => _UserLoaderState();
}

class _UserLoaderState extends State<UserLoader> {
  late final Future<User?> _futureUser = getCurrentUser();

  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder<User?>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error loading user data'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          );
        }
        return widget.onLoaded(snapshot.data!);
      },
    );

    if (widget.appBarTitle != null) {
      return Scaffold(appBar: AppBar(title: Text(widget.appBarTitle!)), body: body);
    }
    return Scaffold(body: body);
  }
}

// Function to get or create current user with proper Firebase Auth ID
Future<User?> getCurrentUser() async {
  try {
    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    final firestoreService = FirestoreService();
    final existingUser = await firestoreService.getUser(firebaseUser.uid);
    if (existingUser != null) return existingUser;

    final newUser = User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Anonymous User',
      email: firebaseUser.email ?? 'anonymous@example.com',
      bio: 'Nature lover and picnic enthusiast',
      isPrivate: false,
      profileImageUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await firestoreService.createUser(newUser);
    return newUser;
  } catch (_) {
    return null;
  }
}

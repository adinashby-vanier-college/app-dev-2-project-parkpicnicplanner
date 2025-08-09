import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _bioController = TextEditingController(text: _currentUser.bio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save changes
                  _currentUser = _currentUser.copyWith(
                    bio: _bioController.text,
                  );
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _currentUser.profileImageUrl != null
                      ? NetworkImage(_currentUser.profileImageUrl!)
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                ),
                if (_isEditing)
                  FloatingActionButton.small(
                    onPressed: _changeProfilePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // User Name
            Text(
              _currentUser.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Privacy Toggle
            SwitchListTile(
              title: const Text('Private Profile'),
              value: _currentUser.isPrivate,
              onChanged: _isEditing
                  ? (value) {
                setState(() {
                  _currentUser = _currentUser.copyWith(isPrivate: value);
                });
              }
                  : null,
            ),

            // Bio Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Me',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Tell others about yourself...',
                    ),
                  )
                      : Text(
                    _currentUser.bio ?? 'No bio yet',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    // Implement image picking functionality
    // For now, we'll just simulate a change
    setState(() {
      _currentUser = _currentUser.copyWith(
        profileImageUrl: 'https://example.com/new_profile.jpg',
      );
    });
  }
}
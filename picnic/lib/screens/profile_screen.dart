import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  late User _currentUser;
  late TextEditingController _bioController;
  late TextEditingController _nameController;

  bool _isEditing = false;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _bioController = TextEditingController(text: _currentUser.bio);
    _nameController = TextEditingController(text: _currentUser.name);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? profileImageUrl = _currentUser.profileImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        // Delete old image if exists
        if (_currentUser.profileImageUrl != null) {
          await _firestoreService.deleteProfilePicture(_currentUser.id);
        }

        profileImageUrl = await _firestoreService.uploadProfilePicture(
            _currentUser.id,
            _selectedImage!
        );
      }

      // Create updated user
      final updatedUser = _currentUser.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        profileImageUrl: profileImageUrl,
      );

      // Save to Firestore
      await _firestoreService.saveUser(updatedUser);

      setState(() {
        _currentUser = updatedUser;
        _selectedImage = null;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
      _bioController.text = _currentUser.bio ?? '';
      _nameController.text = _currentUser.name;
    });
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
                SizedBox(height: 10),
                Text(
                  'This action cannot be undone. All your data will be permanently removed.',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete user's profile picture if exists
      if (_currentUser.profileImageUrl != null) {
        await _firestoreService.deleteProfilePicture(_currentUser.id);
      }

      // Delete user from Firestore
      await _firestoreService.deleteUser(_currentUser.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login or home screen
        // You might want to replace this with your app's login route
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // Replace with your login route
              (Route<dynamic> route) => false,
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _isLoading ? null : _cancelEditing,
            ),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveChanges,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'delete') {
                  _showDeleteAccountDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: _buildProfileImage(),
                  ),
                ),
                if (_isEditing)
                  FloatingActionButton.small(
                    onPressed: _isLoading ? null : _changeProfilePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // User Name Section
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                _currentUser.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 10),

            // Email (Read-only)
            Text(
              _currentUser.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Privacy Toggle
            SwitchListTile(
              title: const Text('Private Profile'),
              subtitle: const Text('Only you can see your profile when enabled'),
              value: _currentUser.isPrivate,
              onChanged: _isEditing && !_isLoading
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
                    enabled: !_isLoading,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Tell others about yourself...',
                      helperText: 'Optional',
                    ),
                  )
                      : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentUser.bio?.isEmpty == true || _currentUser.bio == null
                          ? 'No bio yet'
                          : _currentUser.bio!,
                      style: TextStyle(
                        fontSize: 16,
                        color: _currentUser.bio?.isEmpty == true || _currentUser.bio == null
                            ? Colors.grey[600]
                            : null,
                        fontStyle: _currentUser.bio?.isEmpty == true || _currentUser.bio == null
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timestamps (for info)
            if (_currentUser.updatedAt != null) ...[
              const SizedBox(height: 20),
              Text(
                'Last updated: ${_formatDateTime(_currentUser.updatedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (_currentUser.profileImageUrl != null) {
      return Image.network(
        _currentUser.profileImageUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.person, size: 60),
      );
    } else {
      return const Icon(Icons.person, size: 60);
    }
  }

  Future<void> _changeProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_currentUser.profileImageUrl != null || _selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _currentUser = _currentUser.copyWith(profileImageUrl: null);
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/validators/picnic_form_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  final int nameMinLength = 2;
  final int passwordMinLength = 8;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordInitialController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _loading = false;
  bool _formValid = false;
  String? _error;

  late final FormFieldValidator<String> _firstNameValidator;
  late final FormFieldValidator<String> _lastNameValidator;
  late final FormFieldValidator<String> _emailValidator;
  late final FormFieldValidator<String> _passwordMinimumValidator;
  late final FormFieldValidator<String> _passwordMatchesValidator;

  @override
  void initState() {
    super.initState();

    // Initialize validators
    _firstNameValidator = PicnicFormValidators.minLength(
      "Must be ${widget.nameMinLength} characters or longer",
      length: widget.nameMinLength,
    );

    _lastNameValidator = PicnicFormValidators.minLength(
      "Must be ${widget.nameMinLength} characters or longer",
      length: widget.nameMinLength,
    );

    _emailValidator = PicnicFormValidators.email();

    _passwordMinimumValidator = PicnicFormValidators.custom((value) {
      if (_passwordInitialController.text.isEmpty ||
          _passwordInitialController.text.length < widget.passwordMinLength) {
        return "Password must be at least ${widget.passwordMinLength} characters";
      }
      return null;
    });

    _passwordMatchesValidator = PicnicFormValidators.custom((value) {
      if (_passwordInitialController.text != _passwordConfirmController.text) {
        return "Passwords don't match";
      }
      return null;
    });

    // Add listeners to update form validity
    _firstNameController.addListener(_updateFormValidity);
    _lastNameController.addListener(_updateFormValidity);
    _emailController.addListener(_updateFormValidity);
    _passwordInitialController.addListener(_updateFormValidity);
    _passwordConfirmController.addListener(_updateFormValidity);
  }

  void _updateFormValidity() {
    final isValid = _firstNameValidator(_firstNameController.text) == null &&
        _lastNameValidator(_lastNameController.text) == null &&
        _emailValidator(_emailController.text) == null &&
        _passwordMinimumValidator(_passwordInitialController.text) == null &&
        _passwordMatchesValidator(_passwordConfirmController.text) == null;

    if (_formValid != isValid && mounted) {
      setState(() {
        _formValid = isValid;
      });
    }
  }

  Future<void> _register() async {
    if (!_formValid) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordInitialController.text.trim(),
      );

      // 2. Get the newly created user
      final User? user = userCredential.user;

      if (user != null) {
        // 3. Create a user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 4. Update the user's display name
        await user.updateDisplayName(
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
        );

        // 5. Send email verification
        await user.sendEmailVerification();

        // 6. Navigate to home screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      if (mounted) {
        setState(() {
          _error = errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordInitialController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Picnic Planner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "Register",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                          helperText: ' ',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _firstNameValidator,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                          helperText: ' ',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _lastNameValidator,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          helperText: ' ',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 24),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(15),
                          border: Border.all(color: Colors.white),
                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _passwordInitialController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                  helperText: ' ',
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: _passwordMinimumValidator,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordConfirmController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                  helperText: ' ',
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: _passwordMatchesValidator,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _formValid && !_loading ? _register : null,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
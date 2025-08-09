import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordInitialController =
      TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _loading = false;
  bool _formValid = false;
  String? _error;

  FormFieldValidator<String>? _firstNameValidator;
  FormFieldValidator<String>? _lastNameValidator;
  FormFieldValidator<String>? _emailValidator;
  FormFieldValidator<String>? passwordMinimumValidator;
  FormFieldValidator<String>? passwordMatchesValidator;
  FormFieldValidator<String>? validateForm;

  @override
  void initState() {
    super.initState();

    //Configure firstNameValidator
    _firstNameValidator = PicnicFormValidators.minLength(
      "Must be ${widget.nameMinLength} characters or longer",
      length: widget.nameMinLength,
    );

    //Configure lastNameValidator
    _lastNameValidator = PicnicFormValidators.minLength(
      "Must be ${widget.nameMinLength} characters or longer",
      length: widget.nameMinLength,
    );

    //Configure Validator for Email
    _emailValidator = PicnicFormValidators.email();


    //Configure Validator for Password Minimum
    passwordMinimumValidator = PicnicFormValidators.custom((value) {
      String initialPassword = _passwordInitialController.text;
      String confirmPassword = _passwordConfirmController.text;

      //Check length of password
      if ((initialPassword == null) ||
          initialPassword.isEmpty ||
          (initialPassword.length < widget.passwordMinLength)) {
        return "Password much be longer than ${widget.passwordMinLength} characters";
      }

      return null;
    });

    //Configure Validator for Password Mismatch
    passwordMatchesValidator = PicnicFormValidators.custom((value) {
      String initialPassword = _passwordInitialController.text;
      String confirmPassword = _passwordConfirmController.text;

      //Check length of password
      if (initialPassword != confirmPassword) {
        return "Passwords don't match";
      }

      return null;
    });

    validateForm = PicnicFormValidators.custom((value) {
      checkForm();
      return null;
    });
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    //TODO: Proper registration given user form information

    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text.trim(),
    //   );
    //   Navigator.pushReplacementNamed(context, '/home');
    // } on FirebaseAuthException catch (e) {
    //   setState(() {
    //     _error = e.message;
    //   });
    // } finally {
    //   setState(() {
    //     _loading = false;
    //   });
    // }
  }

  void checkForm(){
    bool formIsValid = (_firstNameValidator?.call(_firstNameController.text) == null);
    formIsValid &= (_lastNameValidator?.call(_lastNameController.text) == null);
    formIsValid &= (_emailValidator?.call(_emailController.text) == null);
    formIsValid &= (passwordMinimumValidator?.call(null) == null);
    formIsValid &= (passwordMatchesValidator?.call(null) == null);

    setState(() {
      _formValid = formIsValid;
    });

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
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            spacing: 20,
            children: [
              Text(
                "Register",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: PicnicFormValidators.composite([_firstNameValidator, validateForm]),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: PicnicFormValidators.composite([_lastNameValidator, validateForm]),
              ),
              TextFormField(
                controller: _emailController,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: PicnicFormValidators.composite([_emailValidator,validateForm]),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(15),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                  child: Column(
                    spacing: 20,
                    children: [
                      TextFormField(
                        controller: _passwordInitialController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: PicnicFormValidators.composite([passwordMinimumValidator,validateForm]),
                      ),
                      TextFormField(
                        controller: _passwordConfirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: PicnicFormValidators.composite([passwordMatchesValidator, validateForm]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_formValid ? (){
                    _formKey.currentState!.validate();

                    if (_formValid) {
                      _register();
                    }
                  } : null ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

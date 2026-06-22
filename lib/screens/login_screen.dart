import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(seconds: 30);
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  int _lockSecondsRemaining = 0;
  Timer? _lockTimer;

  bool get _isLocked => _lockedUntil != null;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  void _startLockout() {
    _lockTimer?.cancel();
    setState(() {
      _lockedUntil = DateTime.now().add(_lockoutDuration);
      _lockSecondsRemaining = _lockoutDuration.inSeconds;
      _errorMessage = null;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _lockedUntil!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _lockedUntil = null;
          _lockSecondsRemaining = 0;
          _failedAttempts = 0;
        });
      } else {
        setState(() {
          _lockSecondsRemaining = remaining;
        });
      }
    });
  }

  String _messageForAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "That email address isn't valid.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "Incorrect email or password.";
      case 'email-already-in-use':
        return "An account already exists for that email.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }

  Future<void> _submit() async {
    if (_isLocked) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final UserCredential credential;
      if (_isRegistering) {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      _failedAttempts = 0;
      // On success, the auth state stream updates and AuthGate
      // navigates to ContentView automatically.
    } on FirebaseAuthException catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= _maxFailedAttempts) {
        _startLockout();
      } else {
        setState(() {
          _errorMessage = _messageForAuthError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegistering ? "Create Account" : "Welcome Back",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 32),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!_emailPattern.hasMatch(value.trim())) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  if (_isLocked) ...[
                    SizedBox(height: 16),
                    Text(
                      "Too many failed attempts. Try again in $_lockSecondsRemaining"
                      "s.",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (_errorMessage != null) ...[
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  SizedBox(height: 24),

                  FilledButton(
                    onPressed: (_isSubmitting || _isLocked) ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isRegistering ? "Sign Up" : "Log In"),
                  ),

                  SizedBox(height: 12),

                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _isRegistering = !_isRegistering;
                              _errorMessage = null;
                            });
                          },
                    child: Text(
                      _isRegistering
                          ? "Already have an account? Log In"
                          : "Don't have an account? Sign Up",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

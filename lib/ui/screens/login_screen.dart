import 'package:aura_health_companion/data/supabase_service.dart';
import 'package:aura_health_companion/ui/screens/home_screen.dart';
import 'package:aura_health_companion/ui/screens/signup_screen.dart';
import 'package:aura_health_companion/ui/widgets/error_animation.dart';
import 'package:aura_health_companion/ui/widgets/success_animation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'success_animation.dart';
// import 'error_animation.dart'; // Import the new error animation widget

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await SupabaseService.signIn(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return SuccessAnimation(
                              message: 'Welcome back!',
                              onComplete: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    } on AuthApiException catch (e) {
                      if (!mounted) return;
                      var message = e.message;
                      if (e.message.toLowerCase().contains(
                        'email not confirmed',
                      )) {
                        message =
                            'Please check your email to confirm your account.';
                      }
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return ErrorAnimation(
                            message: message,
                            onDismiss: () {
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
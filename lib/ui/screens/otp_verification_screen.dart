import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/ui/widgets/error_animation.dart';
import 'package:aura_health_companion/ui/widgets/success_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_health_companion/logic/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:aura_health_companion/ui/screens/login_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const OTPVerificationScreen({super.key, required this.userData});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/PatternLogin.png',
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Image.asset('assets/loginLogo.png', width: 150),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Verify Your Email",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        color: const Color(0xFF00177E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Enter the 6-digit OTP sent to ${widget.userData['email']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 327,
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'OTP',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0025CC),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0F1120),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            fontSize: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the OTP';
                          }
                          if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'Enter a valid 6-digit OTP';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 327,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0025CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await AuthService.verifyOTP(
                                email: widget.userData['email'],
                                otp: _otpController.text,
                                userData: widget.userData,
                              );
                              authController.notifyAuthChange();
                              if (mounted) {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SuccessAnimation(
                                      message: 'Account created successfully! Please log in.',
                                      onComplete: () {
                                        _navigateToLogin();
                                      },
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              var message = e.toString().replaceAll('Exception: ', '');
                              if (message.contains('Invalid OTP')) {
                                message = 'Invalid or expired OTP';
                              } else if (message.contains('Email already used')) {
                                message = 'Email already exists';
                              } else {
                                message = 'Failed to verify OTP. Please try again.';
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
                        child: Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        try {
                          await AuthService.sendOTP(widget.userData['email']);
                          if (mounted) {
                            _otpController.clear(); // Clear the OTP input field
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return SuccessAnimation(
                                  message: 'New OTP sent successfullyyyyy!',
                                  onComplete: () {
                                    // Stay on OTP screen
                                  },
                                );
                              },
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          var message = e.toString().replaceAll('Exception: ', '');
                          if (message.contains('already used')) {
                            message = 'Email already exists. Please log in.';
                          } else {
                            message = 'Failed to resend OTP. Please try again.';
                          }
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return ErrorAnimation(
                                message: message,
                                onDismiss: () {
                                  Navigator.of(context).pop(); // Stay on OTP screen
                                },
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF0025CC),
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
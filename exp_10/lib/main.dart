import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/auth_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AuthenticationApp());
}

class AuthenticationApp extends StatelessWidget {
  const AuthenticationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Student Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4FA),
      ),
      home: const AuthGate(),
    );
  }
}

// Automatically displays login or dashboard
// depending on Firebase authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}

// LOGIN AND REGISTRATION PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    departmentController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }

    return null;
  }

  // Firebase error messages
  String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'The password is too weak.';

        case 'user-not-found':
        case 'invalid-credential':
          return 'Invalid email or password.';

        case 'wrong-password':
          return 'Incorrect password.';

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';

        case 'network-request-failed':
          return 'Network error. Check your internet connection.';

        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    return 'Something went wrong: $error';
  }

  // LOGIN OR REGISTER
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await authService.loginUser(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        await authService.registerUser(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          department: departmentController.text.trim(),
        );
      }

      // AuthGate automatically opens the dashboard.
      // No manual navigation is required.
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Password reset
  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email address first.'),
        ),
      );
      return;
    }

    try {
      await authService.resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final obscureText = isPassword
        ? hidePassword
        : isConfirmPassword
            ? hideConfirmPassword
            : false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword || isConfirmPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        hidePassword = !hidePassword;
                      } else {
                        hideConfirmPassword =
                            !hideConfirmPassword;
                      }
                    });
                  },
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440,
            ),
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 38,
                        backgroundColor: Color(0xFFE8EAF6),
                        child: Icon(
                          Icons.lock_person,
                          color: Colors.indigo,
                          size: 42,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        isLogin
                            ? 'Welcome Back!'
                            : 'Create Account',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        isLogin
                            ? 'Sign in to access your account'
                            : 'Register to create your account',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (!isLogin)
                        buildInputField(
                          controller: nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null ||
                                value.trim().length < 2) {
                              return 'Enter your full name';
                            }
                            return null;
                          },
                        ),

                      buildInputField(
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter your email';
                          }

                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),

                      if (!isLogin)
                        buildInputField(
                          controller: departmentController,
                          label: 'Department',
                          icon: Icons.school,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter your department';
                            }
                            return null;
                          },
                        ),

                      buildInputField(
                        controller: passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: validatePassword,
                      ),

                      if (!isLogin)
                        buildInputField(
                          controller: confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          isConfirmPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm your password';
                            }

                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                        ),

                      if (isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: forgotPassword,
                            child: const Text(
                              'Forgot Password?',
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: isLoading ? null : submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isLogin
                                    ? 'LOGIN'
                                    : 'CREATE ACCOUNT',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin
                                ? "Don't have an account?"
                                : 'Already have an account?',
                          ),

                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      isLogin = !isLogin;
                                    });

                                    formKey.currentState?.reset();
                                  },
                            child: Text(
                              isLogin ? 'Register' : 'Login',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Center(
                        child: Text(
                          'Secured by Firebase Authentication',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// DASHBOARD AFTER SUCCESSFUL LOGIN
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await authService.logoutUser();
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FutureBuilder(
            future: authService.getUserProfile(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return const Text(
                  'Unable to load user profile.',
                );
              }

              final data = snapshot.data?.data();

              if (data == null) {
                return const Text(
                  'User profile not found in Firestore.',
                );
              }

              final name = data['name'] ?? 'User';
              final email = data['email'] ?? user.email ?? '';
              final department = data['department'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFE8EAF6),
                          child: Icon(
                            Icons.person,
                            color: Colors.indigo,
                            size: 50,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Login Successful!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Welcome, $name',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 25),

                        ListTile(
                          leading: const Icon(
                            Icons.email,
                            color: Colors.indigo,
                          ),
                          title: const Text('Email Address'),
                          subtitle: Text(email),
                        ),

                        ListTile(
                          leading: const Icon(
                            Icons.school,
                            color: Colors.indigo,
                          ),
                          title: const Text('Department'),
                          subtitle: Text(department),
                        ),

                        ListTile(
                          leading: const Icon(
                            Icons.verified_user,
                            color: Colors.indigo,
                          ),
                          title: const Text('Authentication Status'),
                          subtitle: const Text('Authenticated'),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await authService.logoutUser();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('LOGOUT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
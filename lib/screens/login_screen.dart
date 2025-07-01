import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _service.signIn(_emailController.text, _passwordController.text);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: ${e.toString()}')),
                  );
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () async {
                String email = '';
                String password = '';
                String displayName = '';
                String role = 'visitor';
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Register'),
                      content: StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: InputDecoration(labelText: 'Email'),
                                onChanged: (v) => email = v,
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: 'Password'),
                                obscureText: true,
                                onChanged: (v) => password = v,
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: 'Display Name'),
                                onChanged: (v) => displayName = v,
                              ),
                              DropdownButton<String>(
                                value: role,
                                items: [
                                  DropdownMenuItem(value: 'visitor', child: Text('Visitor')),
                                  DropdownMenuItem(value: 'publisher', child: Text('Publisher')),
                                ],
                                onChanged: (v) => setState(() => role = v!),
                              ),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await _service.signUp(email, password, role, displayName);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registration successful! Please log in.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registration failed: \\${e.toString()}')),
                              );
                            }
                          },
                          child: Text('Register'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Correo electrónico')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
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
                    SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
                  );
                }
              },
              child: Text('Iniciar sesión'),
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
                      title: Text('Registrarse'),
                      content: StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: InputDecoration(labelText: 'Correo electrónico'),
                                onChanged: (v) => email = v,
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: 'Contraseña'),
                                obscureText: true,
                                onChanged: (v) => password = v,
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: 'Nombre para mostrar'),
                                onChanged: (v) => displayName = v,
                              ),
                              DropdownButton<String>(
                                value: role,
                                items: [
                                  DropdownMenuItem(value: 'visitor', child: Text('Visitante')),
                                  DropdownMenuItem(value: 'publisher', child: Text('Publicador')),
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
                                SnackBar(content: Text('¡Registro exitoso! Por favor inicia sesión.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al registrarse: ${e.toString()}')),
                              );
                            }
                          },
                          child: Text('Registrarse'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancelar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}

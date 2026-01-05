import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_auth/domain/entities/user.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Username harus diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password harus diisi';
                      if (v.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (opsional)',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!v.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (opsional)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      return switch (state) {
                        AuthLoading() => Center(
                          child: CircularProgressIndicator(),
                        ),
                        AuthSucces(message: var message) => Center(
                          child: Text(message),
                        ),
                        AuthFailed(message: var message) => Column(
                          children: [
                            Center(child: Text(message)),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(AuthStarted());
                              },
                              child: Text("Coba Lagi"),
                            ),
                          ],
                        ),
                        _ => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final data = User(
                                  _emailCtrl.text,
                                  _passwordCtrl.text,
                                  email: _usernameCtrl.text,
                                  phone: _phoneCtrl.text,
                                );
                                context.read<AuthBloc>().add(AuthOnSignUp(data));
                              }
                            },
                            child: Text('Daftar'),
                          ),
                        ),
                      };
                    },
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

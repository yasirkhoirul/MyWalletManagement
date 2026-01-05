import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_auth/domain/entities/user.dart' as user;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email harus diisi';
                        if (!v.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password harus diisi';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        return switch (state) {
                          AuthFailed(message: var message) => Center(
                            child: Text(message),
                          ),
                          AuthLoading() => Center(
                            child: CircularProgressIndicator(),
                          ),
                          AuthSucces(message: var message) => Center(
                            child: Text(message),
                          ),
                          _ => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final data = user.User(
                                    _emailCtrl.text,
                                    _passwordCtrl.text,
                                  );
                                  context.read<AuthBloc>().add(
                                    AuthOnLogin(data),
                                  );
                                }
                              },
                              child: const Text('Masuk'),
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
      ),
    );
  }
}

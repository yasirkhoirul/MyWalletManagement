import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                const SizedBox(height: 20),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOnSendEmail) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Silakan cek email Anda untuk mereset password.'),
                      ));
                      _emailCtrl.clear();
                      
                      Navigator.of(context).pop();
                    }
                  },
                  builder: (context, state) {
                    return switch (state) {
                      AuthLoading() => Center(
                        child: CircularProgressIndicator(),
                      ),
                      AuthFailed(message: var message) => Column(
                        children: [
                          Text(message),
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
                              context.read<AuthBloc>().add(
                                AuthOnForgot(_emailCtrl.text),
                              );
                            }
                          },
                          child: const Text('Kirim Email Reset'),
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
    );
  }
}

import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _role = 'Cashier';

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pop(context); // go back to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter username' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'Cashier', child: Text('Cashier')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  setState(() => _role = value.toString());
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) =>
                    v == null || v.length < 4 ? 'Min 4 characters' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              FilledButton(onPressed: _register, child: const Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}
